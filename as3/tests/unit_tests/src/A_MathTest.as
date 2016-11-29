package  
{
	import quickb2.debugging.testing.qb2A_DefaultTest;
	import quickb2.math.geo.qb2M_Math_Geo;
	import quickb2.physics.core.backend.qb2I_BackEndWorldRepresentation;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.physics.core.tangibles.qb2WorldConfig;
	import quickb2.physics.qb2M_Physics;
	import quickb2.thirdparty.box2d.qb2Box2dWorldRepresentation;
	import quickb2.thirdparty.box2d.qb2M_Box2d;
	import quickb2.thirdparty.flash.qb2FlashClock;
	import quickb2.thirdparty.flash.qb2M_Flash;
	import quickb2.utils.qb2I_Clock;
	
	/**
	 * ...
	 * @author 
	 */
	public class A_MathTest extends qb2A_DefaultTest
	{
		public function A_MathTest(name_nullable:String = null) 
		{
			super(name_nullable);
		}
		
		public override function onBefore():void
		{
			qb2M_Math_Geo.startUp();
		}
		
		public override function onAfter():void
		{
			qb2M_Math_Geo.shutDown();
		}
	}
}