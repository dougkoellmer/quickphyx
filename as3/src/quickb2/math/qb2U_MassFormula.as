package quickb2.math 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_MassFormula extends qb2UtilityClass
	{
		public static function parallelAxisTheorem(centerOfMassIntertia:Number, mass:Number, distanceSquared:Number):Number
		{
			return centerOfMassIntertia + mass * distanceSquared;
		}
		
		public static function parallelAxisTheoremInverse(axisInertia:Number, mass:Number, distanceSquared:Number):Number
		{
			return axisInertia - mass * distanceSquared;
		}
	}
}