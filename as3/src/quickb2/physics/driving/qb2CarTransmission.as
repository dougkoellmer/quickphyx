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
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.objects.driving.configs.qb2CarTransmissionConfig;
	import quickb2.objects.driving.qb2CarTire;
	import quickb2.objects.driving.support.qb2CarTransmissionConfig;
	import quickb2.qb2_friend;
	import TopDown.*;
	import TopDown.objects.*;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarTransmission extends qb2Body
	{
		// 3.5, 3.5, 3, 2.5, 2, 1.5, 1
		
		private var m_shiftStartTime:Number = 0;
		protected var _clutchEngaged:Boolean = true;
		private var m_config:qb2CarTransmissionConfig = null;		
		
		public function qb2CarTransmission(config_nullable:qb2CarTransmissionConfig = null)
		{
			init(config_nullable);
		}
		
		private function init(config:qb2CarTransmissionConfig):void
		{
			setConfig(config ? config : (qb2CarTransmissionConfig.useSharedInstanceByDefault ? qb2CarTransmissionConfig.getInstance() : new qb2CarTransmissionConfig()));
		}
		
		public function isClutchEngaged():Boolean
		{
			return _clutchEngaged;
		}
		
		public function getConfig():qb2CarTransmissionConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2CarTransmissionConfig):void
		{
			m_config = config;
		}
		
		
		
		qb2_friend var _carBody:qb2CarBody;
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var tranny:qb2CarTransmission = super.clone(deep) as qb2CarTransmission;
			
			tranny.m_config.copy(this.m_config);
			
			return tranny;
		}
		
		private var _lastForwardBack:Number = 0;
		
		protected override function update():void
		{
			var forwardBack:Number = _carBody.brainPort.NUMBER_PORT_1;
			var shiftAccumulator:int = _carBody.brainPort.INTEGER_PORT_1;
			
			if ( _lastForwardBack >= 0 && forwardBack < 0 )
			{
				shift(0);  // shift to reverse if brain switched from froward to back.
			}
			else if ( _lastForwardBack <= 0 && forwardBack > 0 )
			{
				if ( currGear == 0 )
				{
					shiftToOptimalGear(true, true);  // shift to forward if player switched from down arrow to up arrow.
				}
			}
			else if ( _targetGear != _currGear )
			{
				if ( _carBody.world.clock - m_shiftStartTime >= shiftTime )
				{
					_currGear = _targetGear;
					
					_clutchEngaged = true;
				}
			}
			else
			{
				if ( _targetGear != 0 )
				{
					if ( transmissionType == TRANNY_MANUAL )
					{
						var gear:int = targetGear + shiftAccumulator;
						if ( gear < 1 ) gear = 1;
						else if ( gear > numGears - 1 )  gear = numGears - 1;
						
						if ( gear != targetGear )  shift(gear);
						
						_carBody.brainPort.INTEGER_PORT_1 = 0; // zero out the shift accumulator.
					}
					else if ( transmissionType == TRANNY_AUTOMATIC )
					{
						shiftToOptimalGear();
					}
				}
			}
			
			_lastForwardBack = forwardBack;
		}
		
		public function isInReverse():Boolean
			{  return _currGear == 0;  }
		
		public function getTargetGear():uint
			{  return _targetGear;  }
		protected var _targetGear:uint = 1;
		
		public function getCurrGear():uint
			{  return _currGear;  }
		protected var _currGear:uint = 1;
		
		public function shift(toGear:uint):void
		{
			//if ( !shiftingInterruptible && _currGear != _targetGear )  return;
	
			if ( shiftTime == 0 || _currGear == toGear )
			{
				_currGear = _targetGear = toGear;
				_clutchEngaged = true;
			}
			else
			{
				if ( toGear == _targetGear )  return;
				
				m_shiftStartTime = _carBody.world.clock;
				_targetGear = toGear;
				_clutchEngaged = false;
			}
		}
		
		public function shiftToOptimalGear(forwardOnly:Boolean = true, overrideIfInReverse:Boolean = false ):void
		{
			if ( !overrideIfInReverse && inReverse )  return;
		
			var bestGear:uint = 1;
			var longSpeed:Number = _carBody._kinematics._longSpeed;
			if ( longSpeed < 0 )
			{
				if ( !forwardOnly )
					bestGear = 0;
			}
			else
			{
				var linearSpeed:Number = longSpeed;
				var avgMetricRadius:Number = calcAvgMetricTireRadius();
				var estimatedTireRotSpeed:Number = avgMetricRadius ? linearSpeed / avgMetricRadius : 0;
				var idealRPM:Number = _carBody.engine.torqueCurve.idealRPM;
				var lowestRPMDiff:Number = -1;
				var bestIndex:int = -1;
				var numGears:int = gearRatios.length;
				for ( var i:uint = 1; i < numGears; i++ )
				{
					var engineRPM:Number = qb2U_UnitConversion.radsPerSec_to_RPM(estimatedTireRotSpeed * gearRatios[i] * differential);
					var diff:Number = Math.abs(engineRPM - idealRPM);
					if ( lowestRPMDiff < 0 || diff < lowestRPMDiff )
					{
						lowestRPMDiff = diff;
						bestIndex = i;
					}
				}
				if ( bestIndex > 0 )  bestGear = bestIndex;
			}
			
			shift(bestGear)
		}
		
		private function calcAvgMetricTireRadius():Number
		{
			var total:Number = 0;
			var count:int  = 0;
			for (var i:int = 0; i < _carBody.tires.length; i++ )
			{
				var tire:qb2CarTire = _carBody.tires[i];
				if ( tire.getConfig().isDriven )
				{
					var metricRadius:Number = tire.getRadius() / tire.getWorld().getConfig().pixelsPerMeter;
					total += metricRadius;
					count++;
				}
			}
			
			return count ? total / count : 0;
		}
	
		public function shiftUp():void
		{
			if ( _currGear == 0 )  return;
		
			if ( _currGear < gearRatios.length - 1 )
				shift(_currGear + 1);
		}
			
		public function shiftDown():void
		{
			if ( _currGear == 0 )  return;
		
			if( _currGear > 1 )
				shift(_currGear-1);
		}
			
		public function getCurrentGearRatio():Number
			{  return gearRatios.length ? gearRatios[_currGear] : 0;  }
		
		public function calcTireTorque(engineTorque:Number):Number
		{
			return ((engineTorque * currGearRatio) * differential) * efficiency;
		}
		
		/// Does the conversion from engine radians per second to tire radians per second.
		public function calcRadsPerSec(input:Number):Number
		{
			return (input / currGearRatio) / differential;
		}
		
		/// Does the conversion from tire radians per second to engine radians per second.
		public function calcInverseRadsPerSec(input:Number):Number
		{
			return (input * currGearRatio) * differential;
		}
	}
}