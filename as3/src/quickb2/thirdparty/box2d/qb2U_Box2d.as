package quickb2.thirdparty.box2d 
{
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.Joints.b2JointDef;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoCurveBoundedPlane;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2U_Math;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2CoordProp;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.utils.qb2U_Geom;
	import quickb2.thirdparty.box2d.joints.qb2Box2dBodyTuple;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Box2d extends qb2UtilityClass
	{
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		
		public static function isChangeFlagSet(property:qb2PhysicsProp, changeFlags_nullable:qb2PropFlags):Boolean
		{
			return changeFlags_nullable == null || changeFlags_nullable.isBitSet(property);
		}
		
		public static function populateJointDef(jointDef:b2JointDef, tuple:qb2Box2dBodyTuple):void
		{
			jointDef.bodyA = tuple.bodyA;
			jointDef.bodyB = tuple.bodyB;
		}
		
		public static function getBox2dBodyAttachment(tang:qb2A_TangibleObject, backEnd:qb2Box2dWorldRepresentation):b2Body
		{
			if ( tang.getAncestorBody() == null )
			{
				if ( qb2U_Type.isKindOf(tang, qb2I_RigidObject) )
				{
					return (tang.getBackEndRepresentation() as qb2Box2dBodyRepresentation).getBox2dBody();
				}
				else
				{
					return backEnd.getBox2dGroundBody();
				}
			}
			else
			{
				return (tang.getAncestorBody().getBackEndRepresentation() as qb2Box2dBodyRepresentation).getBox2dBody();
			}
			
			return null;
		}
		
		public static function getCurve(geometry:qb2A_GeoEntity):qb2A_GeoCurve
		{
			var curve:qb2A_GeoCurve = null;
			
			if ( qb2U_Type.isKindOf(geometry, qb2A_GeoCurveBoundedPlane) )
			{
				curve = (geometry as qb2A_GeoCurveBoundedPlane).getBoundary();
			}
			else if ( qb2U_Type.isKindOf(geometry, qb2A_GeoCurve) )
			{
				curve = geometry as qb2A_GeoCurve;
			}
			
			return curve;
		}
		
		public static function calcJointAnchor(joint:qb2Joint, property:qb2CoordProp, anchor_copied:qb2GeoPoint, transform_nullable:qb2AffineMatrix, v2_out:V2):void
		{
			var isObjectA:Boolean = property == qb2S_PhysicsProps.ANCHOR_A;
			var object:qb2A_TangibleObject = isObjectA ? joint.getObjectA() : joint.getObjectB();
			var pixelsPerMeter:Number = object.getEffectiveProp(qb2S_PhysicsProps.PIXELS_PER_METER);
			
			if ( object.getAncestorBody() == null )
			{
				if ( qb2U_Type.isKindOf(object, qb2I_RigidObject) )
				{
					setAnchor(v2_out, anchor_copied, pixelsPerMeter);
				}
				else
				{
					calcGlobalPoint(object, anchor_copied, transform_nullable, s_utilPoint);
					
					setAnchor(v2_out, s_utilPoint, pixelsPerMeter);
				}
			}
			else
			{
				calcGlobalPoint(object, anchor_copied, transform_nullable, s_utilPoint);
				
				setAnchor(v2_out, s_utilPoint, pixelsPerMeter);
			}
		}
		
		public static function calcGlobalPoint(attachment:qb2A_TangibleObject, localAnchor:qb2GeoPoint, transform_nullable:qb2AffineMatrix, anchor_out:qb2GeoPoint):void
		{
			if ( transform_nullable == null )
			{
				qb2U_Geom.calcGlobalPoint(attachment, localAnchor, anchor_out, attachment.getAncestorBody());
			}
			else
			{
				anchor_out.copy(localAnchor);
				anchor_out.transformBy(transform_nullable);
			}
		}
		
		public static function setAnchor(anchor:V2, point:qb2GeoPoint, pixelsPerMeter:Number):void
		{
			anchor.x = point.getX() / pixelsPerMeter;
			anchor.y = point.getY() / pixelsPerMeter;
		}
	}

}