package  
{
	import quickb2.debugging.testing.qb2A_DefaultTest;
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
	public class A_PhysicsTest extends qb2A_DefaultTest
	{
		protected var m_world:qb2World;
		
		public function A_PhysicsTest(name_nullable:String = null) 
		{
			super(name_nullable);
		}
		
		public override function onBefore():void
		{
			qb2M_Flash.startUp(null);
			qb2M_Box2d.startUp();
			qb2M_Physics.startUp();
			
			var backEnd:qb2I_BackEndWorldRepresentation = new qb2Box2dWorldRepresentation();
			var config:qb2WorldConfig = new qb2WorldConfig();
			
			m_world = new qb2World(backEnd, config);
		}
		
		public override function onAfter():void
		{
			qb2M_Physics.shutDown();
			qb2M_Box2d.shutDown();
			qb2M_Flash.shutDown();
		}
	}
}