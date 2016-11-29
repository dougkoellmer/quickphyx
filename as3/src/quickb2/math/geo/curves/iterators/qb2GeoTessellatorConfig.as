package quickb2.math.geo.curves.iterators 
{
	/**
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2GeoTessellatorConfig extends Object
	{
		public var mode:qb2E_GeoTessellatorMode;
		public var targetSegmentLength:Number;
		public var targetPointCount:int;
		public var maxPointsPerCurvedSegment:int;
		public var minPointsPerCurvedSegment:int;
		public var repeatEndpointForClosedCurves:Boolean;
		public var pointOverlapTolerance:Number;
		
		public function qb2GeoTessellatorConfig()
		{
			setToDefaults();
		}
		
		public function setToDefaults():void
		{
			this.mode = qb2E_GeoTessellatorMode.getDefault();
			this.targetSegmentLength = 1;
			this.targetPointCount = 2;
			this.maxPointsPerCurvedSegment = int.MAX_VALUE;
			this.minPointsPerCurvedSegment = 2;
			this.repeatEndpointForClosedCurves = false;
			this.pointOverlapTolerance = 0;
		}
		
		public function copy(config:qb2GeoTessellatorConfig):void
		{
			this.mode = qb2E_GeoTessellatorMode.getDefault(config.mode);
			this.targetSegmentLength = config.targetSegmentLength;
			this.targetPointCount = config.targetPointCount;
			this.maxPointsPerCurvedSegment = config.maxPointsPerCurvedSegment;
			this.minPointsPerCurvedSegment = config.minPointsPerCurvedSegment;
			this.repeatEndpointForClosedCurves = config.repeatEndpointForClosedCurves;
			this.pointOverlapTolerance = config.pointOverlapTolerance;
		}
	}
}