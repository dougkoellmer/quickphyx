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

package quickb2.physics.ai.brains
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.*
	import quickb2.lang.foundation.qb2E_ErrorCode;
	
	import quickb2.physics.ai.qb2A_SmartBody;
	
	import quickb2.lang.qb2_throw;
	import quickb2.event.*;
	import quickb2.physics.core.enums.qb2PhysicsProp;
	
	import QuickB2.objects.ai.qb2A_SmartBody;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.event.qb2EventMultiType;
	import quickb2.event.qb2EventType;
	import TopDown.*;
	import TopDown.objects.*;
	
	

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	[qb2_abstact] public class qb2A_Brain extends qb2A_PhysicsObject
	{	
		public function qb2A_Brain()
		{
			init();
		}
		
		private function init():void
		{
			include "../../../lang/macros/QB2_ABSTRACT_CLASS";
			
			setSharedBool(qb2S_PhysicsProps.JOINS_IN_DEEP_CLONING, false);
		}
		
		qb2_friend function setHost(aSmartBody:qb2A_SmartBody):void
		{
			if ( _host )
			{
				_host.brainPort.clear();
				removedFromHost();
				
				_host.removeEventListener(qb2ContainerEvent.ADDED_TO_WORLD,     hostAddedOrRemoved);
				_host.removeEventListener(qb2ContainerEvent.REMOVED_FROM_WORLD, hostAddedOrRemoved);
				
				if ( _host.world )
				{
					removedFromWorld();
				}
			}
			
			_host = aSmartBody;

			if ( _host )
			{
				addedToHost();
				
				_host.addEventListener(qb2ContainerEvent.ADDED_TO_WORLD,     hostAddedOrRemoved, null, true);
				_host.addEventListener(qb2ContainerEvent.REMOVED_FROM_WORLD, hostAddedOrRemoved, null, true);
				
				if ( _host.world )
				{
					addedToWorld();
				}
			}
		}
		
		private function hostAddedOrRemoved(evt:qb2ContainerEvent):void
		{
			if ( evt.type == qb2ContainerEvent.ADDED_TO_WORLD )
			{
				addedToWorld();
			}
			else
			{
				removedFromWorld();
			}
		}
		
		public function getHost():qb2A_SmartBody
			{  return _host;  }
		private var _host:qb2A_SmartBody;
			
		protected virtual function addedToHost():void { }
		protected virtual function removedFromHost():void { }
		protected virtual function addedToWorld():void {}
		protected virtual function removedFromWorld():void {}
	}
}