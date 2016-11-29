package  
{
	import flash.display.Sprite;
	import quickb2.debugging.testing.qb2A_DefaultTest;
	import quickb2.debugging.testing.qb2Asserter;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.physics.core.events.qb2ContactEvent;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.property.qb2E_JointType;
	
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
	public class MassTest extends A_PhysicsTest
	{
		private var m_bodyA:qb2Body = new qb2Body();
		private var m_shapeA:qb2Shape = new qb2Shape();
		private var m_shapeB:qb2Shape = new qb2Shape();
		
		
		private function clear():void
		{
			qb2U_Family.dismantleTree(m_bodyA);
			
			m_bodyA.setProperty(qb2E_PhysicsProperty.MASS, null);
			m_bodyA.setProperty(qb2E_PhysicsProperty.DENSITY, null);
			m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, null);
			m_shapeA.setProperty(qb2E_PhysicsProperty.DENSITY, null);
			m_shapeB.setProperty(qb2E_PhysicsProperty.MASS, null);
			m_shapeB.setProperty(qb2E_PhysicsProperty.DENSITY, null);
		}
		
		public override function run(__ASSERTER__:qb2Asserter):void
		{
			var joint:qb2Joint = new qb2Joint(qb2E_JointType.MOUSE, m_bodyA, m_shapeA);
			joint.setProperty(qb2E_PhysicsProperty.ATTACHMENT_A, m_bodyA);
			joint.setProperty(qb2E_PhysicsProperty.ATTACHMENT_B, m_shapeA);
			joint.setProperty(qb2E_PhysicsProperty.ANCHOR_A, new qb2GeoPoint(3, 4));
			
			
			var geometry:qb2GeoBoundingBox = new qb2GeoBoundingBox();
			geometry.setAsRect(null, 4, 4);
			var mass:Number = 16;
			m_shapeA.setProperty(qb2E_PhysicsProperty.GEOMETRY, geometry);
			m_shapeB.setProperty(qb2E_PhysicsProperty.GEOMETRY, geometry);
			
			{
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				__ASSERTER__.assert(m_shapeA.getProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.DENSITY) == 1);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass);
				clear();
			}
			
			{
				m_bodyA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				m_bodyA.addChild(m_shapeA);
				m_bodyA.addChild(m_shapeB);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass/2);
				__ASSERTER__.assert(m_shapeB.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass / 2);
				
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass + mass/2);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_shapeB.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass / 2);
				
				clear();
			}
			
			
			{
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				m_bodyA.addChild(m_shapeA);
				__ASSERTER__.assert(m_shapeA.getProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.DENSITY) == 1);
				__ASSERTER__.assert(m_bodyA.getProperty(qb2E_PhysicsProperty.MASS) == null);
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.DENSITY) == 1);
				clear();
			}
			
			{
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				m_bodyA.addChild(m_shapeA);
				m_bodyA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				__ASSERTER__.assert(m_shapeA.getProperty(qb2E_PhysicsProperty.MASS) == mass);
				clear();
			}
				
			{
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				m_bodyA.addChild(m_shapeA);
				m_bodyA.setProperty(qb2E_PhysicsProperty.MASS, mass * 2);
				__ASSERTER__.assert(m_shapeA.getProperty(qb2E_PhysicsProperty.MASS) == null);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass * 2);
				clear();
			}
				
				
			{
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				m_bodyA.addChild(m_shapeA);
				m_bodyA.setProperty(qb2E_PhysicsProperty.MASS, mass * 2);
				m_bodyA.setProperty(qb2E_PhysicsProperty.DENSITY, 1);
				
				__ASSERTER__.assert(m_bodyA.getProperty(qb2E_PhysicsProperty.MASS) == null);
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.DENSITY) == 1);
			}
			
			{
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				m_bodyA.addChild(m_shapeA);
				m_bodyA.setProperty(qb2E_PhysicsProperty.MASS, mass * 2);
				m_bodyA.setProperty(qb2E_PhysicsProperty.DENSITY, 1);
				
				__ASSERTER__.assert(m_bodyA.getProperty(qb2E_PhysicsProperty.MASS) == null);
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.DENSITY) == 1);
			}
				
				/*
				
				
				m_bodyA.setProperty(qb2E_PhysicsProperty.MASS, null);
				
				__ASSERTER__.assert(m_bodyA.getProperty(qb2E_PhysicsProperty.DENSITY) == null);
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == 0);
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.DENSITY) == 0);
				
				
				
				m_bodyA.setProperty(qb2E_PhysicsProperty.DENSITY, 1);
				m_shapeA.setProperty(qb2E_PhysicsProperty.DENSITY, 2);
				
				__ASSERTER__.assert(m_bodyA.getProperty(qb2E_PhysicsProperty.DENSITY) == 1);
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.DENSITY) == 2);
				
				
				
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.DENSITY) == 1);
				
				
				m_bodyA.setProperty(qb2E_PhysicsProperty.DENSITY, 1);
				__ASSERTER__.assert(m_shapeA.getProperty(qb2E_PhysicsProperty.MASS) == mass);
				
				
				m_bodyA.setProperty(qb2E_PhysicsProperty.MASS, null);
				m_bodyA.setProperty(qb2E_PhysicsProperty.DENSITY, null);
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, null);
				m_shapeA.setProperty(qb2E_PhysicsProperty.DENSITY, null);
				m_bodyA.removeAllChildren();
				
				
				m_bodyA.setProperty(qb2E_PhysicsProperty.DENSITY, 12);
				m_shapeA.setProperty(qb2E_PhysicsProperty.MASS, mass);
				
				__ASSERTER__.assert(m_shapeA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_bodyA.getEffectiveProperty(qb2E_PhysicsProperty.MASS) == mass);
				__ASSERTER__.assert(m_shapeA.getProperty(qb2E_PhysicsProperty.MASS) == mass);*/
			
		}
	}
}