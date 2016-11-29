package quickb2.thirdparty.box2d 
{
	import Box2DAS.Common.b2Base;
	import Box2DAS.Common.b2Def;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2World;
	import Box2DAS.Dynamics.Joints.b2DistanceJoint;
	import Box2DAS.Dynamics.Joints.b2Joint;
	import Box2DAS.Dynamics.Joints.b2JointDef;
	import Box2DAS.Dynamics.Joints.b2RevoluteJoint;
	import Box2DAS.Dynamics.Joints.b2RevoluteJointDef;
	import quickb2.lang.types.qb2ClosureConstructor;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.backend.qb2BackEndResult;
	import quickb2.physics.core.backend.qb2E_BackEndProp;
	import quickb2.physics.core.backend.qb2E_BackEndResult;
	import quickb2.physics.core.backend.qb2I_BackEndCallbacks;
	import quickb2.physics.core.backend.qb2I_BackEndWorldRepresentation;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.prop.qb2PU_PhysicsProp;
	import quickb2.physics.core.qb2A_SimulatedPhysicsObject;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2E_LengthUnit;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.thirdparty.box2d.joints.qb2Box2dBodyTuple;
	import quickb2.thirdparty.box2d.joints.qb2Box2dDistanceJoint;
	import quickb2.thirdparty.box2d.joints.qb2Box2dJointRepresentation;
	import quickb2.thirdparty.box2d.joints.qb2Box2dMouseJoint;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.prop.qb2PropValueSet;
	import quickb2.utils.qb2ObjectPool;
	import quickb2.utils.qb2ObjectPoolClosureDelegate;
	
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2World;
	
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Box2dWorldRepresentation extends Object implements qb2I_BackEndWorldRepresentation
	{
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		private static const s_utilValueSet:qb2PropValueSet = new qb2PropValueSet(3);
		
		private const m_utilTuple:qb2Box2dBodyTuple = new qb2Box2dBodyTuple();
		private var m_box2dWorld:b2World;
		private var m_world:qb2World;
		private var m_errorDuringLastStep:Error;
		private var m_isStepping:Boolean = false;
		private var m_groundBody:b2Body;
		
		private const m_massResetQueue:Vector.<qb2Box2dBodyRepresentation> = new Vector.<qb2Box2dBodyRepresentation>();
		
		private const m_jointDestroyQueue:Vector.<b2Joint> = new Vector.<b2Joint>();
		private const m_destroyQueue:Vector.<qb2Box2dObjectRepresentation> = new Vector.<qb2Box2dObjectRepresentation>();
		
		/*private const m_shapePool:qb2ObjectPool = new qb2ObjectPool
		(
			new qb2ClosureConstructor(function():qb2Box2dShapeRepresentation
			{
				return new qb2Box2dShapeRepresentation();
			}),
			new qb2ObjectPoolClosureDelegate(function(instance:qb2Box2dShapeRepresentation):void
			{
				instance.clean();
			})
		);
		
		private const m_bodyPool:qb2ObjectPool = new qb2ObjectPool
		(
			new qb2ClosureConstructor(function():qb2Box2dBodyRepresentation
			{
				return new qb2Box2dBodyRepresentation();
			}),
			new qb2ObjectPoolClosureDelegate(function(instance:qb2Box2dBodyRepresentation):void
			{
				instance.clean();
			})
		);
		
		private const m_jointPool:qb2ObjectPool = new qb2ObjectPool
		(
			new qb2ClosureConstructor(function():qb2Box2dJointRepresentation
			{
				return new qb2Box2dJointRepresentation();
			}),
			new qb2ObjectPoolClosureDelegate(function(instance:qb2Box2dJointRepresentation):void
			{
				instance.clean();
			})
		);*/
	
		public function qb2Box2dWorldRepresentation()
		{
			
		}
		
		public function getWorld():qb2World
		{
			return m_world;
		}
		
		public function getBox2dWorld():b2World
		{
			return m_box2dWorld;
		}
		
		public function startUp(world:qb2World, callbacks:qb2I_BackEndCallbacks):void
		{
			b2Base.initialize(true);
			b2World.defaultContactListener     = qb2Box2dContactListener;
			b2World.defaultDestructionListener = qb2Box2dDestructionListener;
			
			m_box2dWorld = new b2World(new V2(), true);
			m_world = world;
			
			(m_box2dWorld.m_contactListener as qb2Box2dContactListener).initialize(callbacks, this);
			(m_box2dWorld.m_destructionListener as qb2Box2dDestructionListener).initialize(callbacks);
			
			m_groundBody = m_box2dWorld.CreateBody(b2Def.body);
		}
		
		public function getBox2dGroundBody():b2Body
		{
			return m_groundBody;
		}
		
		public function shutDown():void
		{
			// nothing to do here I don't think...GC should take care of things.
		}
		
		public function step(timeStep:Number, positionIterations:int, velocityIterations:int):void
		{
			m_isStepping = true;
			{
				m_errorDuringLastStep = null;
				
				b2Base.lib.b2World_Step(m_box2dWorld._ptr, timeStep, velocityIterations, positionIterations);
				
				processDestroyQueues();
				processMassResetQueue();
			}
			m_isStepping = false;
		}
		
		public function isLocked():Boolean
		{
			return m_box2dWorld.IsLocked();
		}
		
		public function setProperties(propertyMap:qb2PropMap, changeFlags:qb2PropFlags, transform_nullable:qb2AffineMatrix, result_out:qb2BackEndResult):void
		{
			var isGravityChanged:Boolean = qb2PU_PhysicsProp.isCoordinatePropertySet(changeFlags, qb2S_PhysicsProps.GRAVITY, true);
			var isGravityUnitChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.GRAVITY_LENGTH_UNIT, changeFlags);
			var isPixelsPerMeterChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.PIXELS_PER_METER, changeFlags);
			
			if ( !isGravityChanged && !isGravityUnitChanged && !isPixelsPerMeterChanged )  return;
			
			qb2PU_PhysicsProp.getCoordinate(propertyMap, changeFlags, qb2S_PhysicsProps.GRAVITY, s_utilValueSet);
			qb2PU_PhysicsProp.copyValueSetToCoordinate(s_utilValueSet, s_utilVector1);
			
			var gravityUnit:qb2E_LengthUnit = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.GRAVITY_LENGTH_UNIT);
			if ( gravityUnit == qb2E_LengthUnit.PIXELS )
			{
				var pixelsPerMeter:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.PIXELS_PER_METER);
				s_utilVector1.scaleByNumber(1 / pixelsPerMeter);
			}
			
			var box2dVector:V2 = new V2(s_utilVector1.getX(), s_utilVector1.getY());
			m_box2dWorld.SetGravity(box2dVector);
		}
		
		public function makeRepresentation(object:qb2A_SimulatedPhysicsObject, rotationStack:Number, transform:qb2AffineMatrix, propertyMap:qb2PropMap, result_out:qb2BackEndResult):qb2I_BackEndRepresentation
		{
			var objectRep:qb2Box2dObjectRepresentation = object.getBackEndRepresentation() as qb2Box2dObjectRepresentation;
			
			if ( objectRep == null )
			{
				if ( qb2U_Type.isKindOf(object, qb2A_TangibleObject) )
				{
					if ( qb2U_Type.isKindOf(object, qb2Shape) )
					{
						objectRep = new qb2Box2dShapeRepresentation();
					}
					else if ( qb2U_Type.isKindOf(object, qb2Body) )
					{
						objectRep = new qb2Box2dBodyRepresentation();
					}
				}
				else if ( qb2U_Type.isKindOf(object, qb2Joint) )
				{
					var jointType:qb2E_JointType = propertyMap.getProperty(qb2S_PhysicsProps.JOINT_TYPE);
					
					objectRep = new qb2Box2dJointRepresentation();
				}
				
				objectRep.init(object, this);
			}
			
			qb2_assert(objectRep != null);
			objectRep.makeBox2dObject(propertyMap, transform, rotationStack, result_out);
			
			return objectRep as qb2I_BackEndRepresentation;
		}
		
		public function destroyRepresentation(backEndRepresentation:qb2I_BackEndRepresentation):void
		{
			processDestroyQueues();
			
			var objectRep:qb2Box2dObjectRepresentation = backEndRepresentation as qb2Box2dObjectRepresentation;
			qb2_assert(objectRep != null);
			
			if ( objectRep.hasBox2dObject() )
			{
				if ( m_box2dWorld.IsLocked() )
				{
					m_destroyQueue.push(objectRep);
				}
				else
				{
					objectRep.destroyBox2dObject();
					objectRep.clean();
				}
			}
			else
			{
				//--- DRK > Should be a somewhat rare case...some examples...shape geometry is null, joint had an attachent taken away
				//---		or body got added to world in middle of timestep, then immediately removed.
				objectRep.clean();
			}
		}
		
		public function getErrorDuringLastStep():Error
		{
			return m_errorDuringLastStep;
		}
		
		internal function setErrorDuringLastStep(error:Error):void
		{
			m_errorDuringLastStep = error;
		}
		
		public function queueJointDestruction(joint:b2Joint):void
		{
			m_jointDestroyQueue.push(joint);
		}
		
		internal function queueMassReset(bodyRep:qb2Box2dBodyRepresentation):void
		{
			m_massResetQueue.push(bodyRep);
		}
		
		public function onFlushComplete():void
		{
			if ( this.isLocked() )
			{
				return;
			}
			
			processMassResetQueue();
		}
		
		private function processMassResetQueue():void
		{
			var i:int;
			var length:int = m_massResetQueue.length;
			for ( i = 0; i < length; i++ )
			{
				var bodyRep:qb2Box2dBodyRepresentation = m_massResetQueue[i];
				
				bodyRep.resetMass();
			}
			m_massResetQueue.length = 0;
		}
		
		private function processDestroyQueues():void
		{
			if ( this.isLocked() )
			{
				return;
			}
			
			processJointDestroyQueue();
			processNormalDestroyQueue();
		}
		
		private function processJointDestroyQueue():void
		{
			for ( var i:int = 0; i < m_jointDestroyQueue.length; i++ )
			{
				var box2dJoint:b2Joint = m_jointDestroyQueue[i];
				
				m_box2dWorld.DestroyJoint(box2dJoint);
			}
			
			m_jointDestroyQueue.length = 0;
		}
		
		private function processNormalDestroyQueue():void
		{
			for ( var i:int = 0; i < m_destroyQueue.length; i++ )
			{
				var objectRep:qb2Box2dObjectRepresentation = m_destroyQueue[i];
				var asShapeRep:qb2Box2dShapeRepresentation = objectRep as qb2Box2dShapeRepresentation;
				
				if ( asShapeRep != null )
				{
					if ( asShapeRep.getBox2dBody() == null )
					{
						asShapeRep.queueForMassReset();
					}
				}
				
				objectRep.destroyBox2dObject();
				objectRep.clean();
			}
			
			m_destroyQueue.length = 0;
		}
		
		public function getFloat(propertyEnum:qb2E_BackEndProp):Number 
		{
			return NaN;
		}
		
		public function syncVector(propertyEnum:qb2E_BackEndProp, vector_out:qb2GeoVector):void 
		{
			
		}
		
		public function syncPoint(propertyEnum:qb2E_BackEndProp, point_out:qb2GeoPoint, pixelsPerMeter:Number):void 
		{
			
		}
		
		public function getBoolean(propertyEnum:qb2E_BackEndProp):Boolean 
		{
			return false;
		}
		
		public function onStepComplete():void 
		{
			
		}
		
		/*public function getFloat(propertyEnum:qb2E_BackEndProp, backEndRepresentation:*):Number
		{
			var asJoint:b2Joint = backEndRepresentation as b2Joint;
			
			if ( asJoint )
			{
				switch(propertyEnum)
				{
					case qb2E_BackEndProp.REACTION_TORQUE:
					{
						return asJoint.GetReactionTorque(1 / m_qb2World.getLastTimeStep());
					};
					
					case qb2E_BackEndProp.JOINT_TORQUE:
					{
						var asRevJoint:b2RevoluteJoint = asJoint as b2RevoluteJoint;
						if ( asRevJoint )
						{
							return asRevJoint.GetMotorTorque();
						}
					}
					
					case qb2E_BackEndProps.JOINT_SPEED:
					{
						return asJoint.GetMotorSpeed();
					}
					
					case qb2E_BackEndProps.JOINT_ANGLE:
					{
						asRevJoint = asJoint as b2RevoluteJoint;
						
						if ( asRevJoint )
						{
							return asRevJoint.GetJointAngle();
						}
					}
				}
			}
			
			return 0;
		}
		
		public function getPoint(propertyEnum:qb2E_BackEndProp, backEndRepresentation:*):qb2GeoPoint
		{
		}
		
		public function getVector(propertyEnum:qb2E_BackEndProp, backEndRepresentation:*):qb2GeoVector
		{
			var asJoint:b2Joint = backEndRepresentation as b2Joint;
			
			if ( asJoint )
			{
				switch(propertyEnum)
				{
					case qb2E_BackEndProps.REACTION_FORCE:
					{
						var vec:V2 = asJoint.GetReactionForce(1 / m_qb2World.getLastTimeStep());
						return new qb2GeoVector(vec.x, vec.y);
					};
				}
			}
			
			return null;
		}
		
		public function getBoolean(propertyEnum:qb2E_BackEndProp, backEndRepresentation:*):Boolean
		{
			var asBody:b2Body = backEndRepresentation as b2Body;
			
			if ( asBody )
			{
				switch(propertyEnum)
				{
					case qb2E_BackEndProps.IS_SLEEPING:
					{
						return !asBody.IsAwake();
					};
				}
			}
			
			return false;
		}*/
	}
}