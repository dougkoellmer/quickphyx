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
	public class AncestorBodyTest extends A_PhysicsTest
	{
		public override function run(__ASSERTER__:qb2Asserter):void
		{
			var bodyA:qb2Body = new qb2Body();
			var bodyB:qb2Body = new qb2Body();
			var groupA:qb2Group = new qb2Group();
			var shape:qb2Shape = new qb2Shape();
			
			bodyA.addChild(shape);
			__ASSERTER__.assert(shape.getAncestorBody() == bodyA);
			qb2U_Family.dismantleTree(bodyA);
			
			
			m_world.addChild(bodyA);
			bodyA.addChild(shape);
			__ASSERTER__.assert(shape.getAncestorBody() == bodyA);
			__ASSERTER__.assert(bodyA.getAncestorBody() == null);
			__ASSERTER__.assert(m_world.getAncestorBody() == null);
			qb2U_Family.dismantleTree(m_world);
			

			bodyB.addChild(shape);
			m_world.addChild(bodyA);
			bodyA.addChild(bodyB);
			__ASSERTER__.assert(shape.getAncestorBody() == bodyA);
			qb2U_Family.dismantleTree(m_world);
			
	
			bodyB.addChild(shape);
			m_world.addChild(bodyA);
			shape.setProperty(qb2E_PhysicsProperty.IS_BULLET, true);
			bodyA.addChild(bodyB);
			__ASSERTER__.assert(shape.getAncestorBody() == bodyA);
			
			bodyA.removeChild(bodyB);
			__ASSERTER__.assert(bodyB.getAncestorBody() == null);
			__ASSERTER__.assert(shape.getAncestorBody() == bodyB);
			
			bodyA.addChild(bodyB);
			__ASSERTER__.assert(bodyB.getAncestorBody() == bodyA);
			shape.setProperty(qb2E_PhysicsProperty.IS_BULLET, false);
			bodyA.removeChild(bodyB);
			__ASSERTER__.assert(bodyB.getAncestorBody() == null);
			__ASSERTER__.assert(shape.getAncestorBody() == bodyB);
			bodyB.removeChild(shape);
			__ASSERTER__.assert(shape.getAncestorBody() == null);
			
			
			bodyA.addChild(groupA);
			groupA.addChild(bodyB);
			bodyB.addChild(shape);
			__ASSERTER__.assert(shape.getAncestorBody() == bodyA);
			
		}
	}
}