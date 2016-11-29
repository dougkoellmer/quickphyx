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
	import quickb2.lang.*
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	
	import quickb2.physics.extras.qb2TripSensor;
	
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventMultiType;
	import quickb2.event.qb2EventType;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2TripSensorEvent extends qb2Event
	{
		public static const SENSOR_TRIPPED:qb2EventType 		 = new qb2EventType("SENSOR_TRIPPED", prototype.constructor);
		public static const SENSOR_ENTERED:qb2EventType 		 = new qb2EventType("SENSOR_ENTERED", prototype.constructor);
		public static const SENSOR_EXITED:qb2EventType  		 = new qb2EventType("SENSOR_EXITED",  prototype.constructor);
		
		public static const ALL_EVENT_TYPES:qb2EventType		 = new qb2EventMultiType(SENSOR_TRIPPED, SENSOR_ENTERED, SENSOR_EXITED);
		
		private var m_sensor:qb2TripSensor;
		
		private var m_visitingObject:qb2A_TangibleObject;
		
		private var m_startTime:Number;
		
		public function qb2TripSensorEvent(type_nullable:qb2EventType = null) 
		{
			super(type);
		}
		
		public function getTripSensor():qb2TripSensor
		{
			return m_sensor;
		}
		
		public function getVisitingObject():qb2A_TangibleObject
		{
			return m_visitingObject;
		}
		
		public function getVisitingStartTime():Number
		{
			return m_startTime;
		}
		
		public override function clone():*
		{
			var evt:qb2TripSensorEvent = super.clone() as qb2TripSensorEvent;
			evt.m_sensor = m_sensor;
			evt.m_visitingObject = m_visitingObject;
			evt.m_startTime = m_startTime;
			
			return evt;
		}
		
		protected override function clean():void
		{
			super.clean();
			
			m_sensor = null;
			m_visitingObject = null;
			m_startTime = 0;
		}
		
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