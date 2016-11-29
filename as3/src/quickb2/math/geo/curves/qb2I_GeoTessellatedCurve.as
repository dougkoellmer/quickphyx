package quickb2.math.geo.curves 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_GeoTessellatedCurve
	{
		function getPointAt(index:int):qb2GeoPoint;
		
		function getPointCount():int;
	}
}