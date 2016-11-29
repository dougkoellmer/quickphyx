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
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.bridge.qb2P_RigidComponent;
	import quickb2.physics.core.iterators.qb2ChildIterator;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.utils.prop.qb2Prop;
	import quickb2.utils.prop.qb2PropMapStack;
	
	import quickb2.math.geo.*;
	import flash.display.*;
	import quickb2.lang.*
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.event.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.qb2A_PhysicsObject;
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Body extends qb2A_PhysicsObjectContainer implements qb2I_RigidObject
	{
		private const m_rigidComponent:qb2P_RigidComponent = new qb2P_RigidComponent();
		
		public function qb2Body()
		{
			super();
			
			m_rigidComponent.init(this);
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
		
		internal override function onStepComplete_internal(stylePropStack:qb2PropMapStack):void
		{
			super.onStepComplete_internal(null);
			
			m_rigidComponent.onStepComplete(this.getWorld().getRotationStack().value);
			
			//var numToPop:int = pushToEffectsStack();
			
			this.onStepComplete_container(stylePropStack);
			
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
		
		public function convertToGroup():qb2Group
		{
			var group:qb2Group = new qb2Group();
				
			group.copy(this);
			
			var iterator:qb2ChildIterator = qb2A_PhysicsObjectContainer.s_childIterator;
			iterator.initialize(this);
			for ( var object:qb2A_PhysicsObject; object = iterator.next(); )
			{
				group.addChild(object.clone());
			}
			
			return group;
		}
	}
}