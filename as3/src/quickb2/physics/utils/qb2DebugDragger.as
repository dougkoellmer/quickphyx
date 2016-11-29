package quickb2.physics.utils 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.physics.core.events.qb2StepEvent;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.platform.input.qb2I_Mouse;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2DebugDragger
	{
		/**
		 * If debugDragMouse is set to something meaningful, this value determines how forcefully the mouse can drag objects.
		 * It is scaled by the mass of the objects being dragged, so all objects will be dragged at about the same speed.
		 * 
		 * @default 1000.0
		 * @see #debugDragSource
		 *
		public var debugDragAcceleration:Number = 1000.0;
		
		/**
		 * If set, debug mouse dragging becomes enabled. This makes every dynamic object draggable (except if
		 * the object has isDebugDraggable set to false).  It is called debug because it is not meant as a
		 * robust solution for most games or simulations, and is not particularly efficient as far as finding
		 * which body to start dragging on a mouse down event.
		 * 
		 * @default null
		 * @see #debugDragAccel
		 *
		public var debugDragMouse:qb2I_Mouse = null;
		*/
		private var m_mouse:qb2I_Mouse;
		private var m_group:qb2Group;
		private const m_mouseJoint:qb2Joint = new qb2Joint();
		
		private const m_mousePoint:qb2GeoPoint = new qb2GeoPoint();
		private const m_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		
		private var m_dragAcceleration:Number = 1;
		
		public function qb2DebugDragger(mouse:qb2I_Mouse, group:qb2Group, dragAcceleration:Number = 1000) 
		{
			m_mouseJoint.setProp(qb2S_PhysicsProps.JOINT_TYPE, qb2E_JointType.MOUSE);
			
			m_group = group;
			m_mouse = mouse;
			
			m_dragAcceleration = dragAcceleration;
			
			enable();
		}
		
		public function enable():void
		{
			if ( !m_group.hasEventListener(null, updateDebugMouseJoint) )
			{
				m_group.addEventListener(qb2StepEvent.PRE_STEP, updateDebugMouseJoint);
			}
		}
		
		public function disable():void
		{
			m_group.removeEventListeners(updateDebugMouseJoint);
		}
		
		public function setDragAcceleration(value:Number):void
		{
			m_dragAcceleration = value;
		}
		
		public function getMouse():qb2I_Mouse
		{
			return m_mouse;
		}
		
		public function getGroup():qb2Group
		{
			return m_group;
		}
		
		private function updateDebugMouseJoint():void
		{			
			if ( m_mouse != null )
			{
				if ( m_mouseJoint.getParent() != m_group )
				{
					if ( m_mouseJoint.getParent() != null )
					{
						m_mouseJoint.removeFromParent();
					}
					
					m_group.addChild(m_mouseJoint);
				}
				
				m_mouseJoint.setObjectB(m_group);
			}
			else
			{
				if ( m_mouseJoint.getParent() == m_group )
				{
					m_mouseJoint.removeFromParent();
					m_mouseJoint.setObjectB(null);
				}
				
				return;
			}
			
			if( m_mouse.isDown() )
			{
				if ( !m_mouseJoint.hasAttachments() )
				{
					m_mousePoint.set(m_mouse.getCursorX(), m_mouse.getCursorY());
					
					var shape:qb2Shape = qb2U_Geom.findShapeAtPoint(m_group, m_mousePoint);
					
					if ( shape != null )
					{
						m_mouseJoint.setObjectA(shape);
						m_mouseJoint.setObjectB(m_group);
						m_mouseJoint.getEffectiveProp(qb2S_PhysicsProps.ANCHOR_A, m_mousePoint);

						//setObjectIndex(m_mouseJoint, numObjects - 1); // make joint be drawn on top of everything else...this could be done every frame to be guaranteed always on top, but that prolly costs more than it's worth.
					}
				}
				
				if( m_mouseJoint.hasAttachments() )
				{
					m_mousePoint.set(m_mouse.getCursorX(), m_mouse.getCursorY());
					qb2U_Geom.calcLocalPoint(m_group, m_mousePoint, m_mouseJoint.getEffectiveProp(qb2S_PhysicsProps.ANCHOR_B, m_utilPoint1), null);
					
					var attachedMass:Number = m_mouseJoint.getObjectA().getEffectiveProp(qb2S_PhysicsProps.MASS) + qb2U_Tang.calcAttachedMass(m_mouseJoint.getObjectA());
					var force:Number = attachedMass * m_dragAcceleration;
					m_mouseJoint.setProp(qb2S_PhysicsProps.MAX_FORCE, force);
				}
			}
			else
			{
				m_mouseJoint.setObjectA(null);
			}
		}
	}
}