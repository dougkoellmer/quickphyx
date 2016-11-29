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

package quickb2.thirdparty.flash
{
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.math.geo.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	import quickb2.event.*;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventDispatcher;
	import quickb2.event.qb2EventType;
	import quickb2.event.qb2I_EventDispatcher;
	import quickb2.platform.input.qb2A_Mouse;
	import quickb2.platform.input.qb2MouseEvent;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2FlashMouse extends qb2A_Mouse
	{
		private static const TYPE_MAP:Object =
		{
			mouseDown  : qb2MouseEvent.MOUSE_DOWN,
			mouseUp    : qb2MouseEvent.MOUSE_UP,
			click      : qb2MouseEvent.MOUSE_CLICKED,
			mouseMove  : qb2MouseEvent.MOUSE_ENTERED_SCREEN,
			mouseLeave : qb2MouseEvent.MOUSE_EXITED_SCREEN,
			mouseWheel : qb2MouseEvent.MOUSE_WHEEL_SCROLLED
		};
		
		private static var s_lastInstanceCreated:qb2FlashMouse = null;
		private static const s_instanceMap:Dictionary = new Dictionary(true);
		
		private var m_lastEventType:String = "";
		private var m_interactiveObject:InteractiveObject;
		private var m_lastEventTarget:Object = null;
		
		public function qb2FlashMouse(interactiveObject:InteractiveObject = null) 
		{
			setInteractiveObject(interactiveObject);
		}
		
		public static function getInstance(interactiveObject:InteractiveObject = null):qb2FlashMouse
		{
			if ( interactiveObject != null)
			{
				var instance:qb2FlashMouse = s_instanceMap[interactiveObject] as qb2FlashMouse;
				
				if ( instance != null )
				{
					instance.setInteractiveObject(interactiveObject);
				}
				else
				{
					instance = new qb2FlashMouse(interactiveObject);
					s_instanceMap[interactiveObject] = instance;
				}
				
				s_lastInstanceCreated = instance;
				
				return instance;
			}
			else
			{
				if ( s_lastInstanceCreated == null )
				{
					s_lastInstanceCreated = new qb2FlashMouse();
				}
				
				return s_lastInstanceCreated;
			}
		}
		
		private function mouseEvent(nativeEvent:Event):void
		{
			var reventType:qb2EventType = null;
			if ( TYPE_MAP[nativeEvent.type] != null )
			{
				reventType = TYPE_MAP[nativeEvent.type];
			}
			else
			{
				qb2U_Error.throwError(new Error("No type map found"));
			}
			
			/*if ( QB2_DEBUG_MODE )
			{
				qb2_notify("qb2FlashMouse dispatching " + reventType + ".");
			}*/
			
			var event:qb2MouseEvent = qb2GlobalEventPool.checkOut(reventType) as qb2MouseEvent;
			
			if ( reventType == qb2MouseEvent.MOUSE_WHEEL_SCROLLED )
			{
				event.initialize((nativeEvent as MouseEvent).delta);
			}
			
			dispatchEvent(event);
			
			if ( nativeEvent.type == MouseEvent.MOUSE_DOWN )
			{
				m_stage.addEventListener(MouseEvent.MOUSE_UP, mouseEvent, false, 0, true);
			}
			else if ( nativeEvent.type == MouseEvent.MOUSE_UP )
			{
				m_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseEvent, false);
			}
			
			m_lastEventType   = nativeEvent.type;
			m_lastEventTarget = nativeEvent.target;
		}
		
		public function getLastEventType():String
		{
			return m_lastEventType;
		}
		
		public function getLastEventTarget():Object
		{
			return m_lastEventTarget;
		}
		
			
		public override function getCursorX():Number
			{  return m_interactiveObject.mouseX;  }
			
		public override function getCursorY():Number
			{  return m_interactiveObject.mouseY;  }
		
		public function setInteractiveObject(interactiveObject:InteractiveObject):void
		{
			if ( interactiveObject == m_interactiveObject )  return;
			
			if ( m_interactiveObject )
			{
				m_interactiveObject.removeEventListener(MouseEvent.MOUSE_DOWN,	mouseEvent);
				m_interactiveObject.removeEventListener(MouseEvent.MOUSE_UP,	mouseEvent);
				m_interactiveObject.removeEventListener(MouseEvent.CLICK,		mouseEvent);
				m_interactiveObject.removeEventListener(MouseEvent.MOUSE_WHEEL,	mouseEvent);
				
				m_interactiveObject.removeEventListener(Event.ADDED_TO_STAGE,     addedOrRemoved);
				m_interactiveObject.removeEventListener(Event.REMOVED_FROM_STAGE, addedOrRemoved);
			}
			
			if ( m_stage )
			{
				m_stage.removeEventListener(Event.MOUSE_LEAVE,     enterOrExitEvent);
				m_stage.removeEventListener(MouseEvent.MOUSE_MOVE, enterOrExitEvent);
			}
			
			m_interactiveObject = interactiveObject;
			m_stage = m_interactiveObject as Stage;
			
			if ( m_interactiveObject )
			{
				m_interactiveObject.addEventListener(MouseEvent.MOUSE_DOWN, mouseEvent, false, 0, true );
				m_interactiveObject.addEventListener(MouseEvent.CLICK,      mouseEvent, false, 0, true );
				m_interactiveObject.addEventListener(MouseEvent.MOUSE_WHEEL,      mouseEvent, false, 0, true );
			}
			
			if ( m_stage )
			{
				m_stage.addEventListener(Event.MOUSE_LEAVE, enterOrExitEvent, false, 0, true);
			}
			else
			{
				if ( m_interactiveObject.stage )
				{
					m_stage = m_interactiveObject.stage;
					m_interactiveObject.addEventListener(Event.REMOVED_FROM_STAGE, addedOrRemoved, false, 0, true);
					m_stage.addEventListener(Event.MOUSE_LEAVE, enterOrExitEvent, false, 0, true);
				}
				else
				{
					m_interactiveObject.addEventListener(Event.ADDED_TO_STAGE, addedOrRemoved, false, 0, true);
				}
			}
		}
		
		public function getInteractiveObject():InteractiveObject
		{
			return m_interactiveObject;
		}
		
		private function addedOrRemoved(evt:Event):void
		{
			if ( evt.type == Event.ADDED_TO_STAGE )
			{
				m_stage = m_interactiveObject.stage;
				m_stage.addEventListener(Event.MOUSE_LEAVE, enterOrExitEvent, false, 0, true);
				
				m_interactiveObject.addEventListener(Event.REMOVED_FROM_STAGE, addedOrRemoved, false, 0, true);
				m_interactiveObject.removeEventListener(Event.ADDED_TO_STAGE, addedOrRemoved, false);
			}
			else
			{
				m_stage.removeEventListener(Event.MOUSE_LEAVE,     enterOrExitEvent);
				m_stage.removeEventListener(MouseEvent.MOUSE_MOVE, enterOrExitEvent);
				
				m_interactiveObject.addEventListener(Event.ADDED_TO_STAGE, addedOrRemoved, false, 0, true);
				m_interactiveObject.removeEventListener(Event.REMOVED_FROM_STAGE, addedOrRemoved, false);
				
				m_stage = null;
			}
		}
		
		private function enterOrExitEvent(evt:Event):void
		{
			if ( !m_stage )  return;
			
			if ( evt.type == MouseEvent.MOUSE_MOVE )
			{
				mouseEvent(evt);
				m_stage.removeEventListener(MouseEvent.MOUSE_MOVE, enterOrExitEvent, false);
				m_stage.addEventListener(Event.MOUSE_LEAVE, enterOrExitEvent, false, 0, true);
			}
			else
			{
				mouseEvent(evt);
				m_stage.addEventListener(MouseEvent.MOUSE_MOVE, enterOrExitEvent, false, 0, true);
				m_stage.removeEventListener(Event.MOUSE_LEAVE, enterOrExitEvent, false);
			}
		}
		
		private var m_stage:Stage;
	}
}