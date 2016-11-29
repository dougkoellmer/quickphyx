package quickb2.physics.core.backend 
{
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.qb2A_PhysicsObject;
	
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_BackEndRepresentation
	{
		function getFloat(propertyEnum:qb2E_BackEndProp):Number;
		
		function syncVector(propertyEnum:qb2E_BackEndProp, vector_out:qb2GeoVector):void;
		
		function syncPoint(propertyEnum:qb2E_BackEndProp, point_out:qb2GeoPoint, pixelsPerMeter:Number):void;
		
		function getBoolean(propertyEnum:qb2E_BackEndProp):Boolean;
		
		function setProperties(propertyMap:qb2PropMap, changeFlags:qb2PropFlags, transform_nullable:qb2AffineMatrix, result_out:qb2BackEndResult):void;
		
		function onStepComplete():void;
	}
}