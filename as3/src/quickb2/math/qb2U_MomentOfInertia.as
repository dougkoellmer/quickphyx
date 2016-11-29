package quickb2.math 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_MomentOfInertia extends qb2UtilityClass
	{
		public static function circularDisk(mass:Number, radius:Number):Number
		{
			return (mass * (radius * radius)) / 2;
		}
		
		public static function flatRing(mass:Number, innerRadius:Number, outerRadius:Number):Number
		{
			return .5 * mass * (innerRadius * innerRadius + outerRadius * outerRadius);
		}
		
		public static function circle(mass:Number, radius:Number):Number
		{
			return (mass * (radius * radius));
		}
		
		public static function line(mass:Number, lengthSquared:Number):Number
		{
			return (mass * lengthSquared) / 12;
		}
		
		public static function point(mass:Number, distanceFromAxisSquared:Number):Number
		{
			return mass * distanceFromAxisSquared;
		}
		
		public static function rectangle(mass:Number, width:Number, height:Number):Number
		{
			return (mass * (height * height + width * width)) / 12;
		}
		
		public static function sphere(mass:Number, radius:Number):Number
		{
			return (2 * mass * (radius * radius)) / 5;
		}
		
		public static function ellipticalDisk(mass:Number, aRadiusSquared:Number, bRadiusSquared:Number):Number
		{
			return mass * ((aRadiusSquared + bRadiusSquared) / 5);
		}
	}
}