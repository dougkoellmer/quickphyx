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

package quickb2.physics.fields 
{
	
	import quickb2.math.general.*;
	import quickb2.math.geo.*;
	import flash.utils.*;
	import quickb2.debugging.*;
	import quickb2.debugging.logging.*;
	
	
	import quickb2.physics.core.*;
	import quickb2.physics.core.tangibles.*;
	import quickb2.objects.effects.configs.qb2VibratorFieldConfig;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2VibratorField extends qb2A_EffectField
	{
		public function qb2VibratorField(config:qb2VibratorFieldConfig = null)
		{
			init(config);
		}
		
		private function init(config:qb2VibratorFieldConfig):void
		{
			frequencyHz =  1.0 / 60.0;
			
			setConfig(config ? config : (qb2VibratorFieldConfig.useSharedInstanceByDefault ? qb2VibratorFieldConfig.getInstance() : new qb2VibratorFieldConfig()));
		}
		
		public function getConfig():qb2VibratorFieldConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2VibratorFieldConfig):void
		{
			m_config = config;
		}
		private var m_config:qb2VibratorFieldConfig = null;
		
		public function get frequencyHz():Number
			{  return getProperty(qb2S_PhysicsProps.FREQUENCY_HZ) as Number;  }
		public function set frequencyHz(value:Number):void
			{  setProp(qb2S_PhysicsProps.FREQUENCY_HZ, value);  }
		
		public var vibrationDirection:qb2GeoVector = new qb2GeoVector(1, 0);
		
		private static const impulseVector:qb2GeoVector = new qb2GeoVector();
		
		private var lastVibrationTimes:Dictionary = new Dictionary(true);
		
		public override function applyToRigid(rigid:qb2I_RigidObject):void
		{
			var currTime:Number = world ? world.clock : 0;
			
			lastVibrationTimes[rigid] = lastVibrationTimes[rigid] ? lastVibrationTimes[rigid]: 0;
			var sign:Number = lastVibrationTimes[rigid] >= 0 ? 1 : -1;
			var elapsed:Number = currTime - Math.abs(lastVibrationTimes[rigid]);
			
			var modifier:Number = 1;
			if ( elapsed > frequencyHz * 4 || !lastVibrationTimes[rigid] )
			{
				 modifier = .5;
			}
			
			if ( elapsed > frequencyHz )
			{
				impulseVector.copy(vector);
				impulseVector.scale(qb2U_Math.getRandFloat(minImpulse, maxImpulse) * sign * modifier);
				
				if ( randomizeImpulse )
				{
					impulseVector.rotate(Math.random() * (qb2S_Math.PI * 2));
				}
				
				if ( scaleImpulsesByMass )
				{
					impulseVector.scale(rigid.mass);
				}
				
				if ( rigid.ancestorBody )
				{
					rigid.ancestorBody.applyLinearImpulse(rigid.parent.calcWorldPoint(rigid.centerOfMass), impulseVector);
				}
				else
				{
					rigid.applyLinearImpulse(rigid.centerOfMass, impulseVector);
				}
				
				lastVibrationTimes[rigid] = currTime * -sign;
			}
		}
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var cloned:qb2VibratorField = super.clone(deep) as qb2VibratorField;
			
			cloned.m_config.copy(this.m_config);
			
			cloned.vector = this.vector ? this.vector.clone() : null;
			
			return cloned;
		}
		
		//public override function convertTo(T:Class):* 
		//	{  return qb2U_ToString.auto(this, "qb2VibratorField");  }
		
	}
}