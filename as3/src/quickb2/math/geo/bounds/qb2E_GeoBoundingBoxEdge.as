package quickb2.math.geo.bounds 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_GeoBoundingBoxEdge extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const TOP:qb2E_GeoBoundingBoxEdge			= new qb2E_GeoBoundingBoxEdge();
		public static const RIGHT:qb2E_GeoBoundingBoxEdge      	= new qb2E_GeoBoundingBoxEdge();
		public static const BOTTOM:qb2E_GeoBoundingBoxEdge		= new qb2E_GeoBoundingBoxEdge();
		public static const LEFT:qb2E_GeoBoundingBoxEdge		= new qb2E_GeoBoundingBoxEdge();
	}
}