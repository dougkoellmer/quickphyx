package quickb2.thirdparty.box2d.joints 
{
	import Box2DAS.Common.b2Def;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.Joints.b2Joint;
	import Box2DAS.Dynamics.Joints.b2JointDef;
	import Box2DAS.Dynamics.Joints.b2MouseJoint;
	import Box2DAS.Dynamics.Joints.b2MouseJointDef;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.backend.qb2BackEndResult;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2CoordProp;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.thirdparty.box2d.qb2Box2dBodyRepresentation;
	import quickb2.thirdparty.box2d.qb2Box2dBodyTuple;
	import quickb2.thirdparty.box2d.qb2Box2dJointRepresentation;
	import quickb2.thirdparty.box2d.qb2U_Box2d;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2Box2dMouseJoint extends qb2A_Box2dJointComponent
	{
		public function qb2Box2dMouseJoint() 
		{
			super(qb2E_JointType.MOUSE);
		}
		
		public override function makeBox2dJoint(jointRep:qb2Box2dJointRepresentation, propertyMap:qb2PropMap, tuple:qb2Box2dBodyTuple):b2Joint
		{
			var joint:qb2Joint = jointRep.getJoint();
			var objectA:qb2A_TangibleObject = joint.getObjectA();
			var objectB:qb2A_TangibleObject = joint.getObjectB();
			
			var def:b2MouseJointDef = b2Def.mouseJoint;
			qb2U_Box2d.populateJointDef(def, tuple);
			
			var box2dJoint:b2Joint = getWorldRepresentation().getBox2dWorld().CreateJoint(def);
			
			return box2dJoint;
		}
		
		public override function onStepComplete(jointRep:qb2Box2dJointRepresentation):void
		{
			var joint:qb2Joint = jointRep.getJoint();
			
			if ( joint.hasAttachments() )
			{
				if ( joint.getObjectB().getAncestorBody() != null || qb2U_Type.isKindOf(joint.getObjectB(), qb2I_RigidObject) )
				{
					joint.getEffectiveProp(qb2S_PhysicsProps.ANCHOR_B, s_utilPoint1);
					setJointAnchor(qb2S_PhysicsProps.ANCHOR_B, s_utilPoint1);
				}
			}
		}
		
		public override function getBodyTuple(jointRep:qb2Box2dJointRepresentation, tuple_out:qb2Box2dBodyTuple):Boolean
		{
			var joint:qb2Joint = jointRep.getJoint();
			var objectA:qb2A_TangibleObject = joint.getObjectA();
			var objectB:qb2A_TangibleObject = joint.getObjectB();
			
			var definition:b2JointDef = b2Def.mouseJoint;
			var ancestorBodyA:qb2Body = objectA.getAncestorBody();
			var ancestorBodyB:qb2Body = objectB.getAncestorBody();
			
			var bodyA:b2Body = jointRep.getWorldRepresentation().getBox2dGroundBody();
			var bodyB:b2Body = null;
			
			if ( ancestorBodyA == null )
			{
				if ( qb2U_Type.isKindOf(objectA, qb2Group) )
				{
					qb2_assert(false);
				}
				else
				{
					bodyB = (objectA.getBackEndRepresentation() as qb2Box2dBodyRepresentation).getBox2dBody();
				}
			}
			else
			{
				bodyB = (objectA.getAncestorBody().getBackEndRepresentation() as qb2Box2dBodyRepresentation).getBox2dBody();
			}
			
			if ( bodyA == null || bodyB == null )
			{
				return false;
			}
			
			tuple_out.bodyA = bodyA;
			tuple_out.bodyB = bodyB;
			
			return true;
		}
		
		public override function setJointAnchor(jointRep:qb2Box2dJointRepresentation, anchorProperty:qb2CoordProp, transform_nullable:qb2AffineMatrix, anchor_copied:qb2GeoPoint):void
		{
			if ( jointRep.getBox2dJoint() == null )  return;
			
			var joint:qb2Joint = this.getJoint();
			var isObjectA:Boolean = property == qb2S_PhysicsProps.ANCHOR_A;
			var object:qb2A_TangibleObject = isObjectA ? joint.getObjectA() : joint.getObjectB();
			
			var asMouseJoint:b2MouseJoint = jointRep.getBox2dJoint() as b2MouseJoint;
			
			qb2U_Box2d.calcJointAnchor(joint, property, anchor_copied, null, s_utilBox2dVector);
			
			if ( isObjectA )
			{
				asMouseJoint.m_localAnchor.v2 = s_utilBox2dVector;
			}
			else
			{
				asMouseJoint.SetTarget(s_utilBox2dVector);
			}
		}
		
		public override function setBox2dNumericProperties(jointRep:qb2Box2dJointRepresentation, propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void 
		{
			if ( jointRep.getBox2dJoint() == null )  return;
			
			var box2dMouseJoint:b2MouseJoint = jointRep.getBox2dJoint() as b2MouseJoint;
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.DAMPING_RATIO, changeFlags_nullable) )
			{
				box2dMouseJoint.SetDampingRatio(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.DAMPING_RATIO));
			}
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.FREQUENCY_HZ, changeFlags_nullable) )
			{
				box2dMouseJoint.SetFrequency(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.FREQUENCY_HZ));
			}
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.MAX_FORCE, changeFlags_nullable) )
			{
				box2dMouseJoint.SetMaxForce(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.MAX_FORCE));
			}
		}
	}
}