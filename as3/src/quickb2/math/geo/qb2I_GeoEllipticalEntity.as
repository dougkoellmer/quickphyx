package quickb2.math.geo 
{
	import quickb2.event.qb2I_EventDispatcher;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	
	/**
	 * ...
	 * @author 
	 */
	
	public interface qb2I_GeoEllipticalEntity
	{
		function set(sourceCenter:qb2GeoPoint, sourceMajorAxis:qb2GeoVector, sourceMinorAxis:Number):void;
		function getCenter():qb2GeoPoint;
		function getMajorAxis():qb2GeoVector;
		function setMinorAxis(minorAxis:Number):void;
		function getMinorAxis():Number;
	}
}