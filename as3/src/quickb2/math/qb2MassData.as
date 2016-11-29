package quickb2.math 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2MassData 
	{
		public var mass:Number;
		public var momentOfInertia:Number;
		public const centerOfMass:qb2GeoPoint = new qb2GeoPoint();
		
		public function clear():void
		{
			mass = 0;
			momentOfInertia = 0;
			centerOfMass.zeroOut();
		}
	}
}