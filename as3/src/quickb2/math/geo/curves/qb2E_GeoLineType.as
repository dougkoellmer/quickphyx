package quickb2.math.geo.curves 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_GeoLineType extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const SEGMENT:qb2E_GeoLineType  = new qb2E_GeoLineType();
		public static const RAY:qb2E_GeoLineType      = new qb2E_GeoLineType();
		public static const INFINITE:qb2E_GeoLineType = new qb2E_GeoLineType();
	}
}