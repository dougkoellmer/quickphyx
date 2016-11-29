package quickb2.math.geo.surfaces.planar 
{
	import quickb2.lang.foundation.qb2Flag;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2F_GeoPolygonType extends qb2Flag
	{
		include "../../../../lang/macros/QB2_FLAG";
		
		public function qb2F_GeoPolygonType(bits:uint = 0)
		{
			super(bits);
		}
		
		public static const IS_CONVEX:qb2F_GeoPolygonType 				= new qb2F_GeoPolygonType();
		public static const IS_CONCAVE:qb2F_GeoPolygonType 				= new qb2F_GeoPolygonType();
		public static const IS_CLOCKWISE:qb2F_GeoPolygonType 			= new qb2F_GeoPolygonType();
		public static const IS_COUNTER_CLOCKWISE:qb2F_GeoPolygonType 	= new qb2F_GeoPolygonType();
	}
}