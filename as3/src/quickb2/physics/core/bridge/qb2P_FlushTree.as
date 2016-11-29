package quickb2.physics.core.bridge 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2ClosureConstructor;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.qb2ObjectPool;
	import quickb2.utils.qb2ObjectPoolClosureDelegate;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2P_FlushTree 
	{
		private static const s_utilPropertyFlags1:qb2MutablePropFlags = new qb2MutablePropFlags();
		
		private var m_visitor:qb2PI_FlushTreeVisitor;
		
		private const m_nodeManager:qb2P_FlushNodeManager = new qb2P_FlushNodeManager();
		private const m_shortDelayList:Vector.<qb2P_FlushCollector> = new Vector.<qb2P_FlushCollector>();
		
		private const m_worlds:Vector.<qb2World> = new Vector.<qb2World>();
		
		private var m_isWalking:Boolean;
		
		private const m_collectorPool:qb2ObjectPool = new qb2ObjectPool
		(
			new qb2ClosureConstructor(function():qb2P_FlushCollector
			{
				return new qb2P_FlushCollector();
			}),
			new qb2ObjectPoolClosureDelegate(function(collector:qb2P_FlushCollector):void
			{
				//TODO: Somehow only call clean for destruction....will probably have to modify pool API.
				collector.clean();
			})
		);
		
		public function qb2P_FlushTree(visitor:qb2PI_FlushTreeVisitor)
		{
			m_visitor = visitor;
		}		
		
		public function isWalking():Boolean
		{
			return m_isWalking;
		}
		
		public function getNodeCount(list:int):int
		{
			return m_nodeManager.getNodeCount();
		}
		
		public function isRootNode(node:qb2P_FlushNode):Boolean
		{
			return m_nodeManager.isRootNode(node);
		}
		
		public function getNode(object:qb2A_PhysicsObject):qb2P_FlushNode
		{
			return m_nodeManager.getNode(object);
		}
		
		public function isDelayedWithDirtyFlag(object:qb2A_PhysicsObject, dirtyFlag:int):Boolean
		{
			var node:qb2P_FlushNode = getNode(object);
			
			if ( node == null )  return false;
			
			var cachedCollected:qb2P_FlushCollector = node.getCachedCollector();
			
			if ( cachedCollected == null )  return false;
			
			return cachedCollected.hasDirtyFlag(dirtyFlag);
		}
		
		private function registerWorld(object_nullable:qb2A_PhysicsObject):void
		{
			if ( object_nullable == null )  return;
			
			if ( !qb2U_Type.isKindOf(object_nullable, qb2World) )  return;
			
			var asWorld:qb2World = object_nullable as qb2World;
			
			//--- DRK > NOTE: We're technically doing an array search here, but in practice there should really
			//---				only ever be one world flushing at a time...the array is here for just-in-case flexibility.
			var index:int = m_worlds.indexOf(asWorld);
			
			if ( index == -1 )
			{
				m_worlds.push(asWorld);
			}
		}
		
		public function flushWorlds():void
		{
			for ( var i:int = 0; i < m_worlds.length; i++ )
			{
				m_visitor.onFlushComplete(m_worlds[i]);
			}
			m_worlds.length = 0;
		}
		
		public function walk():void
		{
			m_isWalking = true;
			
			var i:int;
			var rootNodes:Vector.<qb2P_FlushNode> = m_nodeManager.getNodeList(qb2P_FlushNodeManager.ROOTS);
			for ( i = 0; i < rootNodes.length; i++ )
			{
				var rootNode:qb2P_FlushNode = rootNodes[i];
				
				if ( rootNode == null )  continue;
				
				var ancestorCollector_nullable:qb2P_FlushCollector = null;
				
				if ( rootNode.getObject().getParent() != null )
				{
					ancestorCollector_nullable = m_collectorPool.checkOut();
					ancestorCollector_nullable.initWithRootAncestors(rootNode);
					
					this.registerWorld(ancestorCollector_nullable.getWorld());
				}
				else
				{
					this.registerWorld(rootNode.getObject());
				}
				
				walkSubTree(rootNode.getObject(), ancestorCollector_nullable, null, /*isRoot=*/true);
				
				if ( ancestorCollector_nullable != null )
				{
					m_collectorPool.checkIn(ancestorCollector_nullable);
				}
			}
			
			this.processShortDelayList();
			
			this.processLongDelayList();
			
			m_nodeManager.garbageCollect();
			
			m_isWalking = false;
		}
		
		private function walkSubTree(object:qb2A_PhysicsObject, parentCollector_nullable:qb2P_FlushCollector, parentNode_nullable:qb2P_FlushNode, isRoot:Boolean):qb2P_FlushNode
		{
			var node:qb2P_FlushNode = this.getNode(object);
			
			m_visitor.onPreVisit(node, object, parentCollector_nullable, s_utilPropertyFlags1);
			
			var collector:qb2P_FlushCollector = node == null ? m_collectorPool.checkOut() : node.getCachedCollector();
			collector = collector /*still*/== null ? m_collectorPool.checkOut() : collector;
			collector.autoRelease();
			collector.initWithRootOrDescendant(node, object, parentCollector_nullable, isRoot);
			
			var originalDirtyFlags:int = node != null ? node.getDirtyFlags() : 0x0;
			
			//--- TODO(DRK, OPT): Figure out cleaner way to determine when to append changed properties from being added/removed to world.
			if ( (originalDirtyFlags & qb2PF_DirtyFlag.ADDED_OR_REMOVED) != 0x0 )
			{
				collector.appendChangedProperties(s_utilPropertyFlags1);
			}
			
			m_visitor.onVisit(node, collector, parentCollector_nullable);
			
			var promoteChildNodes:Boolean = false;
			
			if ( node != null )
			{
				node.clearAggregateFlags();
				node.appendToAggregateDirtyFlags(node.getDirtyFlags());
				
				if ( parentNode_nullable == null  )
				{
					if ( node.isClean() )
					{
						m_nodeManager.deleteNode(node);
						promoteChildNodes = true;
						node = null;
					}
				}
			}
			
			//--- DRK > TODO: As an optimization, there might be instances where we don't have to continue down the tree.
			//---				Not sure what those instances are though, or if they even exist or are reasonably determinable.
			//if ( !collector.areDirtyFlagsCleared() )
			{
				var objectAsContainer:qb2A_PhysicsObjectContainer = object as qb2A_PhysicsObjectContainer;
				if ( objectAsContainer != null )
				{
					var child:qb2A_PhysicsObject = objectAsContainer.getFirstChild();
					
					while ( child != null )
					{
						var childNode:qb2P_FlushNode = this.getNode(child);
						
						if ( childNode != null && promoteChildNodes )
						{
							this.m_nodeManager.moveToList(childNode, qb2P_FlushNodeManager.ROOTS);
						}
						
						childNode = walkSubTree(child, collector, node, /*isRoot=*/false);
						
						if ( childNode != null && node != null )
						{
							node.appendToAggregateDirtyFlags(childNode.getAggregateDirtyFlags());
						}
						
						child = child.getNextSibling();
					}
				}
			}
			
			if ( node != null )
			{
				if ( node.isClean() )
				{
					m_nodeManager.deleteNode(node);
					node = null;
				}
			}
			
			m_visitor.onPostVisit(object, originalDirtyFlags);
			
			if ( collector.shouldRelease() )
			{
				m_collectorPool.checkIn(collector);
			}
			
			return node;
		}
		
		private function processShortDelayList():void
		{
			for ( var i:int = 0; i < m_shortDelayList.length; i++ )
			{
				var collector:qb2P_FlushCollector = m_shortDelayList[i];
				
				this.m_visitor.onShortDelayVisit(collector);
				
				m_collectorPool.checkIn(collector);
			}
			
			m_shortDelayList.length = 0;
		}
		
		private function processLongDelayList():void
		{
			var delayedNodes:Vector.<qb2P_FlushNode> = m_nodeManager.getNodeList(qb2P_FlushNodeManager.LONG_DELAYED);
			for ( var i:int = 0; i < delayedNodes.length; i++ )
			{
				this.addToTree_private(delayedNodes[i]);
			}
		}
		
		public function delay(collector:qb2P_FlushCollector, dirtyFlags:int, delayType:qb2PE_FlushDelay):void
		{
			var object:qb2A_PhysicsObject = collector.getObject();
			var node:qb2P_FlushNode = m_nodeManager.getNode(object);
			
			if ( delayType == qb2PE_FlushDelay.LONG )
			{
				if ( node == null )
				{
					node = m_nodeManager.newNode(object, dirtyFlags, null);
					
					this.m_nodeManager.moveToList(node, qb2P_FlushNodeManager.LONG_DELAYED);
				}
				else
				{
					node.appendDirtyFlags(dirtyFlags, null);
				}
				
				node.cacheCollector(collector);
			}
			else if ( delayType == qb2PE_FlushDelay.SHORT )
			{
				if ( node != null )
				{
					qb2_assert(node.getCachedCollector() == null);
				}
			
				qb2_assert(dirtyFlags == 0x0);
				
				if ( !collector.shouldRelease() )
				{
					return; // means it's already in list...kinda sloppy way to tell though
				}
				
				collector.retain();
				
				m_shortDelayList.push(collector);
			}
		}
		
		internal function addToTree(object:qb2A_PhysicsObject, dirtyFlags:int, changedProperties_copied_nullable:qb2PropFlags):void
		{
			if ( m_isWalking )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_STATE, "Can't add to tree while walking.");
			}
			
			var node:qb2P_FlushNode = m_nodeManager.getNode(object);
			
			if ( node == null )
			{
				node = m_nodeManager.newNode(object, dirtyFlags, changedProperties_copied_nullable);
				
				this.addToTree_private(node);
			}
			else
			{
				this.appendDirtyFlags(node, dirtyFlags, changedProperties_copied_nullable);
			}
		}
		
		private function appendDirtyFlags(node:qb2P_FlushNode, dirtyFlags:int, changedProperties_copied_nullable:qb2PropFlags):void
		{
			if ( dirtyFlags == 0x0 )  return;
			
			var object:qb2A_PhysicsObject = node.getObject();
			node.appendDirtyFlags(dirtyFlags, changedProperties_copied_nullable);
			
			var ancestor:qb2A_PhysicsObjectContainer = object.getParent();
			
			while ( ancestor != null )
			{
				var ancestorNode:qb2P_FlushNode = this.getNode(ancestor);
				
				if ( ancestorNode == null )
				{
					return;
				}
				
				ancestorNode.appendToAggregateDirtyFlags(dirtyFlags);
				
				ancestor = ancestor.getParent();
			}
		}
		
		private function addToTree_private(node:qb2P_FlushNode):void
		{
			var newAncestorNode:qb2P_FlushNode;
			var object:qb2A_PhysicsObject = node.getObject();
			var ancestor:qb2A_PhysicsObjectContainer = object.getParent();
			var foundChildNodeAbove:Boolean = false;
			var isDelayedNode:Boolean = m_nodeManager.isDelayedNode(node);
			var dirtyFlags:int = node.getDirtyFlags();
			
			//--- DRK > Here, we search up the tree in order to see if there are any node leaves that are above the given node.
			//---		If we find any, then we form a chain of nodes from newNode to the leaf if necessary.
			while ( ancestor != null )
			{
				var ancestorNode:qb2P_FlushNode = this.getNode(ancestor);
				
				if ( ancestorNode != null )
				{
					foundChildNodeAbove = true;
					
					if ( !isDelayedNode )
					{
						var ancestorAgain:qb2A_PhysicsObjectContainer = object.getParent();
						
						qb2_assert(dirtyFlags != 0x0);
						
						while ( ancestorAgain != ancestor )
						{
							newAncestorNode = m_nodeManager.newNode(ancestorAgain, 0x0, null);
							newAncestorNode.appendToAggregateDirtyFlags(dirtyFlags);
							
							m_nodeManager.moveToList(newAncestorNode, qb2P_FlushNodeManager.CHILDREN);
							
							ancestorAgain = ancestorAgain.getParent();
						}
						
						ancestorNode.appendToAggregateDirtyFlags(dirtyFlags);
					}
					else
					{
						break;
					}
				}
				else if ( ancestorNode == null )
				{
					if ( /*already*/ foundChildNodeAbove )
					{
						break; // means we went past a root ancestor node...no need to continue up actual object's ancestors.
					}
				}
				
				ancestor = ancestor.getParent();
			}
			
			if ( foundChildNodeAbove )
			{
				m_nodeManager.moveToList(node, qb2P_FlushNodeManager.CHILDREN);
				
				return;
			}
			else
			{
				m_nodeManager.moveToList(node, qb2P_FlushNodeManager.ROOTS);
			}
			
			//--- DRK > Any root nodes that have this object as an ancestor must now relinquish their
			//---		root node status and form a chain of nodes to the new root node.
			var previousNode:qb2P_FlushNode = null;
			var rootNodes:Vector.<qb2P_FlushNode> = m_nodeManager.getNodeList(qb2P_FlushNodeManager.ROOTS);
			for ( var i:int = 0; i < rootNodes.length; i++ )
			{
				var rootNode:qb2P_FlushNode = rootNodes[i];
				
				if ( rootNode == null || rootNode == node )  continue;
				
				ancestor = rootNode.getObject().getParent();
				
				while ( ancestor != null )
				{
					if ( ancestor == object )
					{
						ancestorAgain = rootNode.getObject().getParent();
						previousNode = rootNode;
						
						while ( ancestorAgain != object )
						{
							newAncestorNode = m_nodeManager.newNode(ancestorAgain, 0x0, null);
							newAncestorNode.appendToAggregateDirtyFlags(previousNode.getAggregateDirtyFlags());
							
							previousNode = newAncestorNode;
							ancestorAgain = ancestorAgain.getParent();
						}
						
						m_nodeManager.moveToList(rootNode, qb2P_FlushNodeManager.CHILDREN);
						
						node.appendToAggregateDirtyFlags(previousNode.getAggregateDirtyFlags());
						
						break;
					}
					
					ancestor = ancestor.getParent();
				}
			}
		}
	}
}