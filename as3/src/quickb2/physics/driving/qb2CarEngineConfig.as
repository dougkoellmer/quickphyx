package quickb2.physics.driving 
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarEngineConfig extends Object
	{
		public var constrainRpm:Boolean = true;
		public var cancelThrottleWhenShifting:Boolean = true;
		
		protected override function copy_protected(otherConfig:qb2CarEngineConfig):void
		{
			this.constrainRpm = otherConfig.constrainRpm;
			this.cancelThrottleWhenShifting = otherConfig.cancelThrottleWhenShifting;
		}
	}
}