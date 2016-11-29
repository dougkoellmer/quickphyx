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

package quickb2.physics.ai.brains
{
	import quickb2.event.qb2ContactEvent;
	import quickb2.event.qb2ContainerEvent;
	import quickb2.objects.ai.brains.qb2A_Brain;
	import QuickB2.objects.ai.controllers.qb2Controller;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.utils.qb2ChildIterator;
	import TopDown.*;
	import TopDown.ai.*;
	import TopDown.ai.controllers.*;
	import TopDown.objects.*;
	
	

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2ControllerBrain extends qb2A_Brain
	{		
		public function qb2ControllerBrain()
		{
			init();
		}
		
		private function init():void
		{
			addEventListener(qb2ContainerEvent.ADDED_OBJECT,   addedOrRemovedObject, null, true);
			addEventListener(qb2ContainerEvent.REMOVED_OBJECT, addedOrRemovedObject, null, true);
		}
		
		protected function blendPortData():void
		{
			var iterator:qb2ChildIterator = qb2ChildIterator.getInstance(this);
			for (var object:qb2A_PhysicsObject; object = iterator.next(); ) 
			{
				var controller:qb2Controller = object as qb2Controller;
				
				if ( !controller )  continue;
				
				var controllerPort:qb2BrainPort = controller.brainPort;
				
				if ( !controllerPort.open )  continue;
				
				controller.relay_update();
				
				var hostPort:qb2BrainPort = host.brainPort;
				
				hostPort.BOOLEAN_PORT_1 = !hostPort.BOOLEAN_PORT_1 ? controllerPort.BOOLEAN_PORT_1 : true;
				hostPort.BOOLEAN_PORT_2 = !hostPort.BOOLEAN_PORT_1 ? controllerPort.BOOLEAN_PORT_2 : true;
				hostPort.BOOLEAN_PORT_3 = !hostPort.BOOLEAN_PORT_1 ? controllerPort.BOOLEAN_PORT_3 : true;
				hostPort.BOOLEAN_PORT_4 = !hostPort.BOOLEAN_PORT_1 ? controllerPort.BOOLEAN_PORT_4 : true;
				
				hostPort.INTEGER_PORT_1 += controllerPort.INTEGER_PORT_1;
				hostPort.INTEGER_PORT_2 += controllerPort.INTEGER_PORT_2;
				hostPort.INTEGER_PORT_3 += controllerPort.INTEGER_PORT_3;
				hostPort.INTEGER_PORT_4 += controllerPort.INTEGER_PORT_4;
				
				hostPort.NUMBER_PORT_1 += controllerPort.NUMBER_PORT_1;
				hostPort.NUMBER_PORT_2 += controllerPort.NUMBER_PORT_2;
				hostPort.NUMBER_PORT_3 += controllerPort.NUMBER_PORT_3;
				hostPort.NUMBER_PORT_4 += controllerPort.NUMBER_PORT_4;
				
				hostPort.STRING_PORT += controllerPort.STRING_PORT;
				
				hostPort.BITMASK_PORT |= controllerPort.BITMASK_PORT;
			}
		}

		protected override function update():void
		{
			host.brainPort.clear();
			blendPortData();
		}
		
		protected override function addedToWorld():void
		{
			for ( var i:int = 0; i < controllers.length; i++ )
			{
				controllers[i].relay_activated();
			}
		}
		
		protected override function removedFromWorld():void
		{
			for ( var i:int = 0; i < controllers.length; i++ )
			{
				controllers[i].relay_deactivated();
			}
		}
		
		private function addedOrRemovedObject(evt:qb2ContainerEvent):void
		{
			var controller:qb2Controller = evt.getChild() as qb2Controller;
			if ( controller )
			{
				if ( evt.type == qb2ContainerEvent.ADDED_OBJECT )
				{
					controller.setControllerBrain(this);
					if ( host && host.world )
					{
						controller.relay_activated();
					}
				}
				else if ( evt.type == qb2ContainerEvent.REMOVED_OBJECT )
				{
					controller.setControllerBrain(null);
					controller.relay_deactivated();
				}
			}
		}
	}
}