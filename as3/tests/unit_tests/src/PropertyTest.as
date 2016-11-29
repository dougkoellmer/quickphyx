package  
{
	import quickb2.debugging.testing.qb2A_DefaultTest;
	import quickb2.debugging.testing.qb2Asserter;
	
	import quickb2.physics.core.property.qb2E_PhysicsProperty;
	import quickb2.physics.core.property.qb2E_PhysicsProperty;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.physics.utils.qb2U_Family;
	
	/**
	 * ...
	 * @author 
	 */
	public class PropertyTest extends A_PhysicsTest
	{
		public override function run(__ASSERTER__:qb2Asserter):void
		{
			var bodyA:qb2Body = new qb2Body();
			var bodyB:qb2Body = new qb2Body();
			var groupA:qb2Group = new qb2Group();
			var shape:qb2Shape = new qb2Shape();
			
			bodyA.setProperty(qb2E_PhysicsProperty.ANGULAR_DAMPING, 10);
			bodyA.setProperty(qb2E_PhysicsProperty.IS_BULLET, true);
			
			bodyA.addChild(shape);
			
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.IS_BULLET) == true);
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.ANGULAR_DAMPING) == 10);
			
			bodyA.removeAllChildren();
			
			shape.setProperty(qb2E_PhysicsProperty.IS_BULLET, false);
			shape.setProperty(qb2E_PhysicsProperty.ANGULAR_DAMPING, 20);
			
			bodyA.addChild(shape);
			
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.IS_BULLET) == false);
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.ANGULAR_DAMPING) == 20);
			
			bodyA.setProperty(qb2E_PhysicsProperty.ANGULAR_DAMPING, 10);
			bodyA.setProperty(qb2E_PhysicsProperty.IS_BULLET, true);
			
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.IS_BULLET) == false);
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.ANGULAR_DAMPING) == 20);
			
			m_world.addChild(bodyA);
			
			m_world.setProperty(qb2E_PhysicsProperty.IS_GHOST, true);
			m_world.setProperty(qb2E_PhysicsProperty.LINEAR_DAMPING, 10);
			
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.IS_GHOST) == true);
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.LINEAR_DAMPING) == 10);
			
			shape.removeFromParent();
			
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.IS_GHOST) == false);
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.LINEAR_DAMPING) == 0);
			
			qb2U_Family.dismantleTree(m_world);
			
			m_world.addChild(bodyA);
			bodyA.addChild(bodyB);
			bodyB.addChild(shape);
			
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.IS_GHOST) == true);
			
			shape.setProperty(qb2E_PhysicsProperty.CONTACT_FILTER, new qb2ContactFilter());
			m_world.removeChild(bodyA);
			
			__ASSERTER__.assert(shape.getEffectiveProperty(qb2E_PhysicsProperty.IS_GHOST) == false);
		}
	}
}