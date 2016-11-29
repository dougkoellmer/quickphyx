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
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.display.immediate.style.qb2CompiledStyleRule;
	import quickb2.display.immediate.style.qb2StyleSheet;
	import quickb2.math.*;
	import quickb2.math.geo.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Joints.*;
	import flash.display.*;
	import quickb2.lang.*
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.utils.qb2U_Joint;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2World;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DistanceJoint extends qb2Joint
	{
		public function qb2DistanceJoint(objectA_nullable:qb2A_TangibleObject = null, objectB_nullable:qb2A_TangibleObject = null)
		{
			super(objectA_nullable, objectB_nullable);
		}
		
		
		
		/*qb2_friend override function make(theWorld:qb2World):void
		{
			var makingRopeJoint:Boolean = isRope;
			
			var conversion:Number = theWorld.pixelsPerMeter;
			var corrected1:qb2GeoPoint    = getCorrectedLocal1(conversion, conversion);
			var corrected2:qb2GeoPoint    = getCorrectedLocal2(conversion, conversion);
			
			if ( makingRopeJoint )
			{
				var ropeJointDef:b2RopeJointDef = b2Def.ropeJoint;
				ropeJointDef.localAnchorA.x = corrected1.x;
				ropeJointDef.localAnchorA.y = corrected1.y;
				ropeJointDef.localAnchorB.x = corrected2.x;
				ropeJointDef.localAnchorB.y = corrected2.y;
				ropeJointDef.maxLength      = length / theWorld.pixelsPerMeter;
				
				//--- NOTE: b2RopeJointDef doesn't have the frequencyHz and dampingRatio properties, so it's applied to the actual joint at the end of this function.
				// ropeJointDef.frequencyHz    = frequencyHz;
				// ropeJointDef.dampingRatio   = dampingRatio;
				
				jointDef = ropeJointDef;
			}
			else
			{
				var distJointDef:b2DistanceJointDef = b2Def.distanceJoint;
				distJointDef.localAnchorA.x = corrected1.x;
				distJointDef.localAnchorA.y = corrected1.y;
				distJointDef.localAnchorB.x = corrected2.x;
				distJointDef.localAnchorB.y = corrected2.y;
				distJointDef.length         = length / theWorld.pixelsPerMeter;
				distJointDef.frequencyHz    = frequencyHz;
				distJointDef.dampingRatio   = dampingRatio;
				
				jointDef = distJointDef;
			}
			
			super.make(theWorld);
			
			//--- It's these kinds of API inconsistencies in Box2D that gives quickb2 a purpose in life.
			if ( makingRopeJoint )
			{
				ropeJoint.SetFrequency(frequencyHz);
				ropeJoint.SetDampingRatio(dampingRatio);
			}
		}*/
		
		
	}
}