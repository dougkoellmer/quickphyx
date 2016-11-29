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

package quickb2.physics.extras
{
	import flash.utils.Dictionary;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.events.*;
	import quickb2.math.geo.*;
	import quickb2.lang.*;
	
	import quickb2.debugging.*;
	import quickb2.debugging.drawing.qb2S_DebugDraw;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.event.*;
	
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	import quickb2.physics.core.tangibles.*;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventType;
	
	
	
	[Event(name="SENSOR_TRIPPED", type="quickb2.event.qb2TripSensorEvent")]
	[Event(name="SENSOR_ENTERED", type="quickb2.event.qb2TripSensorEvent")]
	[Event(name="SENSOR_EXITED",  type="quickb2.event.qb2TripSensorEvent")]
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2TripSensor extends qb2Body
	{
		public var triggers:Array = null;
		
		public var tripTime:Number = 0;
		
		private const contactList:Dictionary = new Dictionary();
		
		private var _numVisitors:uint = 0;
		private var _numTrippedVisitors:uint  = 0;
		
		public function qb2TripSensor()
		{
			super();
			//init();
		}
		
		/*private function init():void
		{
			addEventListener(qb2ContactEvent.CONTACT_STARTED, started,    null, true);
			addEventListener(qb2ContactEvent.CONTACT_ENDED,   ended,      null, true);
			addEventListener(qb2StepEvent.POST_STEP,      postUpdate, null, true);
			
			setSharedBoolean(qb2S_PhysicsProps.IS_GHOST, true, true);
		}
		
		public override function clone():*
		{
			var cloned:qb2TripSensor = super.clone() as qb2TripSensor;
			
			cloned.tripTime = this.tripTime;
			
			return cloned;
		}
		
		private function ignore(tang:qb2A_TangibleObject):Boolean
		{
			if ( !triggers )  return false;
			
			for (var i:int = 0; i < triggers.length; i++) 
			{
				var trigger:Object = triggers[i];
				
				if ( trigger is Class )
				{
					if ( tang is (trigger as Class) )
					{
						return false;
					}
				}
				else
				{
					if ( tang == trigger )
					{
						return false;
					}
				}
			}
			
			return true;
		}
		
		private function started(evt:qb2ContactEvent):void
		{
			var visitingObject:qb2A_PhysicsObject = evt.getOtherObject() as qb2A_PhysicsObject;
			var visitingShape:qb2Shape = evt.getOtherShape();
			
			if ( ignore(evt.getOtherObject()) )  return;
			
			var firstContact:Boolean = false;
			var theContact:qb2InternalTripSensorContact;
			if ( !contactList[visitingObject] )
			{
				const newContact:qb2InternalTripSensorContact = new qb2InternalTripSensorContact(getWorld().getClock());
				newContact.visitingObject = evt.getOtherObject();
				theContact = newContact;
				contactList[visitingObject] = newContact;
				newContact.shapeList[visitingShape] = 1;
				_numVisitors++;
				newContact.shapeCount++;
				
				firstContact = true;
			}
			else
			{
				const contact:qb2InternalTripSensorContact = contactList[visitingObject];
				theContact = contact;
				if ( contact.shapeList[visitingShape] )
					contact.shapeList[visitingShape]++;
				else
				{
					contact.shapeCount++;
					contact.shapeList[visitingShape] = 1;
				}
			}
			
			if ( firstContact )
			{
				fireEvent(qb2TripSensorEvent.SENSOR_ENTERED, theContact, false);
				
				if ( tripTime == 0 )
				{
					fireEvent(qb2TripSensorEvent.SENSOR_TRIPPED, theContact, true);
				}
			}
		}
		
		private function ended(evt:qb2ContactEvent):void
		{
			var visitingObject:qb2A_PhysicsObject = evt.getOtherObject() as qb2A_PhysicsObject;
			var visitingShape:qb2Shape = evt.getOtherShape();
	
			if ( ignore(evt.getOtherObject()) && !contactList[visitingObject] )
			{
				return;
			}
			
			if ( !contactList[visitingObject] )
			{
				qb2_throw(new Error("Leaving object never entered."));
			}
			
			var contact:qb2InternalTripSensorContact = contactList[visitingObject];
			
			if ( !contact.shapeList[visitingShape] )  qb2_throw(new Error("Oops, visiting shape wasn't found"));
			
			contact.shapeList[visitingShape]--;
			
			if ( contact.shapeList[visitingShape] == 0 )
			{
				contact.shapeCount--;
				delete contact.shapeList[visitingShape];
				
				if ( contact.shapeCount == 0 )
				{
					delete contactList[visitingObject];
					_numVisitors--;
					
					if ( contact.trippedSensor )
						_numTrippedVisitors--;
					
					fireEvent(qb2TripSensorEvent.SENSOR_EXITED, contact, false);
				}
			}
		}
		
		private function fireEvent(type:qb2EventType, contact:qb2InternalTripSensorContact, tripper:Boolean):void
		{
			var event:qb2TripSensorEvent = qb2GlobalEventPool.checkOut(type) as qb2TripSensorEvent;
			event.m_sensor = this;
			event.m_visitingObject = contact.visitingObject;
			event.m_startTime = contact.startTime;
			dispatchEvent(event);
			
			if ( tripper )
			{
				contact.trippedSensor = true;
				_numTrippedVisitors++;
			}
		}
		
		private function postUpdate(evt:qb2StepEvent):void
		{
			var clock:Number = getWorld().getElapsedTime();
			
			for ( var key:* in contactList )
			{
				var contact:qb2InternalTripSensorContact = contactList[key];
				if ( !contact.trippedSensor )
				{
					if ( clock - contact.startTime > tripTime )
					{
						fireEvent(qb2TripSensorEvent.SENSOR_TRIPPED, contact, true);
					}
				}
			}
		}
		
		public function getVisitorCount():uint
		{
			return _numVisitors;
		}
		
		public function getTrippedVisitorCount():uint
		{
			return _numTrippedVisitors;
		}
		
		/*public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			graphics.pushFillColor(qb2S_DebugDraw.tripSensorFillColor | qb2S_DebugDraw.fillAlpha);
			{
				super.drawDebug(graphics);
			}
			graphics.popFillColor();
		}*/
		
		public override function convertTo(T:Class):* 
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this);
			}
			
			return super.convertTo(T);
		}
	}
}

import flash.utils.Dictionary;

import quickb2.physics.core.tangibles.*;




class qb2InternalTripSensorContact
{
	public var visitingObject:qb2A_TangibleObject;
	
	public const shapeList:Dictionary = new Dictionary();
	
	public var shapeCount:int = 0;
	
	public var startTime:Number = 0;
	
	public var trippedSensor:Boolean = false;
	
	public function qb2InternalTripSensorContact(initStartTime:Number):void
	{
		startTime = initStartTime;
	}
}