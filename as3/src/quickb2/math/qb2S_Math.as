package quickb2.math 
{
	import quickb2.lang.foundation.qb2SettingsClass;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	/**
	 * ...
	 * @author 
	 */
	public class qb2S_Math extends qb2SettingsClass
	{
		public static const PI:Number = Math.PI;
		public static const TAU:Number = PI * 2.0;
		
		public static const RADIANS_360:Number = TAU;
		public static const RADIANS_270:Number = PI * 1.5
		public static const RADIANS_180:Number = PI;
		public static const RADIANS_90:Number = PI / 2;
		public static const RADIANS_45:Number = PI / 4;
		public static const RADIANS_30:Number = PI / 6;
		public static const RADIANS_0:Number = 0;
		
		public static var FLIPPED_Y:Boolean = true;
		
		public static const IDENTITY_MATRIX:qb2AffineMatrix = new qb2AffineMatrix();
		
		{
			IDENTITY_MATRIX.setToIdentity();
		}
		
		public static const X_AXIS:qb2GeoVector = new qb2GeoVector(1, 0);
		public static const Y_AXIS:qb2GeoVector = new qb2GeoVector(0, 1);
		public static const ORIGIN:qb2GeoPoint = new qb2GeoPoint(0, 1);
	}
}