package quickb2.physics.core.bridge 
{
	import quickb2.display.retained.qb2I_Actor;
	import quickb2.display.retained.qb2I_ActorContainer;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2ClosureConstructor;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.backend.qb2I_BackEndWorldRepresentation;
	import quickb2.physics.core.bridge.qb2P_ActorQueue;
	import quickb2.physics.core.bridge.qb2P_EventQueue;
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.events.qb2ContainerEvent;
	import quickb2.physics.core.events.qb2MassEvent;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.joints.qb2PU_JointBackDoor;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.prop.qb2PU_PhysicsProp;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2PU_TangBackDoor;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.qb2ObjectPool;
	import quickb2.utils.qb2ObjectPoolClosureDelegate;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2P_Flusher implements qb2PI_FlushTreeVisitor
	{
		private static const s_instance:qb2P_Flusher = new qb2P_Flusher();
		
		private var m_flushTree:qb2P_FlushTree;
		
		private var m_isFlushing:Boolean = false;
		
		private const m_eventQueue:qb2P_EventQueue = new qb2P_EventQueue();
		private const m_actorQueue:qb2P_ActorQueue = new qb2P_ActorQueue();
		
		private const m_massRebalanceList:Vector.<qb2A_TangibleObject> = new Vector.<qb2A_TangibleObject>();
		
		private const m_jointMakeQueue:Vector.<qb2Joint> = new Vector.<qb2Joint>();
		
		private const m_massChangeFlag:qb2MutablePropFlags = new qb2MutablePropFlags();
		
		private var m_enableBatching:Boolean = true;
		
		public function qb2P_Flusher()
		{
			m_flushTree = new qb2P_FlushTree(this);
			m_massChangeFlag.setBit(qb2S_PhysicsProps.MASS, true);
		}
		
		public function enableBatching(value:Boolean):void
		{
			m_enableBatching = value;
			
			if ( !value )
			{
				this.flush();
			}
		}
		
		public static function getInstance():qb2P_Flusher
		{
			return s_instance;
		}
		
		internal function getFlushTree():qb2P_FlushTree
		{
			return m_flushTree;
		}
		
		public function getDirtyFlags(object:qb2A_PhysicsObject):int
		{
			var node:qb2P_FlushNode = m_flushTree.getNode(object);
			
			if ( node == null )
			{
				return 0x0;
			}
			else
			{
				return node.getDirtyFlags();
			}
		}
		
		private function piggyBackBooleanChange(dirtyFlags:int, changeProperties:qb2PropFlags):int
		{
			if ( changeProperties.isBitSet(qb2S_PhysicsProps.IS_ACTIVE) )
			{
				//--- DRK > Bring along pretty much everything in the event of an isActive change.
				//---		NOTE that this is a little wasteful in the event that isActive got changed to false.
				//---		Only matters if isActive gets set to true and it was false.
				dirtyFlags |= qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED;
				dirtyFlags |= qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED;
			}
			
			if	( 	changeProperties.isBitSet(qb2S_PhysicsProps.CURVES_HAVE_ROUNDED_CAPS) ||
					changeProperties.isBitSet(qb2S_PhysicsProps.CURVES_HAVE_ROUNDED_CORNERS)
				)
			{
				//--- DRK > Bring along tessellation properties for curve-style changes.
				dirtyFlags |= qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED;
			}
			
			return dirtyFlags;
		}
		
		private function piggyBackNumericChange(dirtyFlags:int, changeProperties:qb2PropFlags):int
		{
			if (	changeProperties.isBitSet(qb2S_PhysicsProps.MASS) ||
					changeProperties.isBitSet(qb2S_PhysicsProps.DENSITY) ||
					changeProperties.isBitSet(qb2S_PhysicsProps.DENSITY_LENGTH_UNIT)
				)
			{
				//--- DRK > In order to bring along isActive, which may override mass properties for sub-rigid objects and keep them at zero.
				dirtyFlags |= qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED;
			}
			
			if ( changeProperties.isBitSet(qb2S_PhysicsProps.PIXELS_PER_METER) )
			{
				//--- DRK > Changing pixels per meter pretty much requires everything.
				dirtyFlags |= qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED;
				dirtyFlags |= qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED;
			}
			
			if (	changeProperties.isBitSet(qb2S_PhysicsProps.CURVE_TESSELLATION) ||
					changeProperties.isBitSet(qb2S_PhysicsProps.CURVE_POINT_COUNT) 	||
					changeProperties.isBitSet(qb2S_PhysicsProps.MAX_CURVE_TESSELLATION_POINTS)
				)
			{
				dirtyFlags |= qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED; // bring along curve style properties
			}
			
			if ( changeProperties.isBitSet(qb2S_PhysicsProps.JOINT_TYPE) )
			{
				dirtyFlags |= qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED;
				dirtyFlags |= qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED;
			}
			
			return dirtyFlags;
		}
		
		private function piggyBackObjectChange(dirtyFlags:int, changeProperties:qb2PropFlags):int
		{
			if	( changeProperties.isBitSet(qb2S_PhysicsProps.GEOMETRY) )
			{
				// bring along tessellation and curve style properties
				dirtyFlags |= qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED;
				dirtyFlags |= qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED;
			}
			
			if ( changeProperties.isBitSet(qb2S_PhysicsProps.GRAVITY) )
			{
				dirtyFlags |= qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED; // bring along gravity units and pixels per meter.
			}
			
			return dirtyFlags;
		}
		
		public function addDirtyObject(object:qb2A_PhysicsObject, dirtyFlags:int, changedProperties_copied_nullable:qb2PropFlags):void
		{
			if ( changedProperties_copied_nullable != null )
			{
				if ( (dirtyFlags & qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED) != 0 )
				{
					dirtyFlags |= piggyBackBooleanChange(dirtyFlags, changedProperties_copied_nullable);
				}
				
				if ( (dirtyFlags & qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED) != 0 )
				{
					dirtyFlags |= piggyBackNumericChange(dirtyFlags, changedProperties_copied_nullable);
				}
				
				if ( (dirtyFlags & qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED) != 0 )
				{
					dirtyFlags |= piggyBackObjectChange(dirtyFlags, changedProperties_copied_nullable);
				}
				
				if ( qb2PU_PhysicsProp.isCoordinatePropertySet(changedProperties_copied_nullable, qb2S_PhysicsProps.CENTER_OF_MASS, true) )
				{
					// bring along geometry to recalculate center of mass.
					dirtyFlags |= qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED;
					dirtyFlags |= qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED;
				}
			}
			
			if ( dirtyFlags == qb2PF_DirtyFlag.ADDED_TO_CONTAINER )
			{
				dirtyFlags |= qb2PF_DirtyFlag.NEEDS_MAKING;
			}
			if ( dirtyFlags == qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER )
			{
				dirtyFlags |= qb2PF_DirtyFlag.NEEDS_DESTROYING;
			}
			
			var node:qb2P_FlushNode = m_flushTree.getNode(object);
			var alreadyHadRootNode:Boolean = node != null ? m_flushTree.isRootNode(node) : false;
			
			m_flushTree.addToTree(object, dirtyFlags, changedProperties_copied_nullable);
			
			//--- TODO(DRK, DEP): Remove when the tree can properly batch with multiple levels.
			if ( !m_enableBatching )
			{
				this.flush();
			}
			else
			{
				if ( m_flushTree.getNodeCount(qb2P_FlushNodeManager.CHILDREN) > 0 )
				{
					this.flush();
				}
			}
		}
		
		internal function queueJointForMakeAttempt(joint:qb2Joint):void
		{
			m_jointMakeQueue.push(joint);
		}
		
		internal function addToMassRebalanceList(tang:qb2A_TangibleObject):void
		{
			var index:int = m_massRebalanceList.indexOf(tang);
			
			if ( index >= 0 )  return;
			
			m_massRebalanceList.push(tang);
		}
		
		public function flush():void
		{
			if ( m_isFlushing )  return;
			
			m_isFlushing = true;
			{
				m_flushTree.walk();
				
				var i:int;
				if ( m_massRebalanceList.length > 0 )
				{
					var listLength:int = m_massRebalanceList.length;
					for ( i = 0; i < listLength; i++ )
					{
						m_flushTree.addToTree(m_massRebalanceList[i], qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED, m_massChangeFlag);
						
						//--- DRK > I think theoretically it could be fine to do just one walk after all the changes are added
						//---		to the tree, but this way is just safer what with some bad assumptions probably sprinkled through
						//---		the flush code, that nested dirty nodes don't happen much in practice...this way shouldn't really be
						//---		any slower than doing one walk at the end anyway.
						m_flushTree.walk();
					}
					
					qb2_assert(m_massRebalanceList.length == listLength); // want to make sure nothing got recursively added to rebalance list.
					
					m_massRebalanceList.length = 0;
				}
				
				if ( m_jointMakeQueue.length > 0 )
				{
					for ( i = 0; i < m_jointMakeQueue.length; i++ )
					{
						if ( !m_flushTree.isDelayedWithDirtyFlag(m_jointMakeQueue[i], qb2PF_DirtyFlag.NEEDS_MAKING) )
						{
							qb2PU_JointBackDoor.markForMakeIfWarranted(m_jointMakeQueue[i]);
						}
					}
					m_jointMakeQueue.length = 0;
					
					m_flushTree.walk();
				}
				
				m_flushTree.flushWorlds();
			}
			m_isFlushing = false;
			
			//--- DRK > Have to process some stuff here so that the outside world can't change anything during the flush itself.
			//---		Using instance counters instead of function-local counters ensures that recursive calls to the flush
			//---		will still handle the physics events and actor additions/removals appropriately.
			m_actorQueue.process();
			m_eventQueue.process();
		}
		
		public function onFlushComplete(world:qb2World):void
		{
			var backEndWorld:qb2I_BackEndWorldRepresentation = world.getBackEndRepresentation() as qb2I_BackEndWorldRepresentation;
			
			backEndWorld.onFlushComplete();
		}
		
		public function onPreVisit(node_nullable:qb2P_FlushNode, object:qb2A_PhysicsObject, parentCollector_nullable:qb2P_FlushCollector, changeFlags_out:qb2MutablePropFlags):void
		{
			qb2PU_ContainerSubRoutines.handleWorldChange(m_eventQueue, object, node_nullable, parentCollector_nullable, changeFlags_out);
		}
		
		public function onVisit(node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector, parentCollector_nullable:qb2P_FlushCollector):void 
		{
			var object:qb2A_PhysicsObject = collector.getObject();
			
			qb2PU_MassSubRoutines.handleMassChange(m_eventQueue, object, node_nullable, collector, parentCollector_nullable);
			qb2PU_ContainerSubRoutines.handleContainerChange(m_eventQueue, object, node_nullable, collector.getWorld());
			
			handleActorChange(object, node_nullable, collector);
			
			m_eventQueue.pushPropEvent(object, collector.getChangedProps());
			
			qb2PU_BackEnd.flush(node_nullable, collector);
		}
		
		public function onPostVisit(object:qb2A_PhysicsObject, originalNodeDirtyFlags:int):void
		{
			if ( (originalNodeDirtyFlags & qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER) != 0 )
			{
				qb2PU_PhysicsObjectBackDoor.spliceFromSiblings(object);
			}
		}
		
		public function onShortDelayVisit(collector:qb2P_FlushCollector):void
		{
			qb2PU_BackEnd.flush(null, collector);
		}
		
		private function handleActorChange(object:qb2A_PhysicsObject, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):void
		{
			if ( node_nullable == null )  return;
			
			if ( node_nullable.hasDirtyFlag(qb2PF_DirtyFlag.ACTOR_CHANGED) )
			{
				var dirtyObjectActor:qb2I_Actor = object.getSelfComputedProp(qb2S_PhysicsProps.ACTOR);
				
				if ( dirtyObjectActor != null )
				{
					var oldDirtyObjectActorContainer:qb2I_ActorContainer = dirtyObjectActor.getActorParent();
					
					if ( oldDirtyObjectActorContainer != collector.actorContainer )
					{
						if ( oldDirtyObjectActorContainer != null )
						{
							m_actorQueue.pushRemoval(oldDirtyObjectActorContainer, dirtyObjectActor);
						}
					
						if ( collector.actorContainer != null )
						{
							m_actorQueue.pushAddition(collector.actorContainer, dirtyObjectActor);
						}
					}
				}
				
				node_nullable.clearDirtyFlag(qb2PF_DirtyFlag.ACTOR_CHANGED);
			}
		}
	}
}