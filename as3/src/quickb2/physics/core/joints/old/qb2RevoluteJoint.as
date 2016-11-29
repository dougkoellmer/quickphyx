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
	import quickb2.physics.core.backend.qb2E_BackEndProp;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.math.*;
	
	import quickb2.math.geo.*;
	import quickb2.lang.*
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2World;
	
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2RevoluteJoint extends qb2Joint
	{
		public function qb2RevoluteJoint(objectA:qb2A_TangibleObject = null, objectB:qb2A_TangibleObject = null, initWorldAnchor:qb2GeoPoint = null) 
		{
			super(objectA, objectB);
			
			//setWorldAnchor(initWorldAnchor ? initWorldAnchor : initWorldPoint(objectA));
		}
		
		public function getAngle():Number
		{
			if ( this.getBackEndRepresentation() != null )
			{
				this.getBackEndRepresentation().getFloat(qb2E_BackEndProp.JOINT_ANGLE);
			}
			
			return 0;
		}
			
		public function getSpeed():Number
		{
			if ( this.getBackEndRepresentation() != null )
			{
				this.getBackEndRepresentation().getFloat(qb2E_BackEndProp.JOINT_SPEED);
			}
			
			return 0;
		}

		public function getTorque():Number
		{
			if ( this.getBackEndRepresentation() != null )
			{
				this.getBackEndRepresentation().getFloat(qb2E_BackEndProp.JOINT_TORQUE);
			}
			
			return 0;
		}
		
		protected override function onAttachmentsChanged():void
		{
			/*if ( m_objects[0] != null && m_objects[1] != null )
			{
				var rigidComponent0:qb2InternalRigidComponent = m_objects[0].getSimulatedComponent() as qb2InternalRigidComponent;
				var rigidComponent1:qb2InternalRigidComponent = m_objects[1].getSimulatedComponent() as qb2InternalRigidComponent;
				this.setSharedProperty(qb2S_PhysicsProps.REFERENCE_ANGLE, rigidComponent1.m_rotation - rigidComponent0.m_rotation);
			}*/
		}
		
		//qb2_friend override function make(theWorld:qb2World):void
		//{
			/*var conversion:Number       	= theWorld.getConfig().pixelsPerMeter;
			var corrected1:qb2GeoPoint    = getCorrectedLocal1(conversion, conversion);
			var corrected2:qb2GeoPoint    = getCorrectedLocal2(conversion, conversion);
			
			var revJointDef:b2RevoluteJointDef = b2Def.revoluteJoint;
			revJointDef.localAnchorA.x   = corrected1.m_x;
			revJointDef.localAnchorA.y   = corrected1.m_y;
			revJointDef.localAnchorB.x   = corrected2.m_x;
			revJointDef.localAnchorB.y   = corrected2.m_y;
			
			revJointDef.enableLimit    = isConstrained();
			revJointDef.enableMotor    = getMaxTorque() != 0 ? true : false;
			revJointDef.lowerAngle     = getLowerLimit();
			revJointDef.upperAngle     = getUpperLimit();
			revJointDef.maxMotorTorque = getMaxTorque();
			revJointDef.motorSpeed     = getTargetSpeed();
			revJointDef.referenceAngle = getReferenceAngle();
			
			jointDef = revJointDef;*/
			
		//	super.make(theWorld);
		//}
			
		private var callingFromUpdate:Boolean = false;
		
		protected override function onStepComplete():void
		{
			/*if ( getSpringK() == 0 )  return;
			if ( !m_objects[0] || !m_objects[1] || !m_objects[1].getWorld() || !m_objects[1].getWorld() )  return;
			if ( m_objects[0].isSleeping() && m_objects[1].isSleeping() )  return;
			
			var jointAngle:Number = this.getCurrentAngle();
			if ( isSpringFlippable() )
			{
				 //--- Basically do a kind of modulus on the angle here to allow it to flip...
				var sign:Number = qb2U_Math.sign(jointAngle);
				var modAngle:Number = Math.abs(jointAngle) % (qb2S_Math.PI * 2);
				jointAngle = modAngle > qb2S_Math.PI ? sign * (modAngle - qb2S_Math.PI * 2) : sign*modAngle;
			}
			
			if ( isSpringOptimized() )
			{
				callingFromUpdate = true;
				{
					setMaxTorque(Math.abs((jointAngle * getSpringK()) + (getCurrentSpeed() * getSpringDamping())));
					setTargetSpeed(jointAngle > 0 ? -MAX_SPRING_SPEED : MAX_SPRING_SPEED);
				}
				callingFromUpdate = false;
			}
			
			/*var conversion:Number = worldPixelsPerMeter;
		
			var world1:qb2GeoPoint = getWorldAnchor1();
			var world2:qb2GeoPoint = getWorldAnchor2();
			
			var diff:qb2GeoVector = world2.minus(world1);
			var diffLen:Number = diff.length;
			diff.normalize();
			
			//--- Make it so the spring doesn't "flip" around if so chosen, because by default the distance between objects isn't signed.
			var worldAxis:qb2GeoVector
			if ( !springCanFlip )
			{
				worldAxis = m_objects[0].getWorldVector(_localDirection);
				if ( worldAxis.dotProduct(diff) < 0 )
				{
					diffLen = -diffLen;
					diff.negate();
				}
			}
			
			diff.scale( ((diffLen - springLength)/conversion) * getSpringK );
			
			m_objects[0].applyForce(world1, diff);
			m_objects[1].applyForce(world2, diff.negate());
			
			if ( springDamping )
			{
				var linVel1:qb2GeoVector = m_objects[0].getLinearVelocityAtPoint(world1);
				var linVel2:qb2GeoVector = m_objects[1].getLinearVelocityAtPoint(world2);
				
				var velDiff:qb2GeoVector = linVel2.minus(linVel1).normalize();
				var dampingForceVec:qb2GeoVector = diff.normalize();
				dampingForceVec.scale(velDiff.dotProduct(dampingForceVec) * springDamping);
				m_objects[0].applyForce(world1, dampingForceVec);
				m_objects[1].applyForce(world2, dampingForceVec.negate());
			}*/
		}
		
		public override function draw(graphics:qb2I_Graphics2d):void
		{
			var arrowDrawRadius:Number = 5; // TODO:
			
			var worldPoints:Vector.<qb2GeoPoint> = null;//drawAnchors(graphics);
			
			if (!worldPoints )   return;
			 
			var world1:qb2GeoPoint = worldPoints[0];
			var utilPoint1:qb2GeoPoint = new qb2GeoPoint();
			var utilPoint2:qb2GeoPoint = new qb2GeoPoint();
			
			var arrowSize:Number = arrowDrawRadius * .25;
			
			graphics.pushParam(qb2E_DrawParam.FILL_COLOR, 0);
			{
				graphics.moveTo(utilPoint1.set(world1.getX(), world1.getY()-arrowDrawRadius) as qb2GeoPoint);
				graphics.drawCurveTo(utilPoint1.set(world1.getX() + arrowDrawRadius, world1.getY() - arrowDrawRadius) as qb2GeoPoint, utilPoint1.set(world1.getX() + arrowDrawRadius, world1.getY()) as qb2GeoPoint);
				graphics.drawLineTo(utilPoint1.set(world1.getX() + arrowDrawRadius - arrowSize, world1.getY() - arrowSize) as qb2GeoPoint);
				graphics.moveTo(utilPoint1.set(world1.getX() + arrowDrawRadius, world1.getY()) as qb2GeoPoint);
				graphics.drawLineTo(utilPoint1.set(world1.getX() + arrowDrawRadius + arrowSize, world1.getY() - arrowSize) as qb2GeoPoint);
				
				graphics.moveTo(utilPoint1.set(world1.getX(), world1.getY()+arrowDrawRadius) as qb2GeoPoint);
				graphics.drawCurveTo(utilPoint1.set(world1.getX() - arrowDrawRadius, world1.getY() + arrowDrawRadius) as qb2GeoPoint, utilPoint1.set(world1.getX() - arrowDrawRadius, world1.getY()) as qb2GeoPoint);
				graphics.drawLineTo(utilPoint1.set(world1.getX() - arrowDrawRadius - arrowSize, world1.getY() + arrowSize) as qb2GeoPoint);
				graphics.moveTo(utilPoint1.set(world1.getX() - arrowDrawRadius, world1.getY()) as qb2GeoPoint);
				graphics.drawLineTo(utilPoint1.set(world1.getX() - arrowDrawRadius + arrowSize, world1.getY() + arrowSize) as qb2GeoPoint);
			}
			graphics.popParam(qb2E_DrawParam.FILL_COLOR);
		}
	}
}