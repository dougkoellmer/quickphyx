package quickb2.thirdparty.box2d.joints 
{
	import Box2DAS.Common.b2Def;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.Joints.b2Joint;
	import Box2DAS.Dynamics.Joints.b2JointDef;
	import Box2DAS.Dynamics.Joints.b2DistanceJoint;
	import Box2DAS.Dynamics.Joints.b2DistanceJointDef;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.thirdparty.box2d.qb2Box2dBodyTuple;
	import quickb2.thirdparty.box2d.qb2Box2dJointRepresentation;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	
	/**
	 * ...
	 * @author
	 */
	public class qb2Box2dDistanceJoint extends qb2A_Box2dJointComponent
	{
		public function qb2Box2dDistanceJoint() 
		{
			
		}
		
		public override function makeBox2dJoint(jointRep:qb2Box2dJointRepresentation, propertyMap:qb2PropMap, tuple:qb2Box2dBodyTuple):b2Joint
		{
			var joint:qb2Joint = jointRep.getJoint();
			var objectA:qb2A_TangibleObject = joint.getObjectA();
			var objectB:qb2A_TangibleObject = joint.getObjectB();
			
			var def:b2DistanceJointDef = b2Def.distanceJoint;
			qb2U_Box2d.populateJointDef(def, tuple);
			
			var box2dJoint:b2Joint = getWorldRepresentation().getBox2dWorld().CreateJoint(def);
			
			return box2dJoint;
		}
		
		public override function setJointAnchor(jointRep:qb2Box2dJointRepresentation, property:qb2PhysicsProp, anchor:qb2GeoPoint):void
		{
			if ( jointRep.getBox2dJoint() == null )  return;
			
			var joint:qb2Joint = jointRep.getJoint();
			var isObjectA:Boolean = property == qb2S_PhysicsProps.ANCHOR_A;
			var object:qb2A_TangibleObject = isObjectA ? joint.getObjectA() : joint.getObjectB();
			
			var box2dDistanceJoint:b2DistanceJoint = jointRep.getBox2dJoint() as b2DistanceJoint;
			
			qb2U_Box2d.calcJointAnchor(joint, anchor, null, s_utilBox2dVector);
			
			if ( isObjectA )
			{
				box2dDistanceJoint.m_localAnchor1.v2 = s_utilBox2dVector;
			}
			else
			{
				box2dDistanceJoint.m_localAnchor2.v2 = s_utilBox2dVector;
			}
		}
		
		public override function setBox2dNumericProperties(jointRep:qb2Box2dJointRepresentation, propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void 
		{
			if ( jointRep.getBox2dJoint() == null )  return;
			
			if ( !qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.LENGTH, changeFlags_nullable) )  return;
			
			var box2dDistanceJoint:b2DistanceJoint = jointRep.getBox2dJoint() as b2DistanceJoint;
			var joint:qb2Joint = jointRep.getJoint();
			
			var length:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.LENGTH);
			var pixelsPerMeter:Number = changeFlags_nullable == null ? propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.PIXELS_PER_METER) : joint.getEffectiveProp(qb2S_PhysicsProps.PIXELS_PER_METER);
			box2dDistanceJoint.m_length = length / pixelsPerMeter;
		}
	}
}