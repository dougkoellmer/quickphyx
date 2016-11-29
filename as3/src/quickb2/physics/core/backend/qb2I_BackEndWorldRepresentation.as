package quickb2.physics.core.backend 
{
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.qb2A_SimulatedPhysicsObject;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.prop.qb2PropMap;
	
	/**
	 * Implement this interface to provide the actual back-end physics that will drive the front-end.
	 * 
	 * It is expected that this interface will have to be adjusted to fit the needs/design of other physics engines in the future.
	 * 
	 * @author Doug Koellmer
	 */
	public interface qb2I_BackEndWorldRepresentation extends qb2I_BackEndRepresentation
	{
		/**
		 * Perform any one-time initialization for engine start-up.
		 */
		function startUp(world:qb2World, callbacks:qb2I_BackEndCallbacks):void;
		
		/**
		 * Perform application shut-down steps.
		 */
		function shutDown():void;
		
		/**
		 * Advance the physics world by the specified time-step.
		 * 
		 * @param	timeStep
		 * @param	positionIterations
		 * @param	velocityIterations
		 */
		function step(timeStep:Number, positionIterations:int, velocityIterations:int):void;		
		
		function getErrorDuringLastStep():Error;
		
		function makeRepresentation(object:qb2A_SimulatedPhysicsObject, rotationStack:Number, transform:qb2AffineMatrix, propertyMap:qb2PropMap, result:qb2BackEndResult):qb2I_BackEndRepresentation;
		
		function destroyRepresentation(backEndRepresentation:qb2I_BackEndRepresentation):void;
		
		function onFlushComplete():void;
	}
}