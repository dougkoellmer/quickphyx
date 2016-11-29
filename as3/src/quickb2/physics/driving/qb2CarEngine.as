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

package quickb2.physics.driving
{
	import quickb2.internals.qb2InternalTorqueCurveEntry;
	import quickb2.math.general.*;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.objects.driving.configs.qb2CarEngineConfig;
	import TopDown.*;
	import TopDown.objects.*;


	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarEngine extends qb2Body
	{
		qb2_friend var m_currentRadsPerSec:Number = 0;
		private var m_currentTorque:Number = 0;
		
		private var m_torqueEntries:Vector.<qb2InternalTorqueCurveEntry> = new Vector.<qb2InternalTorqueCurveEntry>();
		
		public function qb2CarEngine(config:qb2CarEngineConfig = null):void
		{
			init(config);
		}
		
		private function init(config:qb2CarEngineConfig):void
		{
			setConfig(config ? config : (qb2CarEngineConfig.useSharedInstanceByDefault ? qb2CarEngineConfig.getInstance() : new qb2CarEngineConfig()));
		}
		
		public function getConfig():qb2CarEngineConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2CarEngineConfig):void
		{
			m_config = config;
		}
		private var m_config:qb2CarEngineConfig = null;
		
		qb2_friend var _carBody:qb2CarBody;
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var engine:qb2CarEngine = super.clone(deep) as qb2CarEngine;
			
			engine.m_config.copy(this.m_config);
			
			for ( var i:uint = 0; i < m_torqueEntries.length; i++ )
			{
				engine.addTorqueEntry(m_torqueEntries[i].m_rpm, m_torqueEntries[i].m_torque);
			}
			
			return engine;
		}
		
		public function getRpm():Number
		{
			return qb2U_UnitConversion.radsPerSec_to_RPM(m_currentRadsPerSec);
		}
		
		public function getRadsPerSec():Number
		{
			return m_currentRadsPerSec;
		}
		qb2_friend function setRadsPerSec(value:Number):void
		{
			m_currentRadsPerSec = constrainRpm ? qb2U_Math.constrain(value, torqueCurve.minRadsPerSec, torqueCurve.maxRadsPerSec) : value;
		}
		
		public function getTorque():Number
		{
			return m_currentTorque;
		}
		
		public function throttle(quotient:Number):void
		{
			if ( !_carBody.tranny.clutchEngaged && cancelThrottleWhenShifting )
			{
				m_currentTorque = 0;
				return;
			}
			
			var rpm:Number = qb2U_UnitConversion.radsPerSec_to_RPM(m_currentRadsPerSec);
			if ( rpm >= torqueCurve.maxRPM )
			{
				if ( _carBody.kinematics.longSpeed < 0 && _carBody.brainPort.NUMBER_PORT_1 > 0 || _carBody.kinematics.longSpeed > 0 && _carBody.brainPort.NUMBER_PORT_1 < 0 )
					rpm -= 1;  // when rpm's max out, no more torque is provided...this is a problem if you're reversing at max rpms and want to change directions...so here's a little hack that drops rpms a hair to provide torque on these directions changes.
			}
			var maxTorque:Number = torqueCurve.calcTorque(rpm);
			
			m_currentTorque = maxTorque * quotient;
		}
		
		private var m_highestEntry:qb2InternalTorqueCurveEntry = null;
		
		public function getIdealRpm():Number
		{
			if ( !m_highestEntry )  return -1;
			
			return m_highestEntry.m_rpm;
		}
		
		public function addTorqueEntry(rpm:Number, torqueAtRpm:Number):void
		{
			var min:int = 0, max:int = m_torqueEntries.length;
			var splitIndex:int = (max - min) / 2;
			var found:Boolean = false;
			var newEntry:qb2InternalTorqueCurveEntry = new qb2InternalTorqueCurveEntry();
			newEntry.m_torque = torqueAtRpm;
			newEntry.m_rpm = rpm;
			while ( !found )
			{
				if ( splitIndex == min || splitIndex == max )
				{
					if ( !m_torqueEntries.length )
					{
						m_torqueEntries.push(newEntry);
					}
					else if ( rpm >= m_torqueEntries[splitIndex].m_rpm )
					{
						if ( splitIndex == m_torqueEntries.length - 1 )
						{
							m_torqueEntries.push(newEntry);
						}
						else
						{
							m_torqueEntries.splice(splitIndex + 1, 0, newEntry);
						}
					}
					
					else
					{
						if ( splitIndex == 0 )
						{
							m_torqueEntries.unshift(newEntry);
						}
						else
						{
							m_torqueEntries.splice(splitIndex, 0, newEntry);
						}
					}
					
					break;
				}
				
				if ( rpm >= m_torqueEntries[splitIndex].m_rpm )
				{
					min = splitIndex;
					splitIndex += (max - min) / 2;
				}
				else
				{
					max = splitIndex;
					splitIndex -= (max - min) / 2;
				}
			}
			
			if ( !highestEntry || torqueAtRpm > highestEntry.m_torque )
			{
				highestEntry = newEntry;
			}
		}
		
		public function calcTorque(atRpm:Number):Number
		{
			if ( m_torqueEntries.length <= 1 )  return 0;
			
			//--- Do a binary search for the closest rpm value on the curve, then linearly interpolate if needed.
			var min:int = 0, max:int = m_torqueEntries.length;
			var splitIndex:int = (max - min) / 2;
			var found:Boolean = false;
			while ( !found )
			{
				if ( splitIndex == min || splitIndex == max )
				{
					if ( splitIndex == 0 )
					{
						if( atRpm <= m_torqueEntries[splitIndex].m_rpm )
							return m_torqueEntries[splitIndex].torque;
						else
							return interpolateTorque(atRpm, m_torqueEntries[splitIndex], m_torqueEntries[splitIndex + 1]);
					}
					else if ( splitIndex == m_torqueEntries.length - 1)
					{
						if ( atRpm >= m_torqueEntries[splitIndex].m_rpm )
						{
							return 0; // effectively we're past the engine's highest RPM rating, meaning in real life the engine would probably explode...so i think zero torque is appropriate
						}
						else
							return interpolateTorque(atRpm, m_torqueEntries[splitIndex-1], m_torqueEntries[splitIndex]);
					}
					else
					{
						if ( atRpm < m_torqueEntries[splitIndex].m_rpm )
							return interpolateTorque(atRPM, m_torqueEntries[splitIndex-1], m_torqueEntries[splitIndex]);
						else
							return interpolateTorque(atRpm, m_torqueEntries[splitIndex], m_torqueEntries[splitIndex + 1]);
					}
				}
				
				if ( atRpm >= m_torqueEntries[splitIndex].m_rpm )
				{
					min = splitIndex;
					splitIndex += (max - min) / 2;
				}
				else
				{
					max = splitIndex;
					splitIndex -= (max - min) / 2;
				}
			}
			return 0;
		}
		
		private function interpolateTorque(rpm:Number, entry1:qb2InternalTorqueCurveEntry, entry2:qb2InternalTorqueCurveEntry):Number
		{
			var ratio:Number = (rpm - entry1.m_rpm) / (entry2.RPM - entry1.m_rpm);
			
			return entry1.m_torque + (entry2.m_torque - entry1.m_torque) * ratio;
		}
		
		public function getTorqueEntryCount():uint
		{
			return m_torqueEntries.length;
		}
		
		public function getMinRpm():Number
		{
			if ( !m_torqueEntries.length )  return NaN;
			
			return m_torqueEntries[0].m_rpm;
		}
		
		public function getMaxRpm():Number
		{
			if ( !m_torqueEntries.length )  return NaN;
			return m_torqueEntries[m_torqueEntries.length - 1].m_rpm;
		}
		
		public function getMinRadsPerSec():Number
		{
			if ( !m_torqueEntries.length )  return NaN;
			
			return qb2U_UnitConversion.RPM_tom_currentRadsPerSec(m_torqueEntries[0].m_rpm);
		}
		
		public function getMaxRadsPerSec():Number
		{
			if ( !m_torqueEntries.length )  return NaN;
			
			return qb2U_UnitConversion.RPM_tom_currentRadsPerSec(m_torqueEntries[m_torqueEntries.length - 1].m_rpm);
		}
	}
}

class qb2InternalTorqueCurveEntry extends Object
{
	qb2_friend var m_torque:Number = 0, m_rpm:Number = 0;
}