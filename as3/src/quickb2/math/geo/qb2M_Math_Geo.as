package quickb2.math.geo 
{
	import quickb2.lang.foundation.qb2ModuleClass;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2M_Math;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2M_Math_Geo extends qb2M_Math
	{
		public static function startUp():void
		{
			qb2M_Math.startUp();
			qb2A_GeoEntity.s_matrix = new qb2AffineMatrix();
		}
		
		public static function shutDown():void
		{
			qb2A_GeoEntity.s_matrix = null;
			qb2M_Math.shutDown();
		}
	}
}