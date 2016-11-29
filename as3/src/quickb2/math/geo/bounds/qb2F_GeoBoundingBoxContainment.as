package quickb2.math.geo.bounds 
{
	import quickb2.lang.foundation.qb2Flag;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2F_GeoBoundingBoxContainment extends qb2Flag
	{
		include "../../../lang/macros/QB2_FLAG";
		
		public function qb2F_GeoBoundingBoxContainment(bits:uint = 0)
		{
			super(bits);
		}
		
		public static const INSIDE:qb2F_GeoBoundingBoxContainment    = new qb2F_GeoBoundingBoxContainment();
		public static const TO_TOP:qb2F_GeoBoundingBoxContainment    = new qb2F_GeoBoundingBoxContainment();
		public static const TO_BOTTOM:qb2F_GeoBoundingBoxContainment = new qb2F_GeoBoundingBoxContainment();
		public static const TO_LEFT:qb2F_GeoBoundingBoxContainment   = new qb2F_GeoBoundingBoxContainment();
		public static const TO_RIGHT:qb2F_GeoBoundingBoxContainment  = new qb2F_GeoBoundingBoxContainment();
	}
}