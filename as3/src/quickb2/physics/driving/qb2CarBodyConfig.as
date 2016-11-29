package quickb2.physics.driving 
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarBodyConfig extends Object
	{		
		public var maxTurnAngle:Number = Math.PI / 4;
		public var turnAxis:Number = 0;
		public var zCenterOfMass:Number = 1;
		
		//--- If brakes ever get implemented 'correctly', these variables will be needed.
		/*public var brakePadFriction:Number  = .5;
		public var brakeForceMaximum:Number = 50000;  // maximum force that can be applied to brake pads
		public var brakeDiscRadius:Number   = .2     // how far away from a tire's rotational axis that the brake force is applied.*/
		
		public var tractionControl:Boolean = true;
		public var autoSetTurnAxis:Boolean = true;
		
		public var testTiresIndividuallyAgainstTerrains:Boolean = true;
		
		protected override function copy_protected(otherConfig:qb2CarBodyConfig):void
		{
			this.parked = otherConfig.parked;
			this.maxTurnAngle = otherConfig.maxTurnAngle;
			this.tractionControl = otherConfig.tractionControl;
			this.zCenterOfMass = otherConfig.zCenterOfMass;
			this.autoSetTurnAxis = otherConfig.autoSetTurnAxis;
			this.turnAxis = otherConfig.turnAxis;
			this.testTiresIndividuallyAgainstTerrains = otherConfig.testTiresIndividuallyAgainstTerrains;
		}
	}
}