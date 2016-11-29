package quickb2.math.geo 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2GeoTolerance extends Object
	{
		public static const EXACT:qb2GeoTolerance = new qb2GeoTolerance(0, 0, 0, 0);
		
		private static const DEFAULT_VALUE:Number = .00000001;
		
		public var equalPoint:Number = NaN;
		public var equalVector:Number = NaN;
		public var equalAngle:Number = NaN;
		public var equalComponent:Number = NaN;
		
		public function qb2GeoTolerance(equalPoint:Number = NaN, equalVector:Number = NaN, equalAngle:Number = NaN, equalComponent:Number = NaN) 
		{
			this.equalPoint = isNaN(equalPoint) ? DEFAULT_VALUE : equalPoint;
			this.equalVector = isNaN(equalVector) ? DEFAULT_VALUE : equalVector;
			this.equalAngle = isNaN(equalAngle) ? DEFAULT_VALUE : equalAngle;
			this.equalComponent = isNaN(equalComponent) ? DEFAULT_VALUE : equalComponent;
		}
		
		public static function getDefault(tolerance_nullable:qb2GeoTolerance = null):qb2GeoTolerance
		{
			return tolerance_nullable == null ? EXACT : tolerance_nullable
		}
		
		public function copy(otherTolerance:qb2GeoTolerance):void
		{
			this.equalPoint = otherTolerance.equalPoint;
			this.equalVector = otherTolerance.equalVector;
			this.equalAngle = otherTolerance.equalAngle;
			this.equalComponent = otherTolerance.equalComponent;
		}
	}
}