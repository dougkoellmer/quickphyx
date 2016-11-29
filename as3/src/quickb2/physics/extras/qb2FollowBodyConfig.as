package quickb2.physics.extras 
{
	import quickb2.math.qb2U_Units;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2FollowBodyConfig extends Object
	{
		public var maxLinearVelocity:Number = 100;
		public var maxAngularVelocity:Number = 100;
		public var linearSnapTime:Number = 0;
		public var angularSnapTime:Number = 0;
		
		public var linearSnapTolerance:Number      = .01;
		public var angularSnapTolerance:Number     = qb2U_Units.deg_to_rad(1);
		
		public function copy(otherConfig:qb2FollowBodyConfig):void
		{
			this.maxLinearVelocity = otherConfig.maxLinearVelocity;
			this.maxAngularVelocity = otherConfig.maxAngularVelocity;
			this.linearSnapTime = otherConfig.linearSnapTime;
			this.angularSnapTime = otherConfig.angularSnapTime;
			
			this.linearSnapTolerance      = otherConfig.linearSnapTolerance;
			this.angularSnapTolerance     = otherConfig.angularSnapTolerance;
		}
	}
}