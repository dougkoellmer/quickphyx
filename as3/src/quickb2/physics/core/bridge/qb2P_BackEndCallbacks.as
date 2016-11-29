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

package quickb2.physics.core.bridge
{	
	import quickb2.physics.core.backend.*;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventType;
	import quickb2.lang.*;
	import quickb2.physics.core.backend.qb2I_BackEndCallbacks;
	import quickb2.physics.utils.qb2U_Family;
	
	import quickb2.debugging.*;
	import quickb2.debugging.logging.*;
	import quickb2.event.*;
	import quickb2.physics.core.iterators.qb2AncestorIterator;
	import quickb2.physics.core.backend.*;
	import quickb2.physics.core.*;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.tangibles.*;
	import quickb2.physics.core.events.*;

	

	/**
	 * ...
	 * @author Doug Koellmer
	 * @private
	 */
	public class qb2P_BackEndCallbacks extends Object implements quickb2.physics.core.backend.qb2I_BackEndCallbacks
	{
		private var CONTACT_STARTED:qb2EventType, CONTACT_ENDED:qb2EventType, PRE_SOLVE:qb2EventType, POST_SOLVE:qb2EventType;
		private var SUB_CONTACT_STARTED:qb2EventType, SUB_CONTACT_ENDED:qb2EventType, SUB_PRE_SOLVE:qb2EventType, SUB_POST_SOLVE:qb2EventType;
		
		private const m_ancestorIterator:qb2AncestorIterator = new qb2AncestorIterator();
		
		public function qb2P_BackEndCallbacks()
		{
			CONTACT_STARTED 		 = qb2ContactEvent.CONTACT_STARTED;
			CONTACT_ENDED   		 = qb2ContactEvent.CONTACT_ENDED;
			PRE_SOLVE       		 = qb2ContactEvent.PRE_SOLVE;
			POST_SOLVE      		 = qb2ContactEvent.POST_SOLVE;
			
			SUB_CONTACT_STARTED 	 = qb2SubContactEvent.SUB_CONTACT_STARTED;
			SUB_CONTACT_ENDED   	 = qb2SubContactEvent.SUB_CONTACT_ENDED;
			SUB_PRE_SOLVE       	 = qb2SubContactEvent.SUB_PRE_SOLVE;
			SUB_POST_SOLVE      	 = qb2SubContactEvent.SUB_POST_SOLVE;
		}
		
		private function dispatchSubContactEvent(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact, type:qb2EventType):void
		{
			m_ancestorIterator.initialize(shape1);
			
			for ( var ancestor:qb2A_PhysicsObjectContainer; (ancestor = m_ancestorIterator.next()) != null; )
			{
				if ( qb2U_Family.isDescendantOf(shape2, ancestor)  )
				{
					var subEvent:qb2SubContactEvent = qb2GlobalEventPool.checkOut(type) as qb2SubContactEvent;
					
					subEvent.initialize(contact);
					
					ancestor.dispatchEvent(subEvent);
				}
			}
		}
		
		private function dispatchContactEvent(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact, type:qb2EventType):void
		{
			m_ancestorIterator.initialize(shape1, qb2A_TangibleObject, false);
			
			for ( var ancestor:qb2A_TangibleObject; (ancestor = m_ancestorIterator.next()) != null; )
			{
				if( ancestor.hasEventListener(type) )
				{
					var ancestorAsGroup:qb2Group = ancestor as qb2Group;
					if ( ancestorAsGroup != null )
					{
						if ( qb2U_Family.isDescendantOf(shape1, ancestorAsGroup) && qb2U_Family.isDescendantOf(shape2, ancestorAsGroup ) )
						{
							//currParent = currParent.m_lastParent;
							break; // contact events aren't dispatched when the dispatcher is a group containing the two shapes that contacted.
						}
					}
					
					var event:qb2ContactEvent = qb2GlobalEventPool.checkOut(type) as qb2ContactEvent;
					event.initialize(contact);
					
					ancestor.dispatchEvent(event);
				}
			}
		}
		
		private function isDestroyed(shape:qb2Shape):Boolean
		{
			var node:qb2P_FlushNode = qb2P_Flusher.getInstance().getFlushTree().getNode(shape);
			
			return node != null && node.hasAnyDirtyFlag(qb2PF_DirtyFlag.NEEDS_DESTROYING);
		}
		
		private function isEitherDestroyed(shape1:qb2Shape, shape2:qb2Shape):Boolean
		{
			return isDestroyed(shape1) || isDestroyed(shape2);
		}
		
		private function process(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact, subContactType:qb2EventType, contactType:qb2EventType):void
		{
			if ( isEitherDestroyed(shape1, shape2) )  return;
			
			dispatchSubContactEvent(shape1, shape2, contact, subContactType);
			dispatchContactEvent(shape1, shape2, contact, contactType);
			dispatchContactEvent(shape2, shape1, contact, contactType);
		}
		
		public function contactStarted(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact):void
		{
			process(shape1, shape2, contact, qb2SubContactEvent.SUB_CONTACT_STARTED, qb2ContactEvent.CONTACT_STARTED);
		}
		
		public function contactEnded(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact):void
		{
			process(shape1, shape2, contact, qb2SubContactEvent.SUB_CONTACT_ENDED, qb2ContactEvent.CONTACT_ENDED);
		}
		
		public function preContact(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact):void
		{
			process(shape1, shape2, contact, qb2SubContactEvent.SUB_PRE_SOLVE, qb2ContactEvent.PRE_SOLVE);
		}
		
		public function postContact(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact):void
		{
			process(shape1, shape2, contact, qb2SubContactEvent.SUB_POST_SOLVE, qb2ContactEvent.POST_SOLVE);
		}
		
		public function onJointRepresentationImplicitlyDestroyed(joint:qb2Joint):void 
		{
			qb2PU_PhysicsObjectBackDoor.setBackEndRepresentation(joint, null);
		}
		
		public function onShapeRepresentationImplicitlyDestroyed(shape:qb2Shape):void 
		{
			qb2PU_PhysicsObjectBackDoor.setBackEndRepresentation(shape, null);
		}
	}
}