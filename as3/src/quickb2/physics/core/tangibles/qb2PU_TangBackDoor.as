package quickb2.physics.core.tangibles 
{
	import quickb2.event.qb2GlobalEventPool;
	import quickb2.event.qb2I_EventDispatcher;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.qb2TransformStack;
	import quickb2.physics.core.bridge.qb2P_RigidComponent;
	import quickb2.physics.core.events.qb2PropEvent;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.qb2A_PhysicsObject;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2PU_TangBackDoor extends qb2UtilityClass
	{
		public static const PRE_STEP_DISPATCHER:int = 0;
		public static const POST_STEP_DISPATCHER:int = 1;
		
		public static function incEffectiveMass(tang:qb2A_TangibleObject, delta:Number):void
		{
			tang.incActualMass(delta);
		}
		
		public static function getDesiredSleepState(tang:qb2A_TangibleObject):Boolean
		{
			return tang.m_desiredSleepState;
		}
		
		public static function incSurfaceArea(tang:qb2A_TangibleObject, delta:Number):void
		{
			tang.m_actualSurfaceArea += delta;
		}
		
		public static function getRigidComponent(tang:qb2A_TangibleObject):qb2P_RigidComponent
		{
			return tang.getRigidComponent();
		}
		
		public static function setJointList(tang:qb2A_TangibleObject, joint:qb2Joint):void
		{
			tang.m_jointList = joint;
		}
		
		public static function addStepDispatcher(world:qb2World, type:int, dispatcher:qb2I_EventDispatcher):void
		{
			world.addStepDispatcher(type, dispatcher);
		}
		
		public static function removeStepDispatcher(world:qb2World, type:int, dispatcher:qb2I_EventDispatcher):void
		{
			world.removeStepDispatcher(type, dispatcher);
		}
		
		public static function getTransformStack(world:qb2World):qb2TransformStack
		{
			return world.getTransformStack();
		}
		
		public static function setContactFilter(tang:qb2A_TangibleObject, filter:qb2ContactFilter):void
		{
			//tang.setContactFilter_internal(filter);
		}
		
		public static function spliceFromSiblings(container:qb2A_PhysicsObjectContainer, child:qb2A_PhysicsObject):void
		{
			container.spliceFromSiblings(child);
		}
		
		public static function getLagMass(tang:qb2A_TangibleObject):Number
		{
			return tang.getLagMass();
		}
		
		public static function dispatchPropChangeEvent(tang:qb2A_TangibleObject, prop:qb2PhysicsProp):void
		{
			if ( !tang.hasEventListener(qb2PropEvent.PROP_CHANGED) )  return;
			
			var event:qb2PropEvent = qb2GlobalEventPool.checkOut(qb2PropEvent.PROP_CHANGED);
			event.initWithChangedProp(prop);
			tang.dispatchEvent(event);
		}
	}
}