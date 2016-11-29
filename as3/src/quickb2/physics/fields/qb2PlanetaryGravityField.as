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
	import quickb2.math.general.qb2U_Math;
	
	
	import Box2DAS.Common.V2;
	import flash.utils.Dictionary;
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.event.qb2StepEvent;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	import quickb2.objects.effects.configs.qb2GravityWellFieldConfig;
	import quickb2.objects.effects.configs.qb2PlanetaryGravityFieldConfig;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2PlanetaryGravityField extends qb2A_EffectField
	{		
		public function qb2PlanetaryGravityField(config:qb2PlanetaryGravityFieldConfig = null )
		{
			init(config);
		}
		
		private function init(config:qb2PlanetaryGravityFieldConfig):void
		{
			addEventListener(qb2StepEvent.POST_UPDATE, processAccumulator, null, true);
			
			setConfig(config ? config : (qb2PlanetaryGravityFieldConfig.useSharedInstanceByDefault ? qb2PlanetaryGravityFieldConfig.getInstance() : new qb2PlanetaryGravityFieldConfig()));
		}
		
		public function getConfig():qb2PlanetaryGravityFieldConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2PlanetaryGravityFieldConfig):void
		{
			m_config = config;
		}
		private var m_config:qb2GravityWellFieldConfig = null;
		
		private var accumArray:Vector.<qb2I_RigidObject> = new Vector.<qb2I_RigidObject>();
		private var accumDict:Dictionary = new Dictionary(true);
		
		private function processAccumulator(evt:qb2StepEvent):void
		{
			for (var i:int = 0; i < accumArray.length; i++) 
			{
				var ithRigid:qb2I_RigidObject = accumArray[i];
				
				for (var j:int = i+1; j < accumArray.length; j++)
				{
					var jthRigid:qb2I_RigidObject = accumArray[j];
			
					var ithWorldPoint:qb2GeoPoint = ithRigid.ancestorBody  ? ithRigid.parent.calcWorldPoint(ithRigid.centerOfMass, ancestorBody.parent) : ithRigid.centerOfMass;
					var jthWorldPoint:qb2GeoPoint = jthRigid.ancestorBody  ? jthRigid.parent.calcWorldPoint(jthRigid.centerOfMass, ancestorBody.parent) : jthRigid.centerOfMass;
					
					var vector:qb2GeoVector = ithWorldPoint.minus(jthWorldPoint);
					
					var force:Number = gravConstant * ( (ithRigid.mass * jthRigid.mass) / vector.lengthSquared);
					
					var forceVec:qb2GeoVector = vector.normalize().scale(force);
					
					if ( jthRigid.ancestorBody )
					{
						jthRigid.ancestorBody.applyForce(jthWorldPoint, forceVec);
					}
					else
					{
						jthRigid.applyForce(jthWorldPoint, forceVec);
					}
					
					if ( ithRigid.ancestorBody )
					{
						ithRigid.ancestorBody.applyForce(ithWorldPoint, forceVec.negate());
					}
					else
					{
						ithRigid.applyForce(ithWorldPoint, forceVec.negate());
					}
				}
				
				delete accumDict[ithRigid];
			}
			
			accumArray.length = 0;
		}
		
		public override function apply(toTangible:qb2A_PhysicsObject):void
		{
			super.apply(toTangible);
			processAccumulator(null);
		}
		
		public override function applyToRigid(rigid:qb2I_RigidObject):void
		{
			if ( accumDict[rigid] )  return;
			
			accumDict[rigid] = true;
			accumArray.push(rigid);
		}
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var cloned:qb2PlanetaryGravityField = super.clone(deep) as qb2PlanetaryGravityField;
			
			cloned.m_config.copy(this.m_config);
			
			return cloned;
		}
		
		//public override function convertTo(T:Class):* 
		//	{  return qb2U_ToString.auto(this, "qb2PlanetaryGravityField");  }
		
	}
}