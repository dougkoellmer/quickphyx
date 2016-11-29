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
	import quickb2.math.geo.*;
	import flash.display.*;
	import flash.events.*;
	import quickb2.lang.*
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2MouseController extends qb2Controller
	{
		public var positionalSpace:InteractiveObject = null;
		public const activeLayers:Array = [];
		
		protected const lastDirection:qb2GeoVector = new qb2GeoVector();
		
		public function qb2MouseController(mouseSource:Stage)
		{
			_mouseSource = mouseSource;
			
			_mouse = new qb2Mouse(_mouseSource);
			
			if ( (this as Object).constructor == qb2MouseController )
			{
				qb2_throw(new qb2Error(qb2E_ErrorCode.ABSTRACT_CLASS;
			}
		}
		
		public function addActiveLayer(aTarget:InteractiveObject):void
		{
			if ( aTarget )
			{
				activeLayers.push(aTarget);
			}
		}
		
		public function removeActiveLayer(aTarget:InteractiveObject):void
		{
			var index:int = activeLayers.indexOf(aTarget);
			if ( index >= 0 )
			{
				activeLayers.splice(index, 1);
			}
		}
		
		protected override function activated():void
		{
			_mouse.addEventListener(MouseEvent.MOUSE_UP,   mouseEventPrivate, false, 0, true);
			_mouse.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventPrivate, false, 0, true);
			_mouse.addEventListener(MouseEvent.CLICK,      mouseEventPrivate, false, 0, true);
		}
		
		protected override function deactivated():void
		{
			_mouse.removeEventListener(MouseEvent.MOUSE_UP,   mouseEventPrivate, false);
			_mouse.removeEventListener(MouseEvent.MOUSE_DOWN, mouseEventPrivate, false);
			_mouse.removeEventListener(MouseEvent.CLICK,      mouseEventPrivate, false);
		}
		
		private function mouseEventPrivate(evt:MouseEvent):void
		{
			if ( brainPort.open  )
			{
				mouseEvent(evt);
			}
		}
		
		protected virtual function mouseEvent(evt:MouseEvent):void
		{
			
		}
		
		protected final function get mouseIsDown():Boolean
		{
			var hitTarget:Boolean = false;
			var mouseDown:Boolean = mouse.isDown;
			
			if ( mouseDown )
			{
				for (var i:int = 0; i < activeLayers.length; i++) 
				{
					var target:* = activeLayers[i];
					
					var currParent:DisplayObject = mouse.lastEventTarget as DisplayObject;
					while (currParent )
					{
						if ( target is Class )
						{
							if ( currParent is (target as Class) )
							{
								hitTarget = true;
								break;
							}
						}
						else
						{
							if ( target == currParent )
							{
								hitTarget = true;
								break;
							}
						}
						
						currParent = currParent.parent;
					}
				}
			}
			
			return mouseDown && hitTarget;
		}
		
		protected final function get mousePosition():qb2GeoPoint
		{
			return positionalSpace ? new qb2GeoPoint(positionalSpace.mouseX, positionalSpace.mouseY) : mouse.position;
		}
		
		public function get mouse():qb2Mouse
			{  return _mouse;  }
		private var _mouse:qb2Mouse;
		
		public function get mouseSource():Stage
			{  return _mouseSource;  }
		private var _mouseSource:Stage;
	}
}