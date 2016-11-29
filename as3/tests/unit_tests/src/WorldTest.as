package  
{
	import quickb2.debugging.testing.qb2A_DefaultTest;
	import quickb2.debugging.testing.qb2Asserter;
	
	import quickb2.physics.core.property.qb2E_PhysicsProperty;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.physics.utils.qb2U_Family;
	
	/**
	 * ...
	 * @author 
	 */
	public class WorldTest extends A_PhysicsTest
	{
		public override function run(__ASSERTER__:qb2Asserter):void
		{
			var bodyA:qb2Body = new qb2Body();
			var bodyB:qb2Body = new qb2Body();
			var groupA:qb2Group = new qb2Group();
			var shape:qb2Shape = new qb2Shape();
			
			m_world.addChild(bodyA);
			__ASSERTER__.assert(bodyA.getWorld() == m_world);
			
			bodyA.removeFromParent();
			__ASSERTER__.assert(bodyA.getWorld() == null);
			
			bodyA.addChild(groupA);
			groupA.addChild(bodyB);
			bodyB.addChild(shape);
			m_world.addChild(bodyA);
			__ASSERTER__.assert(shape.getWorld() == m_world);
			bodyA.removeFromParent();
			__ASSERTER__.assert(shape.getWorld() == null);
			
			m_world.addChild(bodyA);
			shape.setProperty(qb2E_PhysicsProperty.IS_BULLET, true);
			bodyA.removeFromParent();
			__ASSERTER__.assert(shape.getWorld() == null);
		}
	}
}