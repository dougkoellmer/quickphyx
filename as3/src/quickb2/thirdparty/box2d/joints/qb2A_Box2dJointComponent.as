package quickb2.thirdparty.box2d.joints 
{
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.Joints.b2Joint;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2CoordProp;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.thirdparty.box2d.qb2U_Box2d;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2PropFlags;
	
	/**
	 * ...
	 * @author 
	 */
	[qb2_abstract] public class qb2A_Box2dJointComponent 
	{
		protected static const s_utilBox2dVector:V2 = new V2();
		
		protected static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		
		private static const m_subComponents:Vector.<qb2A_Box2dJointComponent> = new Vector.<qb2A_Box2dJointComponent>();
		
		public function qb2A_Box2dJointComponent(type:qb2E_JointType)
		{
			if ( m_subComponents.length <= type.getOrdinal() )
			{
				m_subComponents.length = type.getOrdinal() + 1;
			}
			
			m_subComponents[type.getOrdinal()] = this;
		}
		
		internal static function getComponent(type_nullable:qb2E_JointType):qb2A_Box2dJointComponent
		{
			if ( type_nullable == null )
			{
				return null;
			}
			
			return m_subComponents[type_nullable.getOrdinal()];
		}
		
		[qb2_virtual] public function setJointAnchor(jointRep:qb2Box2dJointRepresentation, anchorProperty:qb2CoordProp, transform_nullable:qb2AffineMatrix, anchor:qb2GeoPoint):void
		{
		}
		
		[qb2_abstract] public function makeBox2dJoint(jointRep:qb2Box2dJointRepresentation, propertyMap:qb2PropMap, tuple:qb2Box2dBodyTuple):b2Joint
		{
			return null;
		}
		
		[qb2_virtual] public function setBox2dNumericProperties(jointRep:qb2Box2dJointRepresentation, propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void 
		{
			
		}
		
		[qb2_virtual] public function setBox2dBooleanProperties(jointRep:qb2Box2dJointRepresentation, propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void 
		{
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.COLLIDE_JOINT_ATTACHMENTS, changeFlags_nullable) )
			{
				var collideConnected:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.COLLIDE_JOINT_ATTACHMENTS);
				jointRep.getBox2dJoint().m_collideConnected = collideConnected;
			}
		}
		
		[qb2_virtual] public function onStepComplete(jointRep:qb2Box2dJointRepresentation):void
		{
		}
		
		[qb2_virtual] public function getBodyTuple(jointRep:qb2Box2dJointRepresentation, tuple_out:qb2Box2dBodyTuple):Boolean
		{
			var joint:qb2Joint = jointRep.getJoint();
			var objectA:qb2A_TangibleObject = joint.getObjectA();
			var objectB:qb2A_TangibleObject = joint.getObjectB();
			tuple_out.bodyA = qb2U_Box2d.getBox2dBodyAttachment(objectA, jointRep.getWorldRepresentation());
			tuple_out.bodyB = qb2U_Box2d.getBox2dBodyAttachment(objectB, jointRep.getWorldRepresentation());
			
			return tuple_out.bodyA != null && tuple_out.bodyB != null;
		}
	}
}