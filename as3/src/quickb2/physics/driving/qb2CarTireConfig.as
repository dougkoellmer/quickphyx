package quickb2.physics.driving
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarTireConfig
	{
		public var friction:Number = 1.5
		
		public var rollingFrictionWhenCoasting:Number 	= 0.01;
		public var rollingFrictionWithThrottle:Number 	= 0.0;
		public var rollingFrictionWithBrakes:Number 	= 0.0;
		
		public var isDriven:Boolean = false;
		public var canTurn:Boolean  = false;
		public var canBrake:Boolean = false;
		public var flippedTurning:Boolean = false;
		
		protected override function copy_protected(otherConfig:qb2CarTireConfig):void
		{
			this.friction = otherConfig.friction;
			this.rollingFrictionWhenCoasting = otherConfig.rollingFrictionWhenCoasting;
			this.rollingFrictionWithThrottle = otherConfig.rollingFrictionWithThrottle;
			this.rollingFrictionWithBrakes   = otherConfig.rollingFrictionWithBrakes;
			this.isDriven = otherConfig.isDriven;
			this.canTurn = otherConfig.canTurn;
			this.canBrake = otherConfig.canBrake;
			this.flippedTurning = otherConfig.flippedTurning;
		}
	}
}