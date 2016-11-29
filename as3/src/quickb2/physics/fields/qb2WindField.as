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
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.objects.effects.configs.qb2WindFieldConfig;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2WindField extends qb2A_EffectField
	{
		/** 
		 * The wind direction and speed.
		 * @default zero-length vector.
		 */
		public var vector:qb2GeoVector = new qb2GeoVector();
		
		public function qb2WindField(config:qb2WindFieldConfig)
		{
			init(config);
		}
		
		private function init(config:qb2WindFieldConfig):void
		{			
			setConfig(config ? config : (qb2WindFieldConfig.useSharedInstanceByDefault ? qb2WindFieldConfig.getInstance() : new qb2WindFieldConfig()));
		}
		
		public function getConfig():qb2WindFieldConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2WindFieldConfig):void
		{
			m_config = config;
		}
		private var m_config:qb2WindFieldConfig = null;
		
		private var utilVec:qb2GeoVector = new qb2GeoVector();
		
		public override function applyToRigid(rigid:qb2I_RigidObject):void
		{
			var rigidWorldVel:qb2GeoVector = rigid.getLinearVelocityAtPoint(rigid.centerOfMass);
			
			if ( simulateDrag )
			{
				utilVec.copy(vector);
				
				var relToAir:qb2GeoVector = utilVec.subtract(rigidWorldVel);
				
				utilVec.copy(relToAir.square().scale(.5 * airDensity));
			}
			else
			{
				if ( !rigidWorldVel.lengthSquared )
				{
					utilVec.copy(vector).scale(airDensity);
				}
				else
				{
					utilVec.copy(vector).normalize();
					var dot:Number = rigidWorldVel.dotProduct(utilVec);
					var worldVelProjection:qb2GeoVector = utilVec.scaledBy(dot);
					utilVec.copy(vector);
					utilVec.subtract(worldVelProjection);
					utilVec.scale(airDensity);
				}
			}
			
			if ( rigid.ancestorBody )
			{
				rigid.ancestorBody.applyForce(rigid.parent.calcWorldPoint(rigid.centerOfMass), utilVec);
			}
			else
			{
				rigid.applyForce(rigid.centerOfMass, utilVec);
			}
		}
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var cloned:qb2WindField = super.clone(deep) as qb2WindField;
			
			cloned.vector.copy(this.vector);
			cloned.m_config.copy(this.m_config);
			
			return cloned;
		}
		
		//public override function convertTo(T:Class):* 
		//	{  return qb2U_ToString.auto(this, "qb2WindField");  }
		
	}
}