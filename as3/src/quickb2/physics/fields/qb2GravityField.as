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
	import quickb2.math.geo.*;
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.coords.qb2GeoVector;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.objects.effects.qb2A_EffectField;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2GravityField extends qb2A_EffectField
	{
		private const m_fieldVector:qb2GeoVector = new qb2GeoVector();
		
		public override function applyToRigid(rigid:qb2I_RigidObject):void
		{
			if ( rigid.ancestorBody )
			{
				rigid.ancestorBody.applyForce(rigid.parent.calcWorldPoint(rigid.centerOfMass), m_fieldVector.scaledBy(rigid.mass));
			}
			else
			{
				rigid.applyForce(rigid.centerOfMass, m_fieldVector.scaledBy(rigid.mass));
			}
		}
		
		public function getFieldVector():qb2GeoVector
		{
			return m_fieldVector;
		}
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var cloned:qb2GravityField = super.clone(deep) as qb2GravityField;
			
			cloned.m_fieldVector.copy(this.vector);
			
			return cloned;
		}
		
		public override function convertTo(T:Class):* 
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this, "qb2GravityField");
			}
			
			else return super.convertTo(T);
		}
	}
}