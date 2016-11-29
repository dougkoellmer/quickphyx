package quickb2.math.geo.curves.iterators 
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2GeoSamplePointIteratorConfig extends Object
	{
		public var pointCount:int;
		public var startParam:Number = 0.0;
		public var endParam:Number = 1.0;
		
		public function qb2GeoSamplePointIteratorConfig()
		{
			
		}
		
		public function setToDefaults():void
		{
			pointCount = 2;
			startParam = 0;
			endParam = 1;
		}
		
		public function copy(otherConfig:qb2GeoSamplePointIteratorConfig):void
		{
			this.pointCount = otherConfig.pointCount;
			this.startParam = otherConfig.startParam;
			this.endParam = otherConfig.endParam;
		}
	}
}