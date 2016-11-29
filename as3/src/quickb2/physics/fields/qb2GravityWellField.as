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
	import quickb2.math.qb2U_Math;
	
	
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.objects.effects.configs.qb2GravityWellFieldConfig;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2GravityWellField extends qb2A_EffectField
	{
		public function qb2GravityWellField()
		{
		}
		
		public override function applyToRigid(rigid:qb2I_RigidObject):void
		{
			var thisWorldPoint:qb2GeoPoint  = this.parent  ? this.parent.calcWorldPoint(this.position)       : this.position;
			var rigidWorldPoint:qb2GeoPoint = rigid.parent ? rigid.parent.calcWorldPoint(rigid.centerOfMass) : rigid.centerOfMass;
			var vector:qb2GeoVector = thisWorldPoint.minus(rigidWorldPoint);
			
			if ( !qb2U_Math.isWithin(vector.length, Math.max(.1, minHorizon), maxHorizon) )  return;
			
			var force:Number = gravConstant * ( (rigid.mass * wellMass));// / vector.lengthSquared);
			
			if ( useInverseSquare )
			{
				force /= vector.lengthSquared;
			}
			
			var forceVec:qb2GeoVector = vector.normalize().scale(force);
			
			if ( rigid.ancestorBody )
			{
				rigid.ancestorBody.applyForce(rigidWorldPoint, forceVec);
			}
			else
			{
				rigid.applyForce(rigidWorldPoint, forceVec);
			}
		}
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var cloned:qb2GravityWellField = super.clone(deep) as qb2GravityWellField;
			
			cloned.m_config.copy(this.config);
			
			return cloned;
		}

		/*public override function convertTo(T:Class):* 
			{  return qb2U_ToString.auto(this, "qb2GravityWellField");  }*/
	}
}