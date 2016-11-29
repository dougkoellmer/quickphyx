/**
 * Copyright (c) 2010 Doug Koellmer
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
	import quickb2.math.consts.TO_RAD;
	import quickb2.math.general.qb2U_Math;
	
	
	import quickb2.debugging.*;
	import quickb2.objects.effects.configs.qb2VortexFieldConfig;
	import quickb2.objects.qb2A_PhysicsObject;
	import quickb2.objects.tangibles.qb2I_RigidObject;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2VortexField extends qb2A_EffectField
	{		
		public function qb2VortexField(config:qb2VortexFieldConfig = null)
		{
			init(config);
		}
		
		private function init(config:qb2VortexFieldConfig):void
		{			
			setConfig(config ? config : (qb2VortexFieldConfig.useSharedInstanceByDefault ? qb2VortexFieldConfig.getInstance() : new qb2VortexFieldConfig()));
		}
		
		public function getConfig():qb2VortexFieldConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2VortexFieldConfig):void
		{
			m_config = config;
		}
		private var m_config:qb2VortexFieldConfig = null;
		
		private static const utilWindField:qb2WindField = new qb2WindField();
		
		public override function applyToRigid(rigid:qb2I_RigidObject):void
		{
			var thisWorldPoint:qb2GeoPoint  = this.parent  ? this.parent.calcWorldPoint(this.position)       : this.position;
			var rigidWorldPoint:qb2GeoPoint = rigid.parent ? rigid.parent.calcWorldPoint(rigid.centerOfMass) : rigid.centerOfMass;
			var rigidWorldVel:qb2GeoVector = rigid.getLinearVelocityAtPoint(rigid.centerOfMass);
			
			var vector:qb2GeoVector = rigidWorldPoint.minus(thisWorldPoint);
			var distanceToCenter:Number = vector.length;
			
			if ( !qb2U_Math.isWithin(distanceToCenter, Math.max(.1, minHorizon), maxHorizon) )  return;
			
			var ratio:Number = (distanceToCenter - minHorizon) / (maxHorizon - minHorizon);
			ratio = isFreeVortex ? 1 - ratio : ratio;
			vector.rotate(vortexAngle).setLength(vortexSpeed * ratio);
			
			utilWindField.simulateDrag = this.simulateDrag;
			utilWindField.airDensity = this.airDensity;
			utilWindField.vector.copy(vector);
			utilWindField.applyToRigid(rigid);
		}
		
		public override function convertTo(T:Class):*
			{  return qb2U_ToString.auto.formatToString(this, "qb2VortexField");  }
		
	}
}