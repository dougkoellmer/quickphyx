package quickb2.thirdparty.box2d.joints 
{
	import Box2DAS.Common.b2Base;
	import Box2DAS.Common.b2Def;
	import Box2DAS.Common.b2Vec2;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.Joints.b2Joint;
	import Box2DAS.Dynamics.Joints.b2JointDef;
	import Box2DAS.Dynamics.Joints.b2MouseJoint;
	import Box2DAS.Dynamics.Joints.b2MouseJointDef;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.backend.qb2BackEndResult;
	import quickb2.physics.core.backend.qb2E_BackEndProp;
	import quickb2.physics.core.backend.qb2E_BackEndResult;
	import quickb2.physics.core.backend.qb2I_BackEndJoint;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2CoordProp;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.utils.qb2U_Geom;
	import quickb2.thirdparty.box2d.qb2Box2dObjectRepresentation;
	import quickb2.thirdparty.box2d.qb2U_Box2d;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Box2dJointRepresentation extends qb2Box2dObjectRepresentation implements qb2I_BackEndJoint
	{
		private static const s_originPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilBodyTuple:qb2Box2dBodyTuple = new qb2Box2dBodyTuple();
		protected static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		
		private var m_box2dJoint:b2Joint;
		private var m_isActive:Boolean = true;
		private var m_jointType:qb2E_JointType = null;
		
		public final override function makeBox2dObject(propertyMap:qb2PropMap, transform:qb2AffineMatrix, rotationStack:Number, result_out:qb2BackEndResult):void
		{
			result_out.set(qb2E_BackEndResult.SUCCESS);
			
			if ( m_box2dJoint != null )
			{
				qb2_assert(false);
				return;
			}
			
			m_isActive = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_ACTIVE);
			m_jointType = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.JOINT_TYPE);
			
			if ( !m_isActive )
			{
				return;
			}
			
			if ( m_jointType == null )
			{
				return;
			}
			
			if ( this.getWorldRepresentation().isLocked() )
			{
				result_out.set(qb2E_BackEndResult.TRY_AGAIN_LATER);
				
				return;
			}
			
			var component:qb2A_Box2dJointComponent = qb2A_Box2dJointComponent.getComponent(m_jointType);
			
			if ( !component.getBodyTuple(this, s_utilBodyTuple) )
			{
				result_out.set(qb2E_BackEndResult.TRY_AGAIN_SOON);
				
				return;
			}
			
			this.m_box2dJoint = component.makeBox2dJoint(this, propertyMap, s_utilBodyTuple);
			
			if ( m_box2dJoint != null )
			{
				setBothJointAnchors(propertyMap, null);
				
				component.setBox2dBooleanProperties(this, propertyMap, null);
				component.setBox2dNumericProperties(this, propertyMap, null);
				
				m_box2dJoint.SetUserData(this);
			}
			else
			{
				qb2_assert(false);
			}
		}
		
		private function destroyBox2dJoint(actuallyDestroyJoint:Boolean):void
		{
			if ( m_box2dJoint != null )
			{
				m_box2dJoint.SetUserData(null);
				
				if ( actuallyDestroyJoint )
				{
					if ( this.getWorldRepresentation().isLocked() )
					{
						this.getWorldRepresentation().queueJointDestruction(m_box2dJoint);
					}
					else
					{
						this.getWorldRepresentation().getBox2dWorld().DestroyJoint(m_box2dJoint);
					}
				}
				
				m_box2dJoint = null;
			}
			
			m_isActive = false;
			m_jointType = null;
		}
		
		public override function destroyBox2dObject():void
		{
			destroyBox2dJoint(true);
		}
		
		public function onImplicitlyDestroyed():void
		{
			destroyBox2dJoint(false);
		}
		
		public function onAttachmentRemoved():void
		{
			destroyBox2dJoint(true);
		}
		
		public function getFloat(propertyEnum:qb2E_BackEndProp):Number
		{
			switch(propertyEnum)
			{
				case qb2E_BackEndProp.ABSOLUTE_ROTATION:
				{
					//return m_body.GetAngle();
				}
				
				case qb2E_BackEndProp.ANGULAR_VELOCITY:
				{
					//return m_body.GetAngularVelocity();
				}
			}
			
			return NaN;
		}
		
		public function syncVector(propertyEnum:qb2E_BackEndProp, vector_out:qb2GeoVector):void
		{
			switch(propertyEnum)
			{
			}
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
			var component:qb2A_Box2dJointComponent = qb2A_Box2dJointComponent.getComponent(m_jointType);
			
			if ( component != null )
			{
				component.onStepComplete(this);
			}
		}
		
		private function getAnchorOrDefault(property:qb2PhysicsProp, propertyMap:qb2PropMap):qb2GeoPoint
		{
			var anchor:qb2GeoPoint = propertyMap.getPropertyOrDefault(property);
			
			return anchor == null ? s_originPoint : anchor;
		}
		
		protected function setBothJointAnchors(propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void
		{
			var component:qb2A_Box2dJointComponent = qb2A_Box2dJointComponent.getComponent(m_jointType);
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.ANCHOR_A, changeFlags_nullable) )
			{
				component.setJointAnchor(this, qb2S_PhysicsProps.ANCHOR_A, null, getAnchorOrDefault(qb2S_PhysicsProps.ANCHOR_A, propertyMap));
			}
			
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.ANCHOR_B, changeFlags_nullable) )
			{
				component.setJointAnchor(this, qb2S_PhysicsProps.ANCHOR_B, null, getAnchorOrDefault(qb2S_PhysicsProps.ANCHOR_B, propertyMap));
			}
		}
		
		private function handleIsActiveChange(propertyMap:qb2PropMap, changeFlags:qb2PropFlags, result_out:qb2BackEndResult):Boolean
		{
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_ACTIVE, changeFlags) )
			{
				var isActive:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_ACTIVE);
				
				if ( isActive )
				{
					if ( m_box2dJoint == null )
					{
						makeBox2dObject(propertyMap, null, 0, result_out);
						
						return true;
					}
				}
				else
				{
					if ( m_box2dJoint != null )
					{
						this.destroyBox2dJoint(true);
						
						return true;
					}
				}
			}
			
			return false;
		}
		
		private function handleJointTypeChange(propertyMap:qb2PropMap, changeFlags:qb2PropFlags, result_out:qb2BackEndResult):Boolean
		{
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.JOINT_TYPE, changeFlags) )
			{
				var oldJointType:qb2E_JointType = m_jointType;
				var newJointType:qb2E_JointType = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.JOINT_TYPE);
				
				if ( oldJointType != null && newJointType == null )
				{
					this.destroyBox2dObject();
					
					return true;
				}
				else if ( oldJointType == null && newJointType != null )
				{
					this.makeBox2dObject(propertyMap, null, 0, result_out);
					
					return true;
				}
				else if( oldJointType != null && newJointType != null && oldJointType != newJointType )
				{
					this.destroyBox2dObject();
					this.makeBox2dObject(propertyMap, null, 0, result_out);
					
					return true;
				}
				else
				{
					qb2_assert(oldJointType == newJointType);
				}
			}
			
			return false;
		}
		
		[qb2_virtual] public final function setProperties(propertyMap:qb2PropMap, changeFlags:qb2PropFlags, transform_nullable:qb2AffineMatrix, result_out:qb2BackEndResult):void 
		{
			result_out.set(qb2E_BackEndResult.SUCCESS);
			
			if ( handleIsActiveChange(propertyMap, changeFlags, result_out) )
			{
				return;
			}
			
			if ( handleJointTypeChange(propertyMap, changeFlags, result_out) )
			{
				return;
			}
			
			if ( m_box2dJoint != null )
			{
				var component:qb2A_Box2dJointComponent = qb2A_Box2dJointComponent.getComponent(m_jointType);
				component.setBox2dNumericProperties(this, propertyMap, changeFlags);
				component.setBox2dBooleanProperties(this, propertyMap, changeFlags);
				
				setBothJointAnchors(propertyMap, changeFlags);
			}
		}
		
		internal function getBox2dJoint():b2Joint
		{
			return m_box2dJoint;
		}
		
		public function getJoint():qb2Joint
		{
			return this.getPhysicsObject() as qb2Joint;
		}
		
		public function isSimulating():Boolean
		{
			return m_box2dJoint != null || m_isActive == false;
		}
		
		public override function hasBox2dObject():Boolean
		{
			return m_box2dJoint != null;
		}
	
		public function setJointAnchor(anchorProperty:qb2CoordProp, transform_nullable:qb2AffineMatrix, anchor:qb2GeoPoint):void 
		{
			var component:qb2A_Box2dJointComponent = qb2A_Box2dJointComponent.getComponent(m_jointType);
			
			if ( component == null )  return;
			
			component.setJointAnchor(this, anchorProperty, transform_nullable, anchor);
		}
	}
}