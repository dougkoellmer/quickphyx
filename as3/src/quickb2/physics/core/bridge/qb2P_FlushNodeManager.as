package quickb2.physics.core.bridge 
{
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2ClosureConstructor;
	import quickb2.physics.core.bridge.qb2P_FlushNode;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.qb2ObjectPool;
	import quickb2.utils.qb2ObjectPoolClosureDelegate;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2P_FlushNodeManager
	{
		private static const DELAYED_NODE_INDEX_START:int = int.MAX_VALUE / 2;
		
		internal static const ROOTS:int = 0;
		internal static const CHILDREN:int = 1;
		internal static const LONG_DELAYED:int = 2;
		
		private const m_utilInt:qb2Integer = new qb2Integer();
		
		private const m_lists:Vector.<Vector.<qb2P_FlushNode>> = new Vector.<Vector.<qb2P_FlushNode>> (3, true);
		
		private var m_totalNodeCount:int = 0;
		
		private const m_nodeCounts:Vector.<int> = new Vector.<int> (3, true);
		
		
		private const m_nodePool:qb2ObjectPool = new qb2ObjectPool
		(
			new qb2ClosureConstructor(function():qb2P_FlushNode
			{
				return new qb2P_FlushNode();
			}),
			new qb2ObjectPoolClosureDelegate(function(node:qb2P_FlushNode):void
			{
				//TODO: Somehow only call clean for destruction....will probably have to modify pool API.
				node.clean();
			})
		);
		
		public function qb2P_FlushNodeManager() 
		{
			for ( var i:int = 0; i < m_lists.length; i++ )
			{
				m_lists[i] = new Vector.<qb2P_FlushNode>();
			}
		}
		
		internal function isRootNode(node:qb2P_FlushNode):Boolean
		{
			return this.getNodeListForObject(node.getObject(), m_utilInt) == m_lists[ROOTS];
		}
		
		internal function isDelayedNode(node:qb2P_FlushNode):Boolean
		{
			return this.getNodeListForObject(node.getObject(), m_utilInt) == m_lists[LONG_DELAYED];
		}
		
		internal function garbageCollect():void
		{
			if ( m_totalNodeCount > 0 )  return;
			
			for ( var i:int = 0; i < m_lists.length; i++ )
			{
				m_lists[i].length = 0;
			}
		}
		
		internal function moveToList(node:qb2P_FlushNode, list:int):void
		{
			var currentList:Vector.<qb2P_FlushNode> = getNodeListForObject(node.getObject(), m_utilInt);
			
			if ( currentList != null )
			{				
				currentList[m_utilInt.value] = null;
				m_nodeCounts[m_utilInt.value]--;
			}
			
			var newList:Vector.<qb2P_FlushNode> = m_lists[list];
			m_nodeCounts[list]++;
			
			if ( currentList == newList )
			{
				qb2_assert(false, "DRK > Just interested if any case makes it here...not necessarily bad.");
				
				return;
			}
				
			var flushId:int;
			
			if ( list == ROOTS )
			{
				flushId = newList.length + 1;
			}
			else if ( list == CHILDREN )
			{
				flushId = -(newList.length + 1)
			}
			else if ( list == LONG_DELAYED )
			{
				flushId = newList.length + DELAYED_NODE_INDEX_START;
			}
			
			newList.push(node);
				
			qb2PU_PhysicsObjectBackDoor.setFlushId(node.getObject(), flushId);
		}
		
		public function getNodeCount(list:int):int
		{
			return m_nodeCounts[list];
		}
		
		internal function deleteNode(node:qb2P_FlushNode):void
		{
			m_totalNodeCount--;
			
			var nodeList:Vector.<qb2P_FlushNode> = getNodeListForObject(node.getObject(), m_utilInt);
			
			if ( nodeList == null )
			{
				qb2_assert(false);
				
				return;
			}
		
			var node:qb2P_FlushNode = nodeList[m_utilInt.value];
			m_nodeCounts[m_utilInt.value]--;
			
			nodeList[m_utilInt.value] = null;
			
			qb2PU_PhysicsObjectBackDoor.setFlushId(node.getObject(), 0);
			
			m_nodePool.checkIn(node);
		}
		
		internal function newNode(object:qb2A_PhysicsObject, dirtyFlags:int, changedProperties_nullable:qb2PropFlags):qb2P_FlushNode
		{
			var newNode:qb2P_FlushNode = m_nodePool.checkOut();
			newNode.initialize(object);
			newNode.appendDirtyFlags(dirtyFlags, changedProperties_nullable);
			
			m_totalNodeCount++;
			
			return newNode;
		}
		
		public function getNode(object:qb2A_PhysicsObject):qb2P_FlushNode
		{
			var nodeList:Vector.<qb2P_FlushNode> = getNodeListForObject(object, m_utilInt);
			
			if ( nodeList != null )
			{
				return nodeList[m_utilInt.value];
			}
			
			return null;
		}
		
		internal function getNodeList(list:int):Vector.<qb2P_FlushNode>
		{
			return m_lists[list];
		}
		
		internal function getNodeListForObject(object:qb2A_PhysicsObject, index_out:qb2Integer):Vector.<qb2P_FlushNode>
		{
			var flushId:int = qb2PU_PhysicsObjectBackDoor.getFlushId(object);
			
			if ( flushId == 0 )
			{
				return null;
			}
			
			if ( flushId < 0 )
			{
				index_out.value = Math.abs(flushId) - 1;
				
				return m_lists[CHILDREN];
			}
			
			if ( flushId > 0 )
			{
				if ( flushId >= DELAYED_NODE_INDEX_START )
				{
					index_out.value = flushId - DELAYED_NODE_INDEX_START;
					
					return m_lists[LONG_DELAYED];
				}
				else
				{
					index_out.value = flushId - 1;
					
					return m_lists[ROOTS];
				}
			}
			
			return null;
		}
	}
}