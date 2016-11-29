package quickb2.physics.ai.brains 
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2TrackBrainConfig 
	{		
		public var minHitSpeed:Number = 5;
		public var maxHitSpeed:Number = 50;
		
		public var tetherMultiplier:Number = 15;
		public var tetherMinimum:Number = 10;
		public var tetherMaximum:Number = 150;
		
		public var ignoreGod:Boolean = false;
		public var avoidUTurns:Boolean = true;
		public var uTurnDistance:Number = 100;
		
		public var turnChance:Number = .5;
		
		public var parallelTolerance:Number = 1 * (Math.PI / 180.0);
		
		public var autoSearchForTrack:Boolean = true;
		
		public var historyDepth:uint = 4;
		
		protected override function copy_protected(otherConfig:qb2TrackBrainConfig):void
		{
			this.minHitSpeed = otherConfig.minHitSpeed;
			this.maxHitSpeed = otherConfig.maxHitSpeed;
			
			this.tetherMultiplier = otherConfig.tetherMultiplier;
			this.tetherMinimum = otherConfig.tetherMinimum;
			this.tetherMaximum = otherConfig.tetherMaximum
			
			this.ignoreGod = otherConfig.ignoreGod;
			this.avoidUTurns = otherConfig.avoidUTurns;
			this.uTurnDistance = otherConfig.uTurnDistance;
			
			this.turnChance = otherConfig.turnChance;
			
			this.parallelTolerance = otherConfig.parallelTolerance;
			
			this.autoSearchForTrack = otherConfig.autoSearchForTrack;
			
			this.historyDepth = otherConfig.historyDepth;
		}
	}
}