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

package quickb2.physics.core.tangibles
{
	import flash.display.*;
	import flash.utils.*;
	import quickb2.physics.core.backend.qb2I_BackEndShape;
	import quickb2.physics.core.bridge.qb2P_Flusher;
	import quickb2.physics.core.bridge.qb2P_RigidComponent;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.utils.primitives.qb2Boolean;
	import quickb2.utils.prop.qb2Prop;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2PropMapStack;
	
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.utils.qb2U_Geom;
	
	import quickb2.lang.*;
	
	import quickb2.math.*;
	
	import quickb2.math.geo.*;
	import quickb2.math.geo.coords.*;
	import quickb2.math.geo.curves.*;
	import quickb2.math.geo.surfaces.*;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.*;
	import quickb2.display.immediate.graphics.*;
	import quickb2.display.immediate.style.*;
	
	

	/**
	 * Shapes form the leaves of a world tree, and define the geometry for tangible objects.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2Shape extends qb2A_TangibleObject implements qb2I_RigidObject
	{
		private static const s_utilBool1:qb2Boolean = new qb2Boolean();
		private const m_rigidComponent:qb2P_RigidComponent = new qb2P_RigidComponent();
		
		public function qb2Shape(geometry_nullable:qb2A_GeoEntity = null)
		{
			super();
			
			m_rigidComponent.init(this);
			
			this.setProp(qb2S_PhysicsProps.GEOMETRY, geometry_nullable);
		}
		
		internal override function getRigidComponent():qb2P_RigidComponent
		{
			return m_rigidComponent;
		}
		
		protected override function setProp_protected(property:qb2Prop, value:*):void
		{
			if ( !m_rigidComponent.setProp(property, value) )
			{
				super.setProp_protected(property, value);
			}
		}
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			//TODO: Somehow pass pixelsPerMeter and geometry down efficiently...through stylesheet?
			
			var geometry:qb2A_GeoEntity = this.getEffectiveProp(qb2S_PhysicsProps.GEOMETRY);
			
			if ( geometry != null )
			{
				qb2U_Geom.pushToTransformStack(this, graphics.getTransformStack());
				
				geometry.draw(graphics, propertyMap_nullable);
				
				qb2U_Geom.popFromTransformStack(this, graphics.getTransformStack());
			}
		}
		
		internal override function onStepComplete_internal(stylePropStack:qb2PropMapStack):void
		{
			//var numToPop:int = pushToEffectsStack();
			
			super.onStepComplete_internal(null);
			
			m_rigidComponent.onStepComplete(this.getWorld().getRotationStack().value);
			
			qb2PU_PhysicsObjectBackDoor.onStepComplete_protected(this);
			
			var graphics:qb2I_Graphics2d = this.getWorld().getConfig().graphics;
			var geometry:qb2A_GeoEntity = this.getEffectiveProp(qb2S_PhysicsProps.GEOMETRY);
	
			if ( geometry != null && graphics != null )
			{
				qb2PU_PhysicsObjectBackDoor.depthFirst_push(this, graphics, stylePropStack, s_utilBool1);
				var pushedStyles:Boolean = s_utilBool1.value;
				
				graphics.getTransformStack().get().copy(this.getWorld().getTransformStack().get());
				this.draw(graphics, stylePropStack.get());
				
				qb2PU_PhysicsObjectBackDoor.depthFirst_pop(this, stylePropStack, pushedStyles);
			}
			
			//popFromEffectsStack(numToPop);
		}
		
		public function getLinearVelocity():qb2GeoVector
		{
			return m_rigidComponent.getLinearVelocity();
		}
		
		public function setLinearVelocity(x:Number, y:Number):void
		{
			m_rigidComponent.getLinearVelocity().set(x, y);
		}

		public function getAngularVelocity():Number
		{
			return m_rigidComponent.getAngularVelocity();
		}

		public function setAngularVelocity(radsPerSec:Number):void
		{
			return m_rigidComponent.setAngularVelocity(radsPerSec);
		}
		
		/*public function calcCenterOfMass():qb2GeoPoint
		{
			if ( m_simulatedComponent.m_backEndRepresentation && !m_ancestorBody)
			{
				var point:qb2GeoPoint = new qb2GeoPoint();
				qb2_validate();
				
				m_simulatedComponent.m_backEndRepresentation.syncPoint(qb2E_BackEndProp.CENTER_OF_MASS, point);
				
				return point;
			}
			else if ( m_geometry )
			{
				return m_geometry.calcCenterOfMass();
			}
			
			return new qb2GeoPoint();;
		}*/
	}
}