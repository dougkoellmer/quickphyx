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

package quickb2.physics.core.tangibles 
{
	import flash.display.*;
	import flash.utils.*;
	import quickb2.display.immediate.style.qb2U_Style;
	import quickb2.lang.errors.*;
	import quickb2.utils.primitives.qb2Boolean;
	import quickb2.lang.operators.*;
	import quickb2.event.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.qb2TransformStack;
	import quickb2.physics.core.bridge.qb2P_Flusher;
	import quickb2.physics.core.joints.qb2PU_JointBackDoor;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.utils.primitives.qb2Boolean;
	import quickb2.utils.primitives.qb2Float;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2PropMapStack;
	
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.events.qb2ContainerEvent;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.utils.qb2U_Geom;
	
	import quickb2.lang.*;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	
	import quickb2.physics.core.iterators.qb2ChildIterator;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.math.geo.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	[Event(name="ADDED_OBJECT",					type="quickb2.physics.core.events.qb2ContainerEvent")]
	[Event(name="REMOVED_OBJECT",				type="quickb2.physics.core.events.qb2ContainerEvent")]
	[Event(name="DESCENDANT_ADDED_OBJECT",		type="quickb2.physics.core.events.qb2ContainerEvent")]
	[Event(name="DESCENDANT_REMOVED_OBJECT",	type="quickb2.physics.core.events.qb2ContainerEvent")]
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_PhysicsObjectContainer extends qb2A_TangibleObject
	{
		private static const s_utilBool1:qb2Boolean = new qb2Boolean();
		internal static const s_childIterator:qb2ChildIterator = new qb2ChildIterator();
		
		private var m_firstChild:qb2A_PhysicsObject = null;
		private var m_lastChild:qb2A_PhysicsObject = null;
		private var m_childCount:int = 0;
		
		public function qb2A_PhysicsObjectContainer()
		{
			include "../../../lang/macros/QB2_ABSTRACT_CLASS";
		}
		
		public function getFirstChild():qb2A_PhysicsObject
		{
			return m_firstChild;
		}
		
		public function getLastChild():qb2A_PhysicsObject
		{
			return m_lastChild;
		}
		
		public function getChildCount():int
		{
			return m_childCount;
		}
			
		private static function clone_pushDictUsage():void
		{
			if ( !clone_dictUsageTracker )
			{
				clone_rigidDict = new Dictionary(false);
				clone_jointDict = new Dictionary(false);
			}
			
			clone_dictUsageTracker++;
		}
		
		private static function clone_popDictUsage():void
		{
			clone_dictUsageTracker--;
			
			if ( clone_dictUsageTracker <= 0 )
			{
				clone_jointDict = clone_rigidDict = null;
				clone_dictUsageTracker = 0;
			}
		}
		
		private static var clone_dictUsageTracker:int = 0;
		private static var clone_rigidDict:Dictionary;
		private static var clone_jointDict:Dictionary;
		
		public override function clone():*
		{
			/*var newContainer:qb2A_PhysicsObjectContainer = super.clone() as qb2A_PhysicsObjectContainer;
			newContainer.removeAllChildren(); // in case the constructor adds some objects, which it generally shouldn't, but you never know.
				
			clone_pushDictUsage();
			{
				newContainer.getSimulatedComponent().m_sharedFlags |= qb2S_PhysicsProps.IS_DEEP_CLONING; // cancels inheritance of properties for improved performance.
				{
					var iterator:qb2ChildIterator = qb2ChildIterator.getInstance(this);
					for ( var ithObject:qb2I_PhysicsObject; ithObject = iterator.next(); )
					{
						var ithObjectClone:qb2I_PhysicsObject = ithObject.clone();
						newContainer.addChild(ithObjectClone);
						
						if ( ithObject as qb2I_RigidObject )
						{
							clone_rigidDict[ithObject] = ithObjectClone;
						}
						else if ( ithObject as qb2Joint )
						{
							clone_jointDict[ithObject] = ithObjectClone;
						}
					}
				}
				newContainer.getSimulatedComponent().m_sharedFlags &= ~qb2S_PhysicsProps.IS_DEEP_CLONING;
				
				if ( clone_dictUsageTracker == 1 ) // (if this was the original object that got cloned...
				{
					for ( var key:* in clone_jointDict )
					{
						var joint:qb2Joint = key as qb2Joint;
						var clonedObject1:qb2I_RigidObject = clone_rigidDict[joint.m_objects[0]] as qb2I_RigidObject;
						var clonedObject2:qb2I_RigidObject = clone_rigidDict[joint.m_objects[1]] as qb2I_RigidObject;
						
						var clonedJoint:qb2Joint = clone_jointDict[joint];
						
						if ( !clonedJoint.m_objects[0] && clonedObject1 )
						{
							clonedJoint.setObjectAtIndex(0, clonedObject1, false);
						}
						
						if ( !clonedJoint.m_objects[1] && clonedObject2 )
						{
							clonedJoint.setObjectAtIndex(1, clonedObject2, false);
						}
						
						if ( clonedJoint.hasObjectsSet() )
						{
							delete clone_jointDict[joint];
						}
					}
				}
			}
			clone_popDictUsage();
			
			//TODO: Make qb2Body do this shit in the copy method.
			var asBody:qb2Body = newContainer as qb2Body;
			if ( newContainer as qb2Body )
			{
				var rigidComponent:qb2InternalRigidComponent = asBody.getSimulatedComponent() as qb2InternalRigidComponent;
				asBody.getPosition().copy(rigidComponent.m_position);
				asBody.setRotation(rigidComponent.m_rotation);
			}
			
			return newContainer;*/
		}
		
		private function addMultipleObjectsToList(someObjects:Array, refObject:qb2A_PhysicsObject):void
		{
			for ( var i:int = 0; i < someObjects.length; i++ )
			{
				var ithObject:qb2A_PhysicsObject = someObjects[i] as qb2A_PhysicsObject;
				
				if ( ithObject == null )
				{
					qb2U_Error.throwCode(qb2E_CompilerErrorCode.TYPE_MISMATCH);
				}
				
				if ( ithObject == this )
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.SELF_REFERENCE, "Tried to add object to itself");
				}
				
				if ( ithObject.getParent() != null )
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ALREADY_IN_USE, "Object already has a parent.");
				}
				
				//--- Link the object up with the rest of the tree.
				qb2PU_PhysicsObjectBackDoor.setParent(ithObject, this);
				
				if ( this.getAncestorBody() == null )
				{
					var thisAsBody:qb2Body = this as qb2Body;
					
					if ( thisAsBody != null )
					{
						qb2PU_PhysicsObjectBackDoor.setAncestorBody(ithObject, thisAsBody);
					}
				}
				else
				{
					qb2PU_PhysicsObjectBackDoor.setAncestorBody(ithObject, this.getAncestorBody());
				}
				
				qb2_assert(ithObject.getNextSibling() == null && ithObject.getPreviousSibling() == null);
				
				if ( refObject != null )
				{
					var old_refObject_m_previousSibling:qb2A_PhysicsObject = refObject.getPreviousSibling();
					
					qb2PU_PhysicsObjectBackDoor.setPreviousSibling(refObject, ithObject);
					qb2PU_PhysicsObjectBackDoor.setNextSibling(ithObject, refObject);
					qb2PU_PhysicsObjectBackDoor.setPreviousSibling(ithObject, old_refObject_m_previousSibling);
					
					if ( old_refObject_m_previousSibling != null )
					{
						qb2PU_PhysicsObjectBackDoor.setNextSibling(old_refObject_m_previousSibling, ithObject);
					}
					else
					{
						m_firstChild = ithObject;
					}
				}
				else if( m_lastChild != null )
				{
					var lastObject:qb2A_PhysicsObject = this.m_lastChild;
					qb2PU_PhysicsObjectBackDoor.setNextSibling(lastObject, ithObject);
					qb2PU_PhysicsObjectBackDoor.setPreviousSibling(ithObject, lastObject);
					this.m_lastChild = ithObject;
				}
				else
				{
					this.m_firstChild = this.m_lastChild = ithObject;
				}
				
				m_childCount++;
				
				qb2PU_PhysicsObjectBackDoor.invalidate(ithObject, qb2PF_DirtyFlag.ADDED_TO_CONTAINER);
			}
			
			qb2P_Flusher.getInstance().flush();
		}
		
		protected override function recomputePhysicsProps():void
		{
			if ( this.getWorld() == null ) return;
			
			super.recomputePhysicsProps();
			
			var currentObject:qb2A_PhysicsObject = this.getFirstChild();
				
			while ( currentObject != null )
			{
				qb2PU_PhysicsObjectBackDoor.recomputePhysicsProps_relay(currentObject);
				
				currentObject = currentObject.getNextSibling();
			}
		}
		
		protected override function recomputeStyleProps():void
		{
			if ( this.getWorld() == null ) return;
			
			super.recomputeStyleProps();
			
			var currentObject:qb2A_PhysicsObject = this.getFirstChild();
				
			while ( currentObject != null )
			{
				qb2PU_PhysicsObjectBackDoor.recomputeStyleProps_relay(currentObject);
				
				currentObject = currentObject.getNextSibling();
			}
		}
		
		public function addChild(... oneOrMoreChildren):void
		{
			addMultipleObjectsToList(oneOrMoreChildren, null);
		}
			
		/*public function insertChild(referenceObject:qb2A_PhysicsObject, offset:int = 0, ... oneOrMoreObjects):qb2A_PhysicsObjectContainer
		{
			return addMultipleObjectsToList(oneOrMoreObjects, index);
		}*/
		
		public function swapChildren(child1:qb2A_PhysicsObject, child2:qb2A_PhysicsObject):void
		{
			if ( child1.getParent() != this || child2.getParent() != this )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_RELATIONSHIP, "One or both of the given objects are not children of this object.");
			}
			
			var child1_previous:qb2A_PhysicsObject = child1.getPreviousSibling();
			var child1_next:qb2A_PhysicsObject = child1.getNextSibling();
			var child2_previous:qb2A_PhysicsObject = child2.getPreviousSibling();
			var child2_next:qb2A_PhysicsObject = child2.getNextSibling();
			
			qb2PU_PhysicsObjectBackDoor.setNextSibling(child1, child2_next);
			qb2PU_PhysicsObjectBackDoor.setPreviousSibling(child1, child2_previous);
			qb2PU_PhysicsObjectBackDoor.setNextSibling(child2, child1_next);
			qb2PU_PhysicsObjectBackDoor.setPreviousSibling(child2, child1_previous);
			
			if ( child1_previous != null )
			{
				qb2PU_PhysicsObjectBackDoor.setNextSibling(child1_previous, child2);
			}
			
			if ( child1_next != null )
			{
				qb2PU_PhysicsObjectBackDoor.setPreviousSibling(child1_next, child2);
			}
			
			if ( child2_previous != null )
			{
				qb2PU_PhysicsObjectBackDoor.setNextSibling(child2_previous, child1);
			}
			
			if ( child2_next != null )
			{
				qb2PU_PhysicsObjectBackDoor.setPreviousSibling(child2_next, child1);
			}
			
			if ( m_firstChild == child1 )
			{
				m_firstChild = child2;
			}
			else if ( m_firstChild == child2 )
			{
				m_firstChild = child1;
			}
			
			if ( m_lastChild == child1 )
			{
				m_lastChild = child2;
			}
			else if ( m_lastChild == child2 )
			{
				m_lastChild = child1;
			}
			
			this.dispatchOrderChanged(child1);
			this.dispatchOrderChanged(child2);
		}
		
		private function dispatchOrderChanged(child:qb2A_PhysicsObject):void
		{
			if ( child.hasEventListener(qb2ContainerEvent.ORDER_CHANGED) )
			{
				var event:qb2ContainerEvent = qb2GlobalEventPool.checkOut(qb2ContainerEvent.ORDER_CHANGED) as qb2ContainerEvent;
				event.initialize(child, this, this.getWorld());
				child.dispatchEvent(event);
			}
		}
		
		internal function spliceFromSiblings(child:qb2A_PhysicsObject):void
		{
			if ( child == m_firstChild )
			{
				m_firstChild = child.getNextSibling();
			}
			
			if ( child == m_lastChild )
			{
				m_lastChild = child.getPreviousSibling();
			}
		}

		public function removeAllChildren():void
		{
			s_childIterator.initialize(this);
			for ( var object:qb2A_PhysicsObject; (object = s_childIterator.next()) != null; )
			{
				qb2PU_PhysicsObjectBackDoor.invalidate(object, qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER);
			}
			
			m_childCount = 0;
			
			qb2P_Flusher.getInstance().flush();
		}
		
		public function removeChild(object:qb2A_PhysicsObject):void
		{
			if ( object.getParent() != this )
			{
				qb2U_Error.throwError(new Error("Tried to remove an object that is not a child of the container."));
			}
			
			qb2PU_PhysicsObjectBackDoor.invalidate(object, qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER);
			
			m_childCount--;
			
			qb2P_Flusher.getInstance().flush();
		}
		
		internal function depthFirst_push(graphics_nullable:qb2I_Graphics2d, transformStack:qb2TransformStack, rotationStack_nullable:qb2Float, stylePropStack:qb2PropMapStack, pushedStyles_out:qb2Boolean):void
		{
			qb2PU_PhysicsObjectBackDoor.depthFirst_push(this, graphics_nullable, stylePropStack, s_utilBool1);
			
			var areWeAtOrBelowTopOfRigidHierarchy:Boolean = this.getAncestorBody() != null || this.getBackEndRepresentation() != null;
			
			//--- DRK > If we're above a rigid hierarchy, we need to push the transform regardless, to sync points from back end.
			//---		If we're at or below rigid hierarchy, we only need the transform for drawing.
			if ( areWeAtOrBelowTopOfRigidHierarchy )
			{
				// TODO: Check if we are actually enabled for drawing and don't proceed if not.
				if ( graphics_nullable != null )
				{
					qb2U_Geom.pushToTransformStack(this, transformStack);
				}
			}
			else
			{
				qb2U_Geom.pushToTransformStack(this, transformStack);
				
				if ( rotationStack_nullable != null )
				{
					rotationStack_nullable.value += this.getRotation();
				}
			}
		}
		
		internal function depthFirst_pop(graphics_nullable:qb2I_Graphics2d, transformStack:qb2TransformStack, rotationStack_nullable:qb2Float, stylePropStack:qb2PropMapStack, popStyles:Boolean):void
		{
			var areWeAtOrBelowTopOfRigidHierarchy:Boolean = this.getAncestorBody() != null || this.getBackEndRepresentation() != null;
			
			if ( areWeAtOrBelowTopOfRigidHierarchy )
			{
				// TODO: Check if we are actually enabled for drawing and don't proceed.
				if ( graphics_nullable != null )
				{
					qb2U_Geom.popFromTransformStack(this, transformStack);
				}
			}
			else
			{
				qb2U_Geom.popFromTransformStack(this, transformStack);
				
				if ( rotationStack_nullable != null )
				{
					rotationStack_nullable.value -= this.getRotation();
				}
			}
			
			qb2PU_PhysicsObjectBackDoor.depthFirst_pop(this, stylePropStack, popStyles);
		}
		
		internal function onStepComplete_container(stylePropStack:qb2PropMapStack):void
		{
			qb2PU_PhysicsObjectBackDoor.onStepComplete_protected(this);
			var world:qb2World = this.getWorld();
			
			this.depthFirst_push(world.getConfig().graphics, world.getTransformStack(), world.getRotationStack(), stylePropStack, s_utilBool1);
			var pushedStyles:Boolean = s_utilBool1.value;
			{
				var currentObject:qb2A_PhysicsObject = this.getFirstChild();
				
				while ( currentObject != null )
				{
					if ( qb2U_Type.isKindOf(currentObject, qb2A_TangibleObject) )
					{
						(currentObject as qb2A_TangibleObject).onStepComplete_internal(stylePropStack);
					}
					else if ( qb2U_Type.isKindOf(currentObject, qb2Joint) )
					{
						qb2PU_JointBackDoor.onStepComplete_internal(currentObject as qb2Joint, stylePropStack);
					}
					else
					{
						qb2PU_PhysicsObjectBackDoor.onStepComplete_protected(currentObject);
					}
					
					currentObject = currentObject.getNextSibling();
				}
			}
			this.depthFirst_pop(world.getConfig().graphics, world.getTransformStack(), world.getRotationStack(), stylePropStack, pushedStyles);
		}
		
		private function draw_private(graphics:qb2I_Graphics2d, stylePropStack:qb2PropMapStack, propertyMap_nullable:qb2PropMap = null):void
		{
			this.depthFirst_push(graphics, graphics.getTransformStack(), null, stylePropStack, s_utilBool1);
			var popStyles:Boolean = s_utilBool1.value;
			
			var currentChild:qb2A_PhysicsObject = this.getFirstChild();
			
			while ( currentChild != null )
			{
				currentChild.draw(graphics, propertyMap_nullable);
				
				currentChild = currentChild.getNextSibling();
			}
			
			this.depthFirst_pop(graphics, graphics.getTransformStack(), null, stylePropStack, popStyles);
		}
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			//--- DRK > Can't think of a good way to avoid allocation here.
			var styleStack:qb2PropMapStack = new qb2PropMapStack();
			
			this.draw_private(graphics, styleStack);
		}
		
		/*public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			var debugDrawBit:uint = qb2S_PhysicsProps.IS_DEBUG_DRAWABLE.getBits();
			
			var iterator:qb2ChildIterator = qb2ChildIterator.getInstance(this);
			for ( var object:qb2A_PhysicsObject; object = iterator.next(); )
			{
				if ( object.m_sharedFlags & debugDrawBit )
				{
					object.draw(graphics);
				}
			}
			qb2ChildIterator.releaseInstance(iterator);
		}*/
	}
}