package quickb2.math.geo 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_GeoIntersectionFlags extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const CURVE_TO_POINT:uint     = 0x00000001;
		public static const CURVE_TO_CURVE:uint     = 0x00000002;
		public static const CURVE_TO_SURFACE:uint   = 0x00000004;
		public static const SURFACE_TO_SURFACE:uint = 0x00000008;
	}
}