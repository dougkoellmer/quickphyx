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

package quickb2.physics.core.joints.old
{
	import quickb2.event.qb2MathEvent;
	
	import quickb2.math.*;
	import quickb2.math.general.*;
	import quickb2.math.geo.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Joints.*;
	import flash.display.*;
	import quickb2.lang.*
	import quickb2.debugging.*;
	import quickb2.lang.foundation.qb2E_ErrorCode;
	import quickb2.lang.qb2_throw;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.enums.qb2PhysicsProp;
	import quickb2.physics.core.enums.qb2PhysicsProp;
	import quickb2.physics.core.joints.qb2I_JointWithSpring;
	import quickb2.physics.core.joints.qb2I_JointWithTwoWorldAnchors;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.style.qb2PSEUDOTYPE;
	import quickb2.display.immediate.style.qb2StyleParam;
	
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2World;
	
	import quickb2.drawing.qb2I_Graphics2d;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2PistonJoint extends qb2Joint
	{		
		//--- It seems that if you set the lower and upper translations equal on a piston or line joint, it makes the joint get stuck at 0.
		//--- It seems that they need to be offset by *just* over a centimeter for this not to happen, so this number fixes that.
		private static const IDENTICAL_LIMIT_CORRECTION:Number = .01001; // (in meters)
		
		private const m_localDirection:qb2GeoVector = new qb2GeoVector();
	
		public function qb2PistonJoint(objectA:qb2I_RigidObject = null, objectB:qb2I_RigidObject = null, worldAnchorA:qb2GeoPoint = null, worldAnchorB:qb2GeoPoint = null)
		{
			init(objectA, objectB);
			
			setWorldAnchorA(initWorldAnchorA ? initWorldAnchorA : initWorldPoint(objectA));
			setWorldAnchorB(initWorldAnchorB ? initWorldAnchorB : initWorldPoint(objectB));
		}
			
		/*protected override function propertyChanged(propertyEnum:int):void
		{
			if ( !jointB2 )  return;
			
			var value:Number = _propertyMap[propertyName];
			
			if ( propertyName == qb2S_PhysicsProps.MAX_FORCE )
			{
				if ( !callingFromUpdate && optimizedSpring && springK )
					qb2_throw(new qb2Error(qb2E_ErrorCode.OPT_SPRING_MISUSAGE));
				
				if ( jointB2 is b2PrismaticJoint )
				{
					prisJoint.SetMaxMotorForce(value);
					prisJoint.EnableMotor(value ? true : false);
				}
				else if ( jointB2 is b2LineJoint )
				{
					lineJoint.SetMaxMotorForce(value);
					lineJoint.EnableMotor(value ? true : false);
				}
				
				wakeUpAttached();
			}
			else if ( propertyName == qb2S_PhysicsProps.TARGET_SPEED )
			{
				if ( !callingFromUpdate && optimizedSpring && springK )
					qb2_throw(new qb2Error(qb2E_ErrorCode.OPT_SPRING_MISUSAGE));
					
				if ( jointB2 is b2PrismaticJoint )
				{
					prisJoint.SetMotorSpeed(value);
				}
				else if ( jointB2 is b2LineJoint )
				{
					lineJoint.SetMotorSpeed(value);
				}
						
				wakeUpAttached();
			}
			else if ( propertyName == qb2S_PhysicsProps.REFERENCE_ANGLE )
			{
				if ( jointB2 is b2PrismaticJoint )
				{
					prisJoint.m_refAngle = value;
				}
				
				wakeUpAttached();
			}
			else if ( propertyName == qb2S_PhysicsProps.LOWER_LIMIT || propertyName == qb2S_PhysicsProps.UPPER_LIMIT )
			{
				updateLimits();
				wakeUpAttached();
			}
			else
			{
				wakeUpAttached();
			}
		}*/
		
		public function getLocalDirection():qb2GeoVector
		{
			return m_localDirection;
		}
		
		qb2_friend override function anchorUpdated(point:qb2GeoPoint):void
		{
			correctLocals();
			updateDirectionAndSpringLength();
		}
		
		/*qb2_friend override function correctLocals():void
		{
			if ( jointB2 )
			{
				var conversion:Number = worldPixelsPerMeter;
				
				correctLocalVec();
				
				var corrected1:qb2GeoPoint = getCorrectedLocal1(conversion, conversion);
				var corrected2:qb2GeoPoint = getCorrectedLocal2(conversion, conversion);
				
				
				if ( jointB2 is b2PrismaticJoint )
				{
					prisJoint.mm_localAnchor1.x = corrected1.x;
					prisJoint.mm_localAnchor1.y = corrected1.y;
					prisJoint.mm_localAnchor2.x = corrected2.x;
					prisJoint.mm_localAnchor2.y = corrected2.y;
				}
				else if ( jointB2 is b2LineJoint )
				{
					lineJoint.mm_localAnchor1.x = corrected1.x;
					lineJoint.mm_localAnchor1.y = corrected1.y;
					lineJoint.mm_localAnchor2.x = corrected2.x;
					lineJoint.mm_localAnchor2.y = corrected2.y;
				}
			}
		}*/
		
		private function getCorrectedLocalVec():qb2GeoVector
		{
			return _object1._bodyB2 ? _localDirection : _object1.getWorldVector(_localDirection, _object1.m_ancestorBody);
		}
		
		private function correctLocalVec():void
		{
			//--- Be thankful you don't have to deal with this.
			if ( jointB2 )
			{
				var correctedVec:qb2GeoVector = getCorrectedLocalVec();
				
				if ( jointB2 is b2PrismaticJoint )
				{
					prisJoint.m_localXAxis1.x = correctedVec.x;
					prisJoint.m_localXAxis1.y = correctedVec.y;
					prisJoint.m_localYAxis1.x = -prisJoint.m_localXAxis1.y;
					prisJoint.m_localYAxis1.y =  prisJoint.m_localXAxis1.x;
				}
				else
				{
					lineJoint.m_localXAxis1.x = correctedVec.x;
					lineJoint.m_localXAxis1.y = correctedVec.y;
					lineJoint.m_localYAxis1.x = -lineJoint.m_localXAxis1.y;
					lineJoint.m_localYAxis1.y =  lineJoint.m_localXAxis1.x;
				}
			}
		}
		
		private function vectorUpdated(evt:qb2MathEvent):void
		{
			_localDirection.pushDispatchBlock(vectorUpdated);
			{
				_localDirection.normalize();
			}
			_localDirection.popDispatchBlock(vectorUpdated);
			
			correctLocalVec();
			
			wakeUpAttached();
		}
		
		public function setWorldDirection(worldVector:qb2GeoVector):void
		{
			localDirection = _object1 ? _object1.getLocalVector(worldVector) : worldVector.clone();
		}
		
		private var callingFromUpdate:Boolean = false;
		
		protected override function update():void
		{
			if ( springK == 0 )  return;
			if ( !_object1 || !_object2 || !_object2.world || !_object2.world )  return;
			if ( _object1.isSleeping && _object2.isSleeping )  return;
			
			var conversion:Number = worldPixelsPerMeter;
			var diffLen:Number = currJointTranslation;
			var flip:Boolean = !springCanFlip && diffLen < 0;
			
			if ( optimizedSpring )
			{
				callingFromUpdate = true;
				{
					var modDiffLen:Number = springCanFlip ? Math.abs(diffLen) : diffLen;
					var dampingForce:Number = springCanFlip && diffLen < 0 ? -currPistonSpeed * springDamping : currPistonSpeed * springDamping;
					maxForce = Math.abs((((modDiffLen - springLength) / conversion) * springK) + dampingForce);
					
					if ( springCanFlip && diffLen < 0 )
					{
						targetSpeed = diffLen + springLength > 0 ? -MAX_SPRING_SPEED : MAX_SPRING_SPEED;
					}
					else
					{
						targetSpeed = diffLen - springLength < 0 ? MAX_SPRING_SPEED : -MAX_SPRING_SPEED;
					}
				}
				callingFromUpdate = false;
			}
			else
			{
				var world1:qb2GeoPoint = getWorldAnchor1();
				var world2:qb2GeoPoint = getWorldAnchor2();
				var transVec:qb2GeoVector = world2.minus(world1);
				
				if ( springCanFlip && diffLen < 0 )
				{
					diffLen = -diffLen;
				}
				
				var diff:qb2GeoVector = (flip ? transVec.clone().negate() : world2.minus(world1)).normalize();
				diff.scaleByNumber( ((diffLen - springLength) / conversion) * springK );
				
				_object1.applyForce(world1, diff);
				_object2.applyForce(world2, diff.negate());
				
				if ( springDamping )
				{
					diff = world1.minus(world2).normalize();
					var linVel1:qb2GeoVector = _object1.getLinearVelocityAtPoint(world1);
					var jointComponent:Number = diff.dotProduct(linVel1);
					_object1.applyForce(world1, diff.scaledBy(-jointComponent * springDamping));
					
					diff.copy(transVec).normalize();
					var linVel2:qb2GeoVector = _object2.getLinearVelocityAtPoint(world2);
					jointComponent = diff.dotProduct(linVel2);
					_object2.applyForce(world2, diff.scaledBy(-jointComponent * springDamping));
				}
			}
		}		
		
		public function getCurrentTranslation():Number
		{
			if ( jointB2 )
			{
				if ( jointB2 is b2PrismaticJoint )
					return prisJoint.GetJointTranslation() * worldPixelsPerMeter;
				else if ( jointB2 is b2LineJoint )
					return lineJoint.GetJointTranslation() * worldPixelsPerMeter;
			}
			
			return 0;
		}
			
		public function getCurrentSpeed():Number
		{
			if ( jointB2 )
			{
				if ( jointB2 is b2PrismaticJoint )
					return prisJoint.GetJointSpeed();
				else if ( jointB2 is b2LineJoint )
					return lineJoint.GetJointSpeed();
			}
			
			return 0;
		}
			
		public function getCurrentForce():Number
		{
			if ( jointB2 )
			{
				if ( jointB2 is b2PrismaticJoint )
					return prisJoint.GetMotorForce();
				else if ( jointB2 is b2LineJoint )
					return lineJoint.GetMotorForce();
			}
			
			return 0;
		}
		
		public function setLimits(lower:Number, upper:Number):void
		{
			lowerLimit = lower;
			upperLimit = upper;
		}
		
		private function updateLimits():void
		{
			if ( !jointB2 )  return;
			
			var limits:Array = getMetricLimits(worldPixelsPerMeter);
			
			if ( jointB2 is b2PrismaticJoint )
			{
				prisJoint.SetLimits(limits[0], limits[1]);
				prisJoint.EnableLimit(hasLimits);
			}
			else if ( jointB2 is b2LineJoint )
			{
				lineJoint.SetLimits(limits[0], limits[1]);
				lineJoint.EnableLimit(hasLimits);
			}
		}
		
		public function hasLimits():Boolean
			{  return isFinite(lowerLimit) || isFinite(upperLimit);  }
			
		private function getMetricLimits(scale:Number):Array
		{
			var lower:Number = lowerLimit / scale;
			var upper:Number = upperLimit / scale;

			//--- "Fix" the limits if they are within 1 centimeter of each other, cause otherwise the joint will get tweaked out and set itself to zero limit.
			if ( Math.abs(upper-lower) < IDENTICAL_LIMIT_CORRECTION )
			{
				upper = lower + IDENTICAL_LIMIT_CORRECTION;
			}
			
			return [lower, upper];
		}
		
		qb2_friend override function objectsUpdated():void
		{
			if ( _object1 &&_object2 )  referenceAngle = _object2.m_rigidImp._rotation - _object1.m_rigidImp._rotation;
			updateDirectionAndSpringLength();
		}
		
		private function updateDirectionAndSpringLength():void
		{
			if ( _object1 && _object2  && m_localAnchor1 && m_localAnchor2)
			{
				if ( autoSetDirection )
				{
					var worldVector:qb2GeoVector = _object2.calcWorldPoint(m_localAnchor2).minus(_object1.calcWorldPoint(m_localAnchor1));
					localDirection = _object1.getLocalVector(worldVector.lengthSquared ? worldVector : worldVector.set(0, -1));
				}
				if ( autoSetLength )
				{
					springLength = _object1.calcWorldPoint(m_localAnchor1).distanceTo(_object2.calcWorldPoint(m_localAnchor2));
				}
			}
		}
		
		
		
		/*qb2_friend override function make(theWorld:qb2World):void
		{
			var limits:Array = getMetricLimits(theWorld.pixelsPerMeter);
			
			var conversion:Number = theWorld.pixelsPerMeter;
			var corrected1:qb2GeoPoint    = getCorrectedLocal1(conversion, conversion);
			var corrected2:qb2GeoPoint    = getCorrectedLocal2(conversion, conversion);
			var correctedVec:qb2GeoVector = getCorrectedLocalVec();
			
			if ( !freeRotation )
			{
				var prisJointDef:b2PrismaticJointDef = b2Def.prismaticJoint;
				prisJointDef.localAnchorA.x   = corrected1.x;
				prisJointDef.localAnchorA.y   = corrected1.y;
				prisJointDef.localAnchorB.x   = corrected2.x;
				prisJointDef.localAnchorB.y   = corrected2.y;
				prisJointDef.localAxis1.x     = correctedVec.x;
				prisJointDef.localAxis1.y     = correctedVec.y;
				prisJointDef.enableLimit      = hasLimits;
				prisJointDef.enableMotor      = maxForce ? true : false;
				prisJointDef.lowerTranslation = limits[0];
				prisJointDef.upperTranslation = limits[1];
				prisJointDef.maxMotorForce    = maxForce;
				prisJointDef.motorSpeed       = targetSpeed;
				prisJointDef.referenceAngle   = referenceAngle;
				
				jointDef = prisJointDef;
			}
			else
			{
				var lineJointDef:b2LineJointDef = b2Def.lineJoint;
				lineJointDef.localAnchorA.x   = corrected1.x;
				lineJointDef.localAnchorA.y   = corrected1.y;
				lineJointDef.localAnchorB.x   = corrected2.x;
				lineJointDef.localAnchorB.y   = corrected2.y;
				lineJointDef.localAxisA.x     = correctedVec.x;
				lineJointDef.localAxisA.y     = correctedVec.y;
				lineJointDef.enableLimit      = hasLimits
				lineJointDef.enableMotor      = maxForce ? true : false;
				lineJointDef.lowerTranslation = limits[0];
				lineJointDef.upperTranslation = limits[1];
				lineJointDef.maxMotorForce    = maxForce;
				lineJointDef.motorSpeed       = targetSpeed;
				
				jointDef = lineJointDef;
			}
			
			super.make(theWorld);
		}*/
		
		private function get prisJoint():b2PrismaticJoint
			{  return jointB2 ? jointB2 as b2PrismaticJoint : null;  }
			
		private function get lineJoint():b2LineJoint
			{  return jointB2 ? jointB2 as b2LineJoint : null;  }
			
		protected override function copy_protected(otherObject:*):void
		{
			super.copy(otherObject);
			
			var otherObjectAsPistonJoint:qb2PistonJoint = otherObject as qb2PistonJoint;
			
			if ( !otherObjectAsPistonJoint )  return;
			
			this.m_localDirection.copy(otherObjectAsPistonJoint.m_localDirection);
		}
		
		public override function draw(graphics:qb2I_Graphics2d):void
		{
			var worldPoints:Vector.<V2> = drawAnchors(graphics);
			
			if ( !worldPoints || worldPoints.length != 2 )   return;
			
			var world1:qb2GeoPoint = new qb2GeoPoint(worldPoints[0].x, worldPoints[0].y);
			var world2:qb2GeoPoint = new qb2GeoPoint(worldPoints[1].x, worldPoints[1].y);
			
			if ( world1.equals(world2) )  return;
			
			var diff:qb2GeoVector = world2.minus(world1);
			var side:qb2GeoVector = diff.perpVector(1).setLength(pistonBaseDrawWidth / 2);
			var distance:Number = diff.length;
				
			graphics.pushFillColor();
			{
				//--- Draw piston base.
				var drawPnt:qb2GeoPoint = world1.clone();
				drawPnt.translate(side);
				graphics.moveTo(drawPnt.x, drawPnt.y);
				drawPnt.translate(diff.scaleByNumber(.5));
				graphics.lineTo(drawPnt.x, drawPnt.y);
				drawPnt.translate(side.negate().scale(2));
				graphics.lineTo(drawPnt.x, drawPnt.y);
				drawPnt.translate(diff.negate());
				graphics.lineTo(drawPnt.x, drawPnt.y);
				
				//--- Draw piston shaft.
				drawPnt.copy(world1);
				drawPnt.translate(diff.negate());
				graphics.moveTo(drawPnt.x, drawPnt.y);
				drawPnt.translate(diff);
				graphics.lineTo(drawPnt.x, drawPnt.y);
				
				//--- Draw spring.
				var segLength:Number = distance / 2 / numSpringCoils;
				side.setLength(springDrawWidth / 2);
				diff.setLength(segLength / 2).negate();
				drawPnt.translate(side).translate(diff);
				graphics.lineTo(drawPnt.x, drawPnt.y);
				diff.scaleByNumber(2);
				side.scaleByNumber(2);
				for (var i:int = 0; i < numSpringCoils-1; i++) 
				{
					side.negate();
					drawPnt.translate(side).translate(diff);
					
					graphics.lineTo(drawPnt.x, drawPnt.y);
				}
				side.negate().scale(.5);
				diff.scaleByNumber(.5);
				drawPnt.translate(side).translate(diff);
				graphics.lineTo(drawPnt.x, drawPnt.y);
			}
			graphics.popFillColor();
		}
		
		qb2_friend override function getWorldAnchors():Vector.<V2>
		{
			var bodyA:b2Body, bodyB:b2Body;
			var anchorA:b2Vec2, anchorB:b2Vec2;
			if ( prisJoint )
			{
				bodyA = prisJoint.m_bodyA;
				bodyB = prisJoint.m_bodyB;
				anchorA = prisJoint.mm_localAnchor1;
				anchorB = prisJoint.mm_localAnchor2;
			}
			else
			{
				bodyA   = lineJoint.m_bodyA;
				bodyB   = lineJoint.m_bodyB;
				anchorA = lineJoint.mm_localAnchor1;
				anchorB = lineJoint.mm_localAnchor2;
			}
			
			reusableV2.xy(anchorA.x, anchorA.y);
			var anch1:V2 = bodyA.calcWorldPoint(reusableV2);
			reusableV2.xy(anchorB.x, anchorB.y);
			var anch2:V2 = bodyB.calcWorldPoint(reusableV2);
			anch1.multiplyN(worldPixelsPerMeter);
			anch2.multiplyN(worldPixelsPerMeter);
			
			return Vector.<V2>([anch1, anch2]);
		}
	}
}