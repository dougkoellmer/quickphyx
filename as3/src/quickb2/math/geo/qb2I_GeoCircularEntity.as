package quickb2.math.geo 
{
	import quickb2.event.qb2I_EventDispatcher;
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_GeoCircularEntity
	{
		function set(center_copied_nullable:qb2GeoPoint, radius:Number):void;
		function getCenter():qb2GeoPoint;
		function getRadius():Number;
		function setRadius(radius:Number):void;
	}
}