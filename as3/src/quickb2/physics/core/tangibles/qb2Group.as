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
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.iterators.qb2ChildIterator;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.math.geo.*;
	import flash.display.*;
	import quickb2.lang.*;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.joints.qb2PU_JointBackDoor;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.utils.qb2U_Kinematics;
	import quickb2.utils.prop.qb2PropMapStack;
	
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	
	
	
	[Event(name="SUB_PRE_SOLVE",       type="quickb2.event.qb2SubContactEvent")]
	[Event(name="SUB_POST_SOLVE",      type="quickb2.event.qb2SubContactEvent")]
	[Event(name="SUB_CONTACT_STARTED", type="quickb2.event.qb2SubContactEvent")]
	[Event(name="SUB_CONTACT_ENDED",   type="quickb2.event.qb2SubContactEvent")]

	/**
	 * The qb2Group class provides a convenient way to treat a bunch of objects as one.  For example, you might put all the walls in a level into one group,
	 * so that you can easily set all their properties.  You might even have a whole level as one group; this way, swapping levels is a snap.  Another use is for when an object,
	 * for example a ragdoll, cannot be built with just one rigid body, but requires multiples bodies attached with joints.  Nesting groups is also possible, like if you wanted
	 * to have a ragdoll's arms be a subgroup of the ragdoll itself.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2Group extends qb2A_PhysicsObjectContainer
	{
		public function qb2Group() 
		{
		}

		internal override function onStepComplete_internal(stylePropStack:qb2PropMapStack):void
		{
			super.onStepComplete_internal(null);
			
			//var numToPop:int = pushToEffectsStack();
			
			super.onStepComplete_container(stylePropStack);
			
			//popFromEffectsStack(numToPop);
		}
		
		/*public function isSleeping():Boolean
		{
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(this, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next() as qb2I_RigidObject; )
			{
				if ( !rigid.isSleeping() )
				{
					return false;
				}
				
				iterator.skipBranch();
			}
			
			return true;
		}*/

		/*public function applyLinearImpulse(atPoint:qb2GeoPoint, impulseVector:qb2GeoVector):void
		{
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(this, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next() as qb2I_RigidObject; )
			{
				rigid.applyLinearImpulse(atPoint, impulseVector);
				iterator.skipBranch();
			}
		}
		
		public function applyAngularImpulse(angularImpulse:Number):void
		{
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(this, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next() as qb2I_RigidObject; )
			{
				rigid.applyAngularImpulse(angularImpulse);
				iterator.skipBranch();
			}
		}
		
		public function applyForce(atPoint:qb2GeoPoint, forceVector:qb2GeoVector):void
		{
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(this, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next() as qb2I_RigidObject; )
			{
				rigid.applyForce(atPoint, forceVector);
				iterator.skipBranch();
			}
		}
		
		public function applyTorque(torque:Number):void
		{
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(this, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next() as qb2I_RigidObject; )
			{
				rigid.applyTorque(torque);
				iterator.skipBranch();
			}
		}*/
		
		public function convertToBody():qb2Body
		{
			var body:qb2Body = new qb2Body();
			body.copy(this);
			
			qb2U_Kinematics.calcAvgLinearVelocity(this, body.getLinearVelocity());
			var avgAngular:Number = qb2U_Kinematics.calcAvgAngularVelocity(this);
			body.setAngularVelocity(avgAngular);
			
			var iterator:qb2ChildIterator = qb2A_PhysicsObjectContainer.s_childIterator;
			iterator.initialize(this);
			for ( var object:qb2A_PhysicsObject; object = iterator.next(); )
			{
				body.addChild(object.clone());
			}

			return body;
		}
	}
}