package quickb2.math.geo{
	/**
	 * ...
	 * @author ...
	 */
	public class qb2GeoIntersectionOptions 
	{
		public const tolerance:qb2GeoTolerance = new qb2GeoTolerance();;
		public var maxIntersections:int = 0;
		//public var granularity:qb2F_GeoIntersectionType = qb2F_GeoIntersectionType.ALL;
		public var generateEntities:Boolean = true;
		
		public static function getDefaultTolerance(options_nullable:qb2GeoIntersectionOptions):qb2GeoTolerance
		{
			return qb2GeoTolerance.getDefault(options_nullable == null ? null : options_nullable.tolerance);
		}
	}
}