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

package quickb2.physics.core.joints
{
	import quickb2.math.*;
	import quickb2.math.geo.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.Joints.*;
	import flash.display.*;
	import quickb2.lang.*
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2World;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2WeldJoint extends qb2Joint
	{
		public function qb2WeldJoint(objectA:qb2I_RigidObject = null, objectB:qb2I_RigidObject = null, worldAnchor:qb2GeoPoint = null) 
		{
			init(objectA, objectB);
			
			setWorldAnchor(worldAnchor ? worldAnchor : initWorldPoint(objectA));
		}
		
		qb2_friend override function anchorUpdated(point:qb2GeoPoint):void
		{
			correctLocals();
			wakeUpAttached();
		}
		
		/*qb2_friend override function correctLocals():void
		{
			if ( jointB2 )
			{
				var conversion:Number = worldPixelsPerMeter;
				var corrected1:qb2GeoPoint = getCorrectedLocal1(conversion, conversion);
				var corrected2:qb2GeoPoint = getCorrectedLocal2(conversion, conversion);
				
				joint.m_localAnchors[0].x = corrected1.x;
				joint.m_localAnchors[0].y = corrected1.y;
				joint.m_localAnchors[1].x = corrected2.x;
				joint.m_localAnchors[1].y = corrected2.y;
			}
		}*/
		
		qb2_friend override function objectsUpdated():void
		{
			if ( _object1 && _object2 )
				referenceAngle = _object2.m_rigidImp._rotation - _object1.m_rigidImp._rotation;
		}
		
		/*qb2_friend override function make(theWorld:qb2World):void
		{
			var conversion:Number = theWorld.pixelsPerMeter;
			var corrected1:qb2GeoPoint    = getCorrectedLocal1(conversion, conversion);
			var corrected2:qb2GeoPoint    = getCorrectedLocal2(conversion, conversion);
			
			var weldJointDef:b2WeldJointDef = b2Def.weldJoint;
			weldJointDef.localAnchorA.x   = corrected1.x;
			weldJointDef.localAnchorA.y   = corrected1.y;
			weldJointDef.localAnchorB.x   = corrected2.x;
			weldJointDef.localAnchorB.y   = corrected2.y;
			weldJointDef.referenceAngle = this.referenceAngle;
			
			jointDef = weldJointDef;
			
			super.make(theWorld);
		}*/
		
		public override function draw(graphics:qb2I_Graphics2d):void
		{
			var worldPoints:Vector.<V2> = drawAnchors(graphics);
			
			if ( !worldPoints )   return;
			
			var world1:qb2GeoPoint = reusableDrawPoint.set(worldPoints[0].x, worldPoints[0].y);
			var vec:qb2GeoVector = new qb2GeoVector(1, 1);
			vec.setLength(crossDrawRadius);
			
			graphics.pushFillColor();
			{
				world1.translate(vec);
				graphics.moveTo(world1.x, world1.y);
				world1.translate(vec.negate().scale(2));
				graphics.lineTo(world1.x, world1.y);
				world1.translate(vec.negate().scale(.5)).translate(vec.setToPerpVector());
				graphics.moveTo(world1.x, world1.y);
				world1.translate(vec.negate().scale(2));
				graphics.lineTo(world1.x, world1.y);
			}
			graphics.popFillColor();
		}
	}
}