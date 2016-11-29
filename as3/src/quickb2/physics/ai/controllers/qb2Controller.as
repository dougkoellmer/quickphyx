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

package quickb2.physics.ai.controllers 
{	
	import quickb2.lang.*
	import quickb2.lang.foundation.qb2E_ErrorCode;
	import quickb2.lang.qb2_throw;
	import quickb2.lang.foundation.qb2Error;
	import QuickB2.objects.ai.brains.qb2ControllerBrain;
	import quickb2.objects.ai.qb2BrainPort;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import TopDown.*;
	import TopDown.ai.*;
	import TopDown.ai.brains.*;
	import TopDown.objects.*;
	

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Controller extends qb2A_PhysicsObject
	{
		public const brainPort:qb2BrainPort = new qb2BrainPort();
		
		public function qb2Controller():void
		{
			if ( (this as Object).constructor == qb2Controller )
			{
				qb2_throw(new qb2Error(qb2E_ErrorCode.ABSTRACT_CLASS));
			}
		}
		
		protected virtual function activated():void {}
			
		protected virtual function deactivated():void { }
		
		protected virtual function update():void { }
		
		qb2_friend function relay_update():void
		{
			if( brainPort.open )
				update();
		}

		qb2_friend function relay_activated():void
		{
			brainPort.clear();
			activated();
		}
		
		qb2_friend function relay_deactivated():void
		{
			deactivated();
			brainPort.clear();
		}
		
		qb2_friend function setControllerBrain(aBrain:qb2ControllerBrain):void
			{  m_controllerBrain = aBrain;  }
		private var m_controllerBrain:qb2ControllerBrain = null;
		
		public function getBrain():qb2ControllerBrain
			{  return m_controllerBrain;  }
	}
}