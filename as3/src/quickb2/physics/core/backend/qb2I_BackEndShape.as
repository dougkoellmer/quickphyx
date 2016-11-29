package quickb2.physics.core.backend 
{
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.utils.prop.qb2PropMap;
	
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_BackEndShape extends qb2I_BackEndRigidBody
	{
		function draw(graphics:qb2I_Graphics2d, pixelsPerMeter:Number):void;
	}
}