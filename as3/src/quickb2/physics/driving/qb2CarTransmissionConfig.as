package quickb2.physics.driving 
{
	import quickb2.objects.driving.enums.qb2E_CarTransmissionType;
	import quickb2.objects.driving.enums.qb2E_CarTransmissionType;
	import QuickB2.objects.driving.qb2CarTransmission;
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarTransmissionConfig extends Object
	{		
		public var torqueConversion:Number = .8;
		public var differential:Number = 3.5;
		public var shiftTime:Number = .25;
		public var efficiency:Number = .7;
		public var transmissionType:qb2E_CarTransmissionType = qb2E_CarTransmissionType.AUTOMATIC;
		public const forwardGearRatios:Vector.<Number> = new Vector.<Number>();
		public const reverseGearRatios:Vector.<Number> = new Vector.<Number>();
		
		public var shiftingInterruptible:Boolean = false;
		
		protected override function copy_protected(otherConfig:qb2CarTransmissionConfig):void
		{
			this.torqueConversion = otherConfig.torqueConversion;
			this.differential = otherConfig.differential;
			this.efficiency = otherConfig.efficiency;
			this.transmissionType = otherConfig.transmissionType;
			this.shiftTime = otherConfig.shiftTime;
			this.shiftingInterruptible = otherConfig.shiftingInterruptible;
			
			vectorCopy(otherConfig.forwardGearRatios, this.forwardGearRatios);
			vectorCopy(otherConfig.reverseGearRatios, this.reverseGearRatios);
		}
		
		private static function vectorCopy(source:Vector.<Number>, destination:Vector.<Number>):void
		{
			source.length = 0;
			for ( var i:int = 0; i < destination.length; i++ )
			{
				source.push(destination[i]);
			}
		}
	}
}