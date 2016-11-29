package quickb2.physics.core.backend 
{
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_BackEndRigidBody extends qb2I_BackEndRepresentation
	{
		function updateTransform(transform_nullable:qb2AffineMatrix, rotationStack:Number, pixelsPerMeter:Number, result_out:qb2BackEndResult):void;
		
		function updateVelocities(linear:qb2GeoVector, angular:Number, rotationStack:Number, pixelsPerMeter:Number):void;
		
		function setIsSleeping(value:Boolean):void;
	}
}