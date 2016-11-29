package quickb2.thirdparty.box2d 
{
	import Box2DAS.Collision.Shapes.b2MassData;
	import Box2DAS.Common.b2Def;
	import Box2DAS.Common.b2Vec2;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2BodyDef;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2World;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2MassData;
	import quickb2.physics.core.backend.qb2BackEndError;
	import quickb2.physics.core.backend.qb2BackEndResult;
	import quickb2.physics.core.backend.qb2E_BackEndProp;
	import quickb2.physics.core.backend.qb2E_BackEndResult;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.backend.qb2I_BackEndRigidBody;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2E_LengthUnit;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.*;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.qb2OptVector;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Box2dBodyRepresentation extends qb2Box2dObjectRepresentation implements qb2I_BackEndRigidBody
	{
		private static var s_utilBox2dMassData:b2MassData = null;
		private static const s_utilMassData:qb2MassData = new qb2MassData();
		private static const s_utilPointB2:V2 = new V2();
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector:qb2GeoVector = new qb2GeoVector();
		
		private var m_box2dBody:b2Body;
		
		private var m_queuedForMassReset:Boolean = false;
		
		private static function initUtilBox2dMassData():void
		{
			s_utilBox2dMassData = s_utilBox2dMassData != null ? s_utilBox2dMassData : new b2MassData();
		}
		
		protected function makeBox2dObject_earlyOut(result_out:qb2BackEndResult):Boolean
		{
			if ( this.getWorldRepresentation().isLocked() )
			{
				result_out.set(qb2E_BackEndResult.TRY_AGAIN_LATER);
				
				return true;
			}
			
			return false;
		}
		
		public override function makeBox2dObject(propertyMap:qb2PropMap, transform:qb2AffineMatrix, rotationStack:Number, result_out:qb2BackEndResult):void
		{
			result_out.set(qb2E_BackEndResult.SUCCESS);
			
			if ( m_box2dBody != null )
			{
				qb2_assert(false);
				return;
			}
			
			if ( makeBox2dObject_earlyOut(result_out) )  return;
			
			var worldRep:qb2Box2dWorldRepresentation = this.getWorldRepresentation();
			var tang:qb2A_TangibleObject = this.getPhysicsObject() as qb2A_TangibleObject;
			var tangAsRigid:qb2I_RigidObject = getPhysicsObject() as qb2I_RigidObject;
			var bodyDef:b2BodyDef = b2Def.body;
			bodyDef.userData = this;
			var sleepingWhenAdded:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_SLEEPING_WHEN_ADDED);
			bodyDef.awake = !sleepingWhenAdded;
			var pixelsPerMeter:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.PIXELS_PER_METER);
			
			calcPosition(tang.getPosition(), transform, pixelsPerMeter, s_utilPoint);
			bodyDef.position.x = s_utilPoint.getX();
			bodyDef.position.y = s_utilPoint.getY();
			bodyDef.angle = rotationStack + tang.getRotation();
			
			bodyDef.linearVelocity.x = tangAsRigid.getLinearVelocity().getX();
			bodyDef.linearVelocity.y = tangAsRigid.getLinearVelocity().getY();
			bodyDef.angularVelocity = tangAsRigid.getAngularVelocity();
			
			var velocityUnit:qb2E_LengthUnit = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.LINEAR_VELOCITY_LENGTH_UNIT);
			if ( velocityUnit != qb2E_LengthUnit.METERS )
			{
				bodyDef.linearVelocity.x /= pixelsPerMeter;
				bodyDef.linearVelocity.y /= pixelsPerMeter;
			}
			
			if ( tang.getEffectiveProp(qb2S_PhysicsProps.MASS) == 0 && (tangAsRigid.getAngularVelocity() != 0 || tangAsRigid.getLinearVelocity().calcLengthSquared() != 0) )
			{
				bodyDef.type = b2Body.b2_kinematicBody;
			}
			else
			{
				//--- DRK > Always setting to a static body initially so that multiple fixture creations don't invoke a mass reset every time.
				//---		If the body ends up having mass, it will be validated at the end of the flush and changed to dynamic.
				bodyDef.type = b2Body.b2_staticBody;
				
				this.queueForMassReset();
			}
			
			m_box2dBody = worldRep.getBox2dWorld().CreateBody(bodyDef);
			m_box2dBody.SetUserData(this);
			
			setBox2dNumericProperties(propertyMap, null);
			setBox2dBooleanProperties(propertyMap, null);
		}
		
		public override function destroyBox2dObject():void
		{
			if ( m_box2dBody == null )  return;
			
			m_box2dBody.SetUserData(null);
			m_box2dBody.GetWorld().DestroyBody(m_box2dBody);
			m_box2dBody = null;
			
			m_queuedForMassReset = false;
		}
		
		public function getFloat(propertyEnum:qb2E_BackEndProp):Number
		{
			if ( m_box2dBody == null )  return 0;
			
			switch(propertyEnum)
			{
				case qb2E_BackEndProp.ABSOLUTE_ROTATION:
				{
					return m_box2dBody.GetAngle();
				}
				
				case qb2E_BackEndProp.ANGULAR_VELOCITY:
				{
					return m_box2dBody.GetAngularVelocity();
				}
			}
			
			return 0.0;
		}
		
		internal function queueForMassReset():void
		{
			if ( m_queuedForMassReset )  return;
			
			if ( m_box2dBody != null )
			{
				if ( m_box2dBody.GetType() == b2Body.b2_dynamicBody )
				{
					m_box2dBody.SetType(b2Body.b2_staticBody);
				}
			}
			
			getWorldRepresentation().queueMassReset(this);
			
			m_queuedForMassReset = true;
		}
		
		public function setIsSleeping(value:Boolean):void
		{
			if ( m_box2dBody == null )  return;
			
			m_box2dBody.SetAwake(!value);
		}
		
		private function resetMassData():void
		{			
			//--- DRK > Implicitly triggers ResetMassData, which should be an inexpensive
			//----		loop through fixtures, earlying out on each due to zero density.
			m_box2dBody.SetType(b2Body.b2_dynamicBody);
			
			s_utilMassData.clear();
			var fixture:b2Fixture = m_box2dBody.GetFixtureList();
			var lastShapeRep:qb2Box2dShapeRepresentation = null;
			var i:int = 0;
			while ( fixture != null )
			{
				var shapeRep:qb2Box2dShapeRepresentation = fixture.GetUserData() as qb2Box2dShapeRepresentation;
				
				qb2_assert(shapeRep != null);
				
				if ( shapeRep != lastShapeRep )
				{
					var shapeMass:Number = shapeRep.getTangible().getEffectiveProp(qb2S_PhysicsProps.MASS);
					if ( shapeMass > 0 )
					{
						s_utilMassData.mass += shapeMass;
						
						//--- DRK > Mass might be above zero, and moment of intertia zero, when there's a point mass right at the center of mass.
						if ( shapeRep.getMomentOfInertia() > 0 )
						{
							s_utilVector.copy(shapeRep.getCenterOfMass());
							s_utilVector.scaleByNumber(shapeMass);
							s_utilMassData.centerOfMass.translateBy(s_utilVector);
							s_utilMassData.momentOfInertia += shapeRep.getMomentOfInertia() * shapeMass;
						}
					}
				}				
				
				lastShapeRep = shapeRep;
				fixture = fixture.GetNext();
				i++;
			}
			
			if ( s_utilMassData.mass > 0.0 )
			{
				s_utilMassData.centerOfMass.scaleByNumber(1 / s_utilMassData.mass);
			}
			
			initUtilBox2dMassData();
			s_utilBox2dMassData.mass = s_utilMassData.mass;
			s_utilBox2dMassData.I = s_utilMassData.momentOfInertia;
			s_utilBox2dMassData.center.x = s_utilMassData.centerOfMass.getX();
			s_utilBox2dMassData.center.y = s_utilMassData.centerOfMass.getY();
			m_box2dBody.SetMassData(s_utilBox2dMassData);
		}
		
		internal function resetMass():void
		{
			if ( m_box2dBody == null )  return;
			
			qb2_assert(m_queuedForMassReset == true);
			
			if ( getTangible().getEffectiveProp(qb2S_PhysicsProps.MASS) > 0.0 )
			{
				resetMassData();
			}
			
			m_queuedForMassReset = false;
		}
		
		public function getTangible():qb2A_TangibleObject
		{
			return getPhysicsObject() as qb2A_TangibleObject;
		}
		
		private function calcPosition(point:qb2GeoPoint, transform_nullable:qb2AffineMatrix, pixelsPerMeter:Number, point_out:qb2GeoPoint):void
		{
			point_out.copy(point);
			
			if ( transform_nullable != null )
			{
				point_out.transformBy(transform_nullable);
			}
			
			point_out.scaleByNumber(1 / pixelsPerMeter);
		}
		
		public function updateTransform(transform_nullable:qb2AffineMatrix, rotationStack:Number, pixelsPerMeter:Number, result_out:qb2BackEndResult):void
		{
			var tang:qb2A_TangibleObject = getTangible();
			calcPosition(tang.getPosition(), transform_nullable, pixelsPerMeter, s_utilPoint);
			s_utilPointB2.x = s_utilPoint.getX();
			s_utilPointB2.y = s_utilPoint.getY();
			m_box2dBody.SetTransform(s_utilPointB2, rotationStack + tang.getRotation());
		}
		
		public function updateVelocities(linear_copied:qb2GeoVector, angular:Number, rotationStack:Number, pixelsPerMeter:Number):void
		{
			if ( m_box2dBody == null )  return;
			
			var isZeroLengthVector:Boolean = linear_copied.isZeroLength();
			
			//--- DRK > Swap back and forth between kinematic and static body type if needed.
			if (  getTangible().getEffectiveProp(qb2S_PhysicsProps.MASS) == 0 )
			{
				if ( !isZeroLengthVector || angular != 0 )
				{
					m_box2dBody.SetType(b2Body.b2_kinematicBody);
				}
				else
				{
					m_box2dBody.SetType(b2Body.b2_staticBody);
				}
			}
			
			if ( !isZeroLengthVector )
			{
				s_utilVector.copy(linear_copied);
				s_utilVector.scaleByNumber(1/pixelsPerMeter);
				s_utilVector.rotateBy(rotationStack);
				
				m_box2dBody.SetLinearVelocity(new V2(s_utilVector.getX(), s_utilVector.getY()));
			}
			else
			{
				m_box2dBody.SetLinearVelocity(new V2(0, 0));
			}
			
			m_box2dBody.SetAngularVelocity(angular);
			
			m_box2dBody.SetAwake(true);
		}
		
		public function syncVector(propertyEnum:qb2E_BackEndProp, vector_out:qb2GeoVector):void
		{
			if ( m_box2dBody == null )  return;
			
			switch(propertyEnum)
			{
				case qb2E_BackEndProp.LINEAR_VELOCITY:
				{
					vector_out.set(m_box2dBody.m_linearVelocity.x, m_box2dBody.m_linearVelocity.y);  return;
				}
			}
		}
		
		public function syncPoint(propertyEnum:qb2E_BackEndProp, point_out:qb2GeoPoint, pixelsPerMeter:Number):void
		{
			if ( m_box2dBody == null )  return;
			
			switch(propertyEnum)
			{
				case qb2E_BackEndProp.ABSOLUTE_POSITION:
				{					
					point_out.set(m_box2dBody.GetPosition().x * pixelsPerMeter, m_box2dBody.GetPosition().y * pixelsPerMeter);
					
					return;
				}
				
				case qb2E_BackEndProp.CENTER_OF_MASS:
				{
					var center:V2 = m_box2dBody.GetWorldCenter();
					point_out.set(center.x * pixelsPerMeter, center.y * pixelsPerMeter);
					
					return;
				}
			}
		}
		
		public function getBoolean(propertyEnum:qb2E_BackEndProp):Boolean
		{
			if ( m_box2dBody != null )
			{
				if ( propertyEnum == qb2E_BackEndProp.IS_SLEEPING )
				{
					return !m_box2dBody.IsAwake();
				}
			}
				
			return true;
		}
		
		protected function setBox2dBooleanProperties(propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void
		{
			if ( m_box2dBody == null )
			{
				return;
			}
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_ACTIVE, changeFlags_nullable) )
			{
				m_box2dBody.SetBullet(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_ACTIVE));
			}
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_ROTATIONALLY_FIXED, changeFlags_nullable) )
			{
				m_box2dBody.SetFixedRotation(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_ROTATIONALLY_FIXED));
			}
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_SLEEPING_ALLOWED, changeFlags_nullable) )
			{
				m_box2dBody.SetSleepingAllowed(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_SLEEPING_ALLOWED));
			}
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_BULLET, changeFlags_nullable) )
			{
				m_box2dBody.SetBullet(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_BULLET));
			}
		}
		
		protected function setBox2dNumericProperties(propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void
		{
			if ( m_box2dBody == null )  return;
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.LINEAR_DAMPING, changeFlags_nullable) )
			{
				m_box2dBody.SetLinearDamping(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.LINEAR_DAMPING));
			}
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.ANGULAR_DAMPING, changeFlags_nullable) )
			{
				m_box2dBody.SetAngularDamping(propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.ANGULAR_DAMPING));
			}
		}
		
		protected function setProperties_earlyOut(changeFlags:qb2PropFlags, result_out:qb2BackEndResult):Boolean
		{
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_ACTIVE, changeFlags) )
			{
				if ( m_box2dBody != null )
				{
					if ( getWorldRepresentation().isLocked() )
					{
						result_out.set(qb2E_BackEndResult.TRY_AGAIN_LATER);
						
						return true;
					}
				}
			}
			
			return false;
		}
		
		public function setProperties(propertyMap:qb2PropMap, changeFlags:qb2PropFlags, transform_nullable:qb2AffineMatrix, result_out:qb2BackEndResult):void
		{
			result_out.set(qb2E_BackEndResult.SUCCESS);
			
			if ( setProperties_earlyOut(changeFlags, result_out) )  return;
			
			setBox2dBooleanProperties(propertyMap, changeFlags);
			setBox2dNumericProperties(propertyMap, changeFlags);
		}
		
		[qb2_abstract] public function setContactFilter(filter_copied_nullable:qb2ContactFilter):void
		{
			
		}
		
		public override function hasBox2dObject():Boolean
		{
			return m_box2dBody != null;
		}
		
		public function getBox2dBody():b2Body
		{
			return m_box2dBody;
		}
		
		public function onStepComplete():void 
		{
			if ( m_box2dBody == null )  return;
			
			//--- Clear forces.  This isn't done right after b2World::Step() with b2World::ClearForces() to avoid double iteration.
			//--- This function is called anyway, so might as well do it here.
			m_box2dBody.m_force.x = m_box2dBody.m_force.y = 0;
			m_box2dBody.m_torque = 0;
		}
	}
}