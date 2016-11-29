package quickb2.math.geo.curves 
{
	import quickb2.lang.foundation.qb2Flag;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2F_GeoCurveType extends qb2Flag
	{
		include "../../../lang/macros/QB2_FLAG";
		
		public function qb2F_GeoCurveType(bits:uint = 0)
		{
			super(bits);
		}
		
		public static const IS_CLOSED:qb2F_GeoCurveType 				= new qb2F_GeoCurveType();
		public static const IS_TESSELLATED:qb2F_GeoCurveType			= new qb2F_GeoCurveType();
		public static const IS_BOUNDED:qb2F_GeoCurveType				= new qb2F_GeoCurveType();
	}
}