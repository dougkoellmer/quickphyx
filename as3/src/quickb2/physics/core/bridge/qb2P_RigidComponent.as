package quickb2.physics.core.bridge 
{
	import quickb2.event.qb2GlobalEventPool;
	import quickb2.physics.core.backend.qb2E_BackEndProp;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.events.qb2PropEvent;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2PU_TangBackDoor;
	import quickb2.utils.prop.qb2Prop;
	
	import quickb2.physics.core.iterators.qb2AttachedJointIterator;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.qb2A_PhysicsObject;

	import quickb2.lang.*
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.lang.*
	import quickb2.math.*;
	import quickb2.display.retained.*;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public final class qb2P_RigidComponent
	{
		private var m_owner:qb2A_TangibleObject;
		
		private const m_linearVelocity:qb2GeoVector = new qb2GeoVector();
		private var m_angularVelocity:Number = 0;
		
		public function qb2P_RigidComponent() 
		{
		}
		
		public function init(owner:qb2A_TangibleObject):void
		{
			m_owner = owner;
			
			m_linearVelocity.getEventDispatcher().addEventListener(onLinearVelocityChanged);
		}
		
		public function setProp(property:qb2Prop, value:* ):Boolean
		{
			if ( property == qb2S_PhysicsProps.LINEAR_VELOCITY )
			{
				var linearVelocity:qb2GeoVector = value as qb2GeoVector;
				
				if ( linearVelocity != null )
				{
					m_linearVelocity.copy(linearVelocity);
				}
				
				return true;
			}
			else if( property == qb2S_PhysicsProps.ANGULAR_VELOCITY )
			{
				var angularVelocity:Number = value as Number;
				
				setAngularVelocity(angularVelocity);
				
				return true;
			}
			
			return false;
		}
		
		public function getLinearVelocity():qb2GeoVector
		{
			return m_linearVelocity;
		}
		
		public function getAngularVelocity():Number
		{
			return m_angularVelocity;
		}
		
		public function setAngularVelocity(radsPerSec:Number):void
		{
			m_angularVelocity = radsPerSec;
			
			qb2PU_PhysicsObjectBackDoor.invalidate(m_owner, qb2PF_DirtyFlag.VELOCITIES_CHANGED);
			qb2P_Flusher.getInstance().flush();
			
			qb2PU_TangBackDoor.dispatchPropChangeEvent(m_owner, qb2S_PhysicsProps.ANGULAR_VELOCITY);
		}
		
		public function onStepComplete(rotationStack:Number):void
		{
			syncVelocities(rotationStack);
		}
		
		internal function syncVelocities(rotationStack:Number):void
		{
			var backEndRep:qb2I_BackEndRepresentation = m_owner.getBackEndRepresentation();
			
			if ( backEndRep != null && m_owner.getAncestorBody() == null )
			{
				m_linearVelocity.getEventDispatcher().removeEventListener(onLinearVelocityChanged);
				{
					backEndRep.syncVector(qb2E_BackEndProp.LINEAR_VELOCITY, m_linearVelocity);
					 
					if ( rotationStack != 0.0 && !m_linearVelocity.isZeroLength() )
					{
						m_linearVelocity.rotateBy(-rotationStack);
					}
				}
				m_linearVelocity.getEventDispatcher().addEventListener(onLinearVelocityChanged);
				
				m_angularVelocity = backEndRep.getFloat(qb2E_BackEndProp.ANGULAR_VELOCITY);
			}
		}
		
		private function onLinearVelocityChanged():void
		{
			if ( m_owner.getAncestorBody() != null )
			{
				m_linearVelocity.getEventDispatcher().removeEventListener(onLinearVelocityChanged);
				{
					m_linearVelocity.zeroOut();
					m_angularVelocity = 0;
				}
				m_linearVelocity.getEventDispatcher().addEventListener(onLinearVelocityChanged);
			}
			else
			{
				qb2PU_PhysicsObjectBackDoor.invalidate(m_owner, qb2PF_DirtyFlag.VELOCITIES_CHANGED);
			}
			
			qb2P_Flusher.getInstance().flush();
			
			qb2PU_TangBackDoor.dispatchPropChangeEvent(m_owner, qb2S_PhysicsProps.LINEAR_VELOCITY);
		}

		protected function copy(source:*):void
		{
			var sourceAsRigid:qb2P_RigidComponent = source as qb2P_RigidComponent;
			
			//--- Copy velocities and transforms.
			if ( sourceAsRigid != null )
			{
				m_linearVelocity.copy(sourceAsRigid.m_linearVelocity);
				this.setAngularVelocity(sourceAsRigid.m_angularVelocity);
			}
		}
	}
}