package quickb2.physics.core.bridge 
{
	import quickb2.physics.core.prop.*;
	import quickb2.lang.foundation.qb2PrivateUtilityClass;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.surfaces.qb2A_GeoSurface;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2U_Formula;
	import quickb2.physics.core.backend.qb2BackEndResult;
	import quickb2.physics.core.backend.qb2E_BackEndResult;
	import quickb2.physics.core.backend.qb2I_BackEndCallbacks;
	import quickb2.physics.core.backend.qb2I_BackEndJoint;
	import quickb2.physics.core.backend.qb2I_BackEndWorldRepresentation;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.backend.qb2I_BackEndRigidBody;
	import quickb2.physics.core.backend.qb2I_BackEndShape;
	import quickb2.physics.core.iterators.qb2AttachedJointIterator;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.qb2A_SimulatedPhysicsObject;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.core.tangibles.qb2PU_TangBackDoor;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2PU_BackEnd extends qb2PrivateUtilityClass
	{
		private static const s_utilPropertyFlags:qb2MutablePropFlags = new qb2MutablePropFlags();
		private static const s_jointIterator:qb2AttachedJointIterator = new qb2AttachedJointIterator();
		private static const s_result:qb2BackEndResult = new qb2BackEndResult();
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		
		private static function updateJointAnchors(tang:qb2A_TangibleObject, transform:qb2AffineMatrix):void
		{
			s_jointIterator.initialize(tang);
			for ( var joint:qb2Joint; (joint = s_jointIterator.next()) != null; )
			{
				var representation:qb2I_BackEndJoint = (joint.getBackEndRepresentation() as qb2I_BackEndJoint);
				
				if ( representation != null )
				{
					if ( joint.getObjectA() == tang )
					{
						joint.getEffectiveProp(qb2S_PhysicsProps.ANCHOR_A, s_utilPoint1);
						representation.setJointAnchor(qb2S_PhysicsProps.ANCHOR_A, transform, s_utilPoint1);
					}
					else
					{
						joint.getEffectiveProp(qb2S_PhysicsProps.ANCHOR_B, s_utilPoint1);
						representation.setJointAnchor(qb2S_PhysicsProps.ANCHOR_B, transform, s_utilPoint1);
					}
				}
			}
		}
		
		private static function queueJointsForMake(tang:qb2A_TangibleObject):void
		{
			var jointList:qb2Joint = tang.getJointList();
			while (jointList != null )
			{
				var jointRep:qb2I_BackEndJoint = jointList.getBackEndRepresentation() as qb2I_BackEndJoint;
				
				if ( jointRep == null || !jointRep.isSimulating() )
				{
					qb2P_Flusher.getInstance().queueJointForMakeAttempt(jointList);
				}
				
				jointList = jointList.getNextJoint(tang);
			}
		}
		
		private static function destroyJointsIfNecessary(tang:qb2A_TangibleObject):void
		{
			var jointList:qb2Joint = tang.getJointList();
			while (jointList != null )
			{
				var jointRep:qb2I_BackEndJoint = jointList.getBackEndRepresentation() as qb2I_BackEndJoint;
				
				if ( jointRep != null )
				{
					jointRep.onAttachmentRemoved();
				}
				
				jointList = jointList.getNextJoint(tang);
			}
		}
		
		private static function hasNodeAnyDirtyFlag(node_nullable:qb2P_FlushNode, flags:int):Boolean
		{
			if ( node_nullable != null )
			{
				return node_nullable.hasAnyDirtyFlag(flags);
			}
			
			return false;
		}
		
		private static function delay(collector:qb2P_FlushCollector, dirtyFlags:int, type:qb2PE_FlushDelay):void
		{
			qb2P_Flusher.getInstance().getFlushTree().delay(collector, dirtyFlags, type);
		}
		
		private static function clearNodeFlags(node_nullable:qb2P_FlushNode, flags:int):void
		{
			if ( node_nullable != null )
			{
				node_nullable.clearDirtyFlag(flags);
			}
		}
		
		private static function tryToDestroy(backEnd:qb2I_BackEndWorldRepresentation, simulatedObject:qb2A_SimulatedPhysicsObject, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):void
		{
			//--- Destroy object if need be and if possible.
			var needsDestroying:Boolean = collector.hasDirtyFlag(qb2PF_DirtyFlag.NEEDS_DESTROYING);
			
			if( needsDestroying && simulatedObject.getBackEndRepresentation() != null )
			{
				backEnd.destroyRepresentation(simulatedObject.getBackEndRepresentation());
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.FLAGS_TO_CLEAR_ON_MAKE_OR_DESTROY);
				qb2PU_PhysicsObjectBackDoor.setBackEndRepresentation(simulatedObject, null);
				
				var asTangible:qb2A_TangibleObject = simulatedObject as qb2A_TangibleObject;
				if ( asTangible != null )
				{
					destroyJointsIfNecessary(asTangible);
				}
			}
		}
		
		private static function tryToMake(backEnd:qb2I_BackEndWorldRepresentation, simulatedObject:qb2A_SimulatedPhysicsObject, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):Boolean
		{
			var made:Boolean = false;
			
			//--- Make object if need be and if possible.
			var needsMaking:Boolean = collector.hasDirtyFlag(qb2PF_DirtyFlag.NEEDS_MAKING);
			if ( needsMaking )
			{
				if ( simulatedObject.getBackEndRepresentation() != null )
				{
					qb2_assert(false);
					
					return false;
				}
				
				var backEndRep:qb2I_BackEndRepresentation = backEnd.makeRepresentation(simulatedObject, collector.rotationStack, collector.transform, collector.propertyMap, s_result);
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.FLAGS_TO_CLEAR_ON_MAKE_OR_DESTROY);
				qb2PU_PhysicsObjectBackDoor.setBackEndRepresentation(simulatedObject, backEndRep);
				
				var asTangible:qb2A_TangibleObject = simulatedObject as qb2A_TangibleObject;
				if ( asTangible != null )
				{
					queueJointsForMake(asTangible);
				}
				
				if ( s_result.getResult() == qb2E_BackEndResult.TRY_AGAIN_SOON )
				{
					delay(collector, 0x0, qb2PE_FlushDelay.SHORT);
				}
				else if ( s_result.getResult() == qb2E_BackEndResult.TRY_AGAIN_LATER )
				{
					delay(collector, qb2PF_DirtyFlag.NEEDS_MAKING, qb2PE_FlushDelay.LONG);
				}
				
				made = true;
			}
			
			return made;
		}
		
		private static function updateGeometry(backEnd:qb2I_BackEndWorldRepresentation, rigidRep:qb2I_BackEndRigidBody, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):Boolean
		{
			if ( !qb2U_Type.isKindOf(collector.getObject(), qb2Shape) )  return false;
			
			var handled:Boolean = false;
			
			if ( collector.getChangedProps().isBitSet(qb2S_PhysicsProps.GEOMETRY) )
			{				
				if ( collector.getObject().getAncestorBody() != null )
				{
					rigidRep.setProperties(collector.propertyMap, collector.getChangedProps(), collector.transform, s_result);
				}
				else
				{
					rigidRep.setProperties(collector.propertyMap, collector.getChangedProps(), null, s_result);
				}
				
				handled = true;
				
				//--- DRK > This is an attached shape, so the transform was implicitly handled as part of the geometry change, so we can clear both.
				//--- DRK > NOTE: Because both geometry and rigid transform changes flush immediately in order to fire mass change events predictably,
				//---		I don't think the below logic for clearing rigid transform even really matters...it's probably still good to be here just in case.
				//---		LATER NOTE: Considering that geometry and transform can perhaps be changed at the same time through use of style sheets, the above NOTE
				//---					might now be a little more relevant.
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED);
			
				if ( s_result.getResult() == qb2E_BackEndResult.SUCCESS )
				{
					//--- DRK > This is just to let the rigid transform sub-routine know that everything's taken care of.
					collector.clearDirtyFlag(qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED);
				}
				else
				{
					delay(collector, qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED, qb2PE_FlushDelay.LONG);
				}
			}
			
			return handled;
		}
		
		private static function updateRigidTransform(backEnd:qb2I_BackEndWorldRepresentation, rigidRep:qb2I_BackEndRigidBody, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):void
		{
			if ( collector.hasDirtyFlag(qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED) )
			{
				if ( collector.getObject().getAncestorBody() != null )
				{
					(rigidRep).updateTransform(collector.transform, collector.rotationStack, collector.m_pixelsPerMeter, s_result);
				}
				else
				{
					qb2_assert(false);
				}
				
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED);
				
				if ( s_result.getResult() == qb2E_BackEndResult.TRY_AGAIN_LATER )
				{
					collector.clearDirtyFlag(qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED);
					delay(collector, qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED, qb2PE_FlushDelay.LONG);
				}
			}
		}
		
		private static function updateWorldTransform(backEnd:qb2I_BackEndWorldRepresentation, rigidRep:qb2I_BackEndRigidBody, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):void
		{
			if ( collector.hasDirtyFlag(qb2PF_DirtyFlag.WORLD_TRANSFORM_CHANGED) )
			{
				(rigidRep as qb2I_BackEndRigidBody).updateTransform(collector.transform, collector.rotationStack, collector.m_pixelsPerMeter, s_result);
				
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.WORLD_TRANSFORM_CHANGED);
				
				if ( s_result.getResult() == qb2E_BackEndResult.TRY_AGAIN_LATER )
				{
					delay(collector, qb2PF_DirtyFlag.WORLD_TRANSFORM_CHANGED, qb2PE_FlushDelay.LONG);
				}
				
				//--- DRK > Here we're not trickling down transform changes past the top of a rigid hierarchy.
				collector.clearDirtyFlag(qb2PF_DirtyFlag.WORLD_TRANSFORM_CHANGED);
			}
		}
		
		private static function updateVelocities(backEnd:qb2I_BackEndWorldRepresentation, rigid:qb2I_RigidObject, rigidRep:qb2I_BackEndRigidBody, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):void
		{
			if ( collector.hasDirtyFlag(qb2PF_DirtyFlag.VELOCITIES_CHANGED) )
			{
				rigidRep.updateVelocities(rigid.getLinearVelocity(), rigid.getAngularVelocity(), collector.rotationStack, collector.m_pixelsPerMeter);
				
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.VELOCITIES_CHANGED);
				
				//--- DRK > No need to ever trickle velocity changes further down the tree.
				collector.clearDirtyFlag(qb2PF_DirtyFlag.VELOCITIES_CHANGED);
			}
		}
		
		private static function updateSleepState(backEnd:qb2I_BackEndWorldRepresentation, rigidComponent:qb2P_RigidComponent, rigidRep:qb2I_BackEndRigidBody, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):void
		{
			if ( collector.hasDirtyFlag(qb2PF_DirtyFlag.SLEEP_STATE_CHANGED) )
			{
				var asTangible:qb2A_TangibleObject = collector.getObject() as qb2A_TangibleObject;
				
				var isSleeping:Boolean = qb2PU_TangBackDoor.getDesiredSleepState(asTangible);
				
				rigidRep.setIsSleeping(isSleeping);
				
				rigidComponent.syncVelocities(0);
				
				collector.clearDirtyFlag(qb2PF_DirtyFlag.SLEEP_STATE_CHANGED);
				
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.SLEEP_STATE_CHANGED);
			}
		}
		
		private static function updateProperties(backEndRep:qb2I_BackEndRepresentation, collector:qb2P_FlushCollector, node_nullable:qb2P_FlushNode, object:qb2A_PhysicsObject):void
		{
			if ( collector.hasDirtyFlag(qb2PF_DirtyFlag.PROPERTY_CHANGED) )
			{
				var asShape:qb2Shape = object as qb2Shape;
				var changedProperties:qb2PropFlags = collector.getChangedProps();
				
				if ( asShape != null )
				{
					//--- DRK > HACK: This kind of assumes a certain way that the back end handles isActive. With Box2d, it's wasteful to send the
					//---				isActive-changed imperitive down past the top of a rigid root.
					
					if ( asShape.getAncestorBody() == asShape.getParent() )
					{
						if ( changedProperties.isBitSet(qb2S_PhysicsProps.IS_ACTIVE) )
						{
							if ( node_nullable == null || node_nullable != null && !node_nullable.getChangedProperties().isBitSet(qb2S_PhysicsProps.IS_ACTIVE) )
							{
								s_utilPropertyFlags.copy(changedProperties);
								s_utilPropertyFlags.setBit(qb2S_PhysicsProps.IS_ACTIVE, false);
								changedProperties = s_utilPropertyFlags;
							}
						}
					}
				}
				
				backEndRep.setProperties(collector.propertyMap, changedProperties, null, s_result);
				
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.PROPERTY_CHANGED);
				
				if ( s_result.getResult() == qb2E_BackEndResult.TRY_AGAIN_LATER )
				{
					delay(collector, qb2PF_DirtyFlag.PROPERTY_CHANGED, qb2PE_FlushDelay.LONG);
				}
			}
		}
		
		public static function flush(node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector):void
		{
			var object:qb2A_PhysicsObject = collector.getObject();
			var world:qb2World = collector.getWorld();
			
			if ( object == world )
			{
				updateProperties(world.getBackEndRepresentation(), collector, node_nullable, object);
				
				return;
			}
			
			var asSimulated:qb2A_SimulatedPhysicsObject = object as qb2A_SimulatedPhysicsObject;
			var isRepresentable:Boolean = qb2PU_PhysicsObjectBackDoor.isBackEndRepresentable(object);
			
			if ( world == null || !isRepresentable )
			{
				clearNodeFlags(node_nullable, qb2PF_DirtyFlag.FLAGS_TO_CLEAR_ON_NO_BACK_END_REQUIRED);
				
				return;
			}
			
			//--- DRK > HACK: if it looks like the isActive imperitive is coming from a rigid-root or higher,
			//---		then it's not necessary to trickle it down further.
			if ( object.getParent() == object.getAncestorBody() )
			{
				if ( collector.propertyMap.getProperty(qb2S_PhysicsProps.IS_ACTIVE) != null )
				if ( object.getSelfComputedProp(qb2S_PhysicsProps.IS_ACTIVE) == null )
				{
					collector.propertyMap.setProperty(qb2S_PhysicsProps.IS_ACTIVE, null);
				}
			}
			
			var transform:qb2AffineMatrix = collector.transform;
			var rotationStack:Number = collector.rotationStack;
			
			var backEnd:qb2I_BackEndWorldRepresentation = world.getBackEndRepresentation() as qb2I_BackEndWorldRepresentation;
			tryToDestroy(backEnd, asSimulated, node_nullable, collector);
			var justMadeBackEndRep:Boolean = tryToMake(backEnd, asSimulated, node_nullable, collector);
			
			//--- DRK > The making of a back end rep means that that rep is all up-to-date.  If we didn't just make it, then we have 
			//---		to make sure that the geometry, properties, transforms, etc., are synced up.
			if ( !justMadeBackEndRep )
			{
				var backEndRep:qb2I_BackEndRepresentation = asSimulated.getBackEndRepresentation();
				
				if ( backEndRep != null )
				{
					var asTangible:qb2A_TangibleObject = object as qb2A_TangibleObject;
					var geometryChanged:Boolean = false;
					if ( asTangible != null )
					{
						var rigidRep:qb2I_BackEndRigidBody = backEndRep as qb2I_BackEndRigidBody;
						var asRigid:qb2I_RigidObject = asTangible as qb2I_RigidObject;
						var rigidComponent:qb2P_RigidComponent = qb2PU_TangBackDoor.getRigidComponent(asTangible);
						var jointAnchorsNeedUpdating:Boolean = collector.hasDirtyFlag(qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED);
						
						geometryChanged = updateGeometry(backEnd, rigidRep, node_nullable, collector);
						updateRigidTransform(backEnd, rigidRep, node_nullable, collector);
						updateWorldTransform(backEnd, rigidRep, node_nullable, collector);
						updateVelocities(backEnd, asRigid, rigidRep, node_nullable, collector);
						updateSleepState(backEnd, rigidComponent, rigidRep, node_nullable, collector);
						
						if ( jointAnchorsNeedUpdating )
						{
							updateJointAnchors(asTangible, transform);
						}
					}
					
					if ( !geometryChanged )
					{
						updateProperties(backEndRep, collector, node_nullable, object);
					}
				}
			}
		}
	}
}