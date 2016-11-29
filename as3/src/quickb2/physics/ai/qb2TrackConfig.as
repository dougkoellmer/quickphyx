package quickb2.physics.ai 
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2TrackConfig 
	{		
		public var speedLimit:Number = 13.5;
		public var width:Number = 0.0;
		
		public function copy(otherConfig:qb2TrackConfig):void
		{
			this.speedLimit = otherConfig.speedLimit;
			this.width = otherConfig.width;
		}
	}
}