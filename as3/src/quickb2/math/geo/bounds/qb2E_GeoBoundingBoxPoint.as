package quickb2.math.geo.bounds 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_GeoBoundingBoxPoint extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const CENTER:qb2E_GeoBoundingBoxPoint				= new qb2E_GeoBoundingBoxPoint();
		public static const TOP_LEFT:qb2E_GeoBoundingBoxPoint			= new qb2E_GeoBoundingBoxPoint();
		public static const TOP_CENTER:qb2E_GeoBoundingBoxPoint      	= new qb2E_GeoBoundingBoxPoint();
		public static const TOP_RIGHT:qb2E_GeoBoundingBoxPoint			= new qb2E_GeoBoundingBoxPoint();
		public static const RIGHT_CENTER:qb2E_GeoBoundingBoxPoint		= new qb2E_GeoBoundingBoxPoint();
		public static const BOTTOM_RIGHT:qb2E_GeoBoundingBoxPoint		= new qb2E_GeoBoundingBoxPoint();
		public static const BOTTOM_CENTER:qb2E_GeoBoundingBoxPoint		= new qb2E_GeoBoundingBoxPoint();
		public static const BOTTOM_LEFT:qb2E_GeoBoundingBoxPoint		= new qb2E_GeoBoundingBoxPoint();
		public static const LEFT_CENTER:qb2E_GeoBoundingBoxPoint		= new qb2E_GeoBoundingBoxPoint();
	}
}