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
	import quickb2.math.qb2U_Math;
	import quickb2.math.qb2U_Units;
	import quickb2.math.geo.*;
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.event.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.events.*;
	import quickb2.lang.*;
	
	
	
	/**
	 * A body that will snap to a given point and rotation, with optional easing.
	 * This class provides the walls used by qb2WindowWalls.
	 * It is assumed that this body is kept at zero mass.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2FollowBody extends qb2Body
	{
		private static const s_utilVector:qb2GeoVector = new qb2GeoVector();
		
		private const m_targetPosition:qb2GeoPoint = new qb2GeoPoint();
		
		private var m_targetRotation:Number = 0;
		
		private var m_config:qb2FollowBodyConfig = null;
		
		public function qb2FollowBody(config_nullable:qb2FollowBodyConfig = null)
		{
			init(config_nullable);
		}
		
		private function init(config_nullable:qb2FollowBodyConfig):void
		{
			addEventListener(qb2StepEvent.PRE_STEP, onPreStep, true);
			
			setConfig(config_nullable != null ? config_nullable :  new qb2FollowBodyConfig());
		}
		
		public function getConfig():qb2FollowBodyConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2FollowBodyConfig):void
		{
			m_config = config;
		}
		
		public function getTargetRotation():Number
		{
			return m_targetRotation;
		}
		public function setTargetRotation(value:Number):void
		{
			m_targetRotation = qb2U_Math.normalizeAngle(value);
		}
		
		public function getTargetPosition():qb2GeoPoint
		{
			return m_targetPosition;
		}
		
		public function setTargetPosition(x:Number, y:Number):void
		{
			m_targetPosition.set(x, y, 0);
		}
		
		private function onPreStep(evt:qb2StepEvent):void
		{
			var timeStep:Number = this.getWorld().getTelemetry().getCurrentTimeStep();
			
			m_targetPosition.calcDelta(this.getPosition(), s_utilVector);
			var distanceSquared:Number = s_utilVector.calcLengthSquared();
			var distance:Number = Math.sqrt(distanceSquared);
			
			if ( distance < m_config.linearSnapTolerance )
			{
				this.getPosition().copy(m_targetPosition);
				this.getLinearVelocity().zeroOut(); // zero out the velocity.
			}
			else
			{
				var mag:Number = distance / (1 + 1);
				
				if ( mag > m_config.maxLinearVelocity )
				{
					s_utilVector.setLength(m_config.maxLinearVelocity);
				}
				
				getLinearVelocity().copy(s_utilVector);
			}
			
			
			var angleDiff:Number = m_targetRotation - this.getRotation();
			
			if ( Math.abs(angleDiff) < m_config.angularSnapTolerance )
			{
				setRotation(m_targetRotation);
				setAngularVelocity(0);
			}
			else
			{
				var angMag:Number = angleDiff / (2);
				angMag = Math.abs(angMag) > m_config.maxAngularVelocity ? qb2U_Math.normalizeValue(angMag)*m_config.maxAngularVelocity : angMag;
				setAngularVelocity(angMag / getWorld().getTelemetry().getCurrentTimeStep() );
			}
		}
		
		protected override function copy_protected(source:*):void
		{
			super.copy_protected(source);
			
			var asFollowBody:qb2FollowBody = source as qb2FollowBody;
			
			if ( asFollowBody != null )
			
			this.m_targetPosition.copy(asFollowBody.m_targetPosition);
			this.m_targetRotation = asFollowBody.m_targetRotation;
			this.m_config.copy(asFollowBody.m_config);
		}
	}
}