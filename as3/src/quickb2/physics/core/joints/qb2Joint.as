/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package quickb2.physics.core.joints
{
	import quickb2.debugging.*;
	import quickb2.debugging.logging.*;
	import quickb2.event.*;
	import quickb2.utils.primitives.qb2Boolean;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2MathEvent;
	import quickb2.physics.core.backend.*;;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.bridge.qb2P_Flusher;
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.events.*;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.utils.prop.qb2Prop;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropMapStack;
	
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	import quickb2.display.immediate.style.*;
	
	import quickb2.physics.core.*;
	import quickb2.math.geo.*;
	import quickb2.math.geo.coords.*;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	import quickb2.physics.core.tangibles.*;

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2Joint extends qb2A_SimulatedPhysicsObject
	{
		private static const s_utilPropertyFlags:qb2MutablePropFlags = new qb2MutablePropFlags();
		private static const s_utilBool:qb2Boolean = new qb2Boolean();
		
		private static const ATTACHMENT_COUNT:int = 2;
		
		private const m_objects:Vector.<qb2A_TangibleObject> = new Vector.<qb2A_TangibleObject>(ATTACHMENT_COUNT, true);
		
		private const m_previousJoint:Vector.<qb2Joint> = new Vector.<qb2Joint>(ATTACHMENT_COUNT , true);
		private const m_nextJoint:Vector.<qb2Joint> = new Vector.<qb2Joint>(ATTACHMENT_COUNT , true);
		
		private static const MAX_SPRING_SPEED:Number = 1000000;
	
		public function qb2Joint(type_nullable:qb2E_JointType = null, objectA_nullable:qb2A_TangibleObject = null, objectB_nullable:qb2A_TangibleObject = null)
		{
			include "../../../lang/macros/QB2_ABSTRACT_CLASS";
			
			this.init(type_nullable, objectA_nullable, objectB_nullable);
		}
		
		private function init(type_nullable:qb2E_JointType, objectA:qb2A_TangibleObject, objectB:qb2A_TangibleObject):void
		{
			setProp(qb2S_PhysicsProps.JOINT_TYPE, type_nullable);
			
			setObjectA(objectA);
			setObjectB(objectB);
		}
		
		private function onAnchorChanged(anchor:qb2GeoPoint):void
		{
			s_utilPropertyFlags.clear();
			
			if ( anchor == this.getProp(qb2S_PhysicsProps.ANCHOR_A) )
			{
				s_utilPropertyFlags.setBit(qb2S_PhysicsProps.ANCHOR_A, true);
			}
			else if ( anchor == this.getProp(qb2S_PhysicsProps.ANCHOR_B) )
			{
				s_utilPropertyFlags.setBit(qb2S_PhysicsProps.ANCHOR_B, true);
			}
			
			qb2PU_PhysicsObjectBackDoor.invalidate(this, qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED, s_utilPropertyFlags);
			
			qb2P_Flusher.getInstance().flush();
		}
		
		public function calcReactionForce(vector_out:qb2GeoVector):void
		{
			if ( getBackEndRepresentation() != null)
			{
				getBackEndRepresentation().syncVector(qb2E_BackEndProp.REACTION_FORCE, vector_out);
			}
			else
			{
				vector_out.zeroOut();
			}
		}
		
		public function calcReactionTorque():Number
		{
			if ( getBackEndRepresentation() != null )
			{
				return getBackEndRepresentation().getFloat(qb2E_BackEndProp.REACTION_TORQUE);
			}
			
			return 0;
		}
		
		public function getNextJoint(object:qb2A_TangibleObject):qb2Joint
		{
			for ( var i:int = 0; i < m_objects.length; i++ )
			{
				if ( object == m_objects[i] )
				{
					return m_nextJoint[i];
				}
			}
			
			return null;
		}
		
		internal function markForMakeIfWarranted():void
		{
			if ( hasAttachmentsInWorld() && this.getWorld() == m_objects[0].getWorld() )
			if ( isRepresentable() )
			{
				if ( this.getBackEndRepresentation() == null || !this.getBackEndJoint().isSimulating() )
				{
					qb2PU_PhysicsObjectBackDoor.invalidate(this, qb2PF_DirtyFlag.NEEDS_MAKING);
				}
				else
				{
					qb2_assert(false);
				}
			}
		}
		
		private function destroyIfNecessary():void
		{
			if ( this.getBackEndRepresentation() != null )
			{
				this.getBackEndJoint().onAttachmentRemoved();
			}
		}
		
		private function registerObject(tang:qb2A_TangibleObject, index:int):void
		{
			var currentJointList:qb2Joint = tang.getJointList();
			
			//--- Add joint to the joint list.
			this.m_previousJoint[index] = null;
			this.m_nextJoint[index] = currentJointList;
			qb2PU_TangBackDoor.setJointList(tang, this);
			
			markForMakeIfWarranted();
			qb2P_Flusher.getInstance().flush();
		}
		
		private function unregisterObject(tang:qb2A_TangibleObject, index:int):void
		{
			var currentJointList:qb2Joint = tang.getJointList();
			
			if ( this == currentJointList )
			{
				qb2PU_TangBackDoor.setJointList(tang, this.m_nextJoint[index]);
			}
			
			//--- Remove joint from linked list.
			if ( this.m_previousJoint[index] != null )
			{
				this.m_previousJoint[index].m_nextJoint[index] = this.m_nextJoint[index];
			}
			
			if ( this.m_nextJoint[index] != null )
			{
				this.m_nextJoint[index].m_previousJoint[index] = this.m_previousJoint[index];
			}
			
			this.m_previousJoint[index] = this.m_nextJoint[index] = null;
			
			destroyIfNecessary();
		}
		
		private function setObjectAtIndex(objectIndex:int, someObject:qb2A_TangibleObject):void
		{
			if ( m_objects[objectIndex] == someObject )  return;
			
			if ( m_objects[objectIndex] != null )
			{
				unregisterObject(m_objects[objectIndex], objectIndex);
			}
			
			m_objects[objectIndex] = someObject;
			
			if ( m_objects[objectIndex] != null )
			{
				registerObject(m_objects[objectIndex], objectIndex);
			}
		}
		
		[qb2_virtual] protected function onAttachmentsChanged():void
		{
			
		}
		
		private function getBackEndJoint():qb2I_BackEndJoint
		{
			return getBackEndRepresentation() as qb2I_BackEndJoint;
		}
		
		public function hasAttachments():Boolean
		{
			return m_objects[0] != null && m_objects[1] != null;
		}
		
		public function hasAttachmentsInWorld():Boolean
		{
			if ( hasAttachments() && m_objects[0].getWorld() != null && m_objects[1].getWorld() != null)
			if ( m_objects[0].getWorld() == m_objects[1].getWorld() )
			{
				return true;
			}
			
			return false;
		}
		
		internal function isRepresentable():Boolean
		{
			if( hasAttachments() )
			{
				var objectA:qb2A_TangibleObject = this.getObjectA();
				var objectB:qb2A_TangibleObject = this.getObjectB();
				var ancestorBodyA:qb2Body = objectA.getAncestorBody();
				var ancestorBodyB:qb2Body = objectB.getAncestorBody();
				
				if ( objectA == objectB )
				{
					return false;
				}
				
				if ( this.getEffectiveProp(qb2S_PhysicsProps.JOINT_TYPE) == qb2E_JointType.MOUSE )
				{
					if ( ancestorBodyA == null && qb2U_Type.isKindOf(objectA, qb2Group) )
					{
						return false;
					}
				}
				else
				{
					if ( ancestorBodyA == null && ancestorBodyB == null )
					{
						if ( qb2U_Type.isKindOf(objectA, qb2Group) && qb2U_Type.isKindOf(objectB, qb2Group) )
						{
							return false;
						}
					}
					else if ( ancestorBodyA != null && ancestorBodyB != null )
					{
						if ( ancestorBodyA == ancestorBodyB )
						{
							return false;
						}
					}
				}
				
				return true;
			}
			
			return false;
		}
		
		private function setAnchor(property:qb2PhysicsProp, value:*):void
		{
			var currentAnchor:qb2GeoPoint = super.getProp(property);
			
			if ( currentAnchor != null )
			{
				currentAnchor.getEventDispatcher().removeEventListener(onAnchorChanged);
			}
			
			super.setProp_protected(property, value);
			
			var newAnchor:qb2GeoPoint = value as qb2GeoPoint;
			
			if ( newAnchor != null )
			{
				newAnchor.getEventDispatcher().addEventListener(onAnchorChanged);
			}
		}
		
		protected override function setProp_protected(property:qb2Prop, value:*):void
		{
			var point:qb2GeoPoint;
			var currentAnchor:qb2GeoPoint;
			
			if ( property == qb2S_PhysicsProps.IS_SLEEPING )
			{
				setIsSleeping(value);
			}
			else if ( property == qb2S_PhysicsProps.ANCHOR_A || qb2S_PhysicsProps.ANCHOR_B )
			{
				setAnchor(property as qb2PhysicsProp, value);
			}
			else
			{
				super.setProp_protected(property, value);
			}
		}

		protected override function getProp_protected(property:qb2Prop, value_out_nullable:* = null):*
		{
			if ( property == qb2S_PhysicsProps.IS_SLEEPING )
			{
				return isSleeping();
			}
			else
			{
				return super.getProp_protected(property, value_out_nullable);
			}
		}
		
		private function setIsSleeping(isSleeping:Boolean):void
		{
			for ( var i:int = 0; i < m_objects.length; i++ )
			{
				if ( m_objects[i] != null)
				{
					m_objects[i].setProp(qb2S_PhysicsProps.IS_SLEEPING, true);
				}
			}
		}
		
		private function isSleeping():Boolean
		{
			for ( var i:int = 0; i < m_objects.length; i++ )
			{
				if ( m_objects[i] != null )
				{
					if ( !m_objects[i].getProp(qb2S_PhysicsProps.IS_SLEEPING) )
					{
						return false;
					}
				}
			}
			
			return true;
		}
		
		private function getComponent():qb2PA_JointComponent
		{
			var type:qb2E_JointType = this.getEffectiveProp(qb2S_PhysicsProps.JOINT_TYPE);
			
			return qb2PA_JointComponent.getComponent(type);
		}
		
		internal function onStepComplete_internal(stylePropStack:qb2PropMapStack):void
		{
			qb2PU_PhysicsObjectBackDoor.onStepComplete_internal(this); // effectively calling super here.
			
			qb2PU_PhysicsObjectBackDoor.onStepComplete_protected(this);
			
			qb2PU_PhysicsObjectBackDoor.depthFirst_push(this, this.getWorld().getConfig().graphics, stylePropStack, s_utilBool);
			
			if ( hasAttachmentsInWorld() )
			{
				var graphics:qb2I_Graphics2d = this.getWorld().getConfig().graphics;
				
				if ( graphics != null )
				{
					this.draw(graphics, stylePropStack.get());
				}
			}
			
			qb2PU_PhysicsObjectBackDoor.depthFirst_pop(this, stylePropStack, s_utilBool.value);
		}
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			var component:qb2PA_JointComponent = this.getComponent();
			
			if ( component != null )
			{
				component.draw(this, graphics, propertyMap_nullable);
			}
		}
		
		protected function drawAnchor(point:qb2GeoPoint, graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap):void
		{
			point.draw(graphics, propertyMap_nullable);
		}

		public function setObjectA(object_nullable:qb2A_TangibleObject):void
		{
			setObjectAtIndex(0, object_nullable);
		}
		
		public function getObjectA():qb2A_TangibleObject
		{
			return m_objects[0];
		}

		public function setObjectB(object_nullable:qb2A_TangibleObject):void
		{
			setObjectAtIndex(1, object_nullable);
		}
		
		public function getObjectB():qb2A_TangibleObject
		{
			return m_objects[1];
		}
	}
}