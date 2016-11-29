package quickb2.physics.driving 
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarTerrainConfig extends Object
	{
		public var slidingSkidColor:uint = 0x000000;
		public var rollingSkidColor:uint = 0x000000;
		
		public var slidingSkidAlpha:Number = .6;
		public var rollingSkidAlpha:Number = .6;
		
		public var skidDuration:Number = 2;
		
		public var drawSlidingSkids:Boolean = true;
		public var drawRollingSkids:Boolean = false;
		
		protected override function copy_protected(otherConfig:qb2CarTerrainConfig):void
		{
			this.slidingSkidColor = otherConfig.slidingSkidColor;
			this.rollingSkidColor = otherConfig.rollingSkidColor;
			this.slidingSkidAlpha = otherConfig.slidingSkidAlpha;
			this.rollingSkidAlpha = otherConfig.rollingSkidAlpha;
			this.skidDuration	  = otherConfig.skidDuration;
			this.drawSlidingSkids = otherConfig.drawSlidingSkids;
			this.drawRollingSkids = otherConfig.drawRollingSkids;
		}
	}
}