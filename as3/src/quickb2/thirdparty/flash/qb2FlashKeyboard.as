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
	import flash.display.*;
	import flash.display.InteractiveObject;
	import flash.events.*;
	import flash.utils.*;
	import quickb2.event.*;
	import quickb2.lang.*
	import quickb2.event.qb2Event;
	
	import quickb2.event.qb2EventDispatcher;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2FlashKeyboard extends qb2A_Keyboard
	{		
		public function qb2FlashKeyboard(interactiveObject:InteractiveObject = null):void
		{
			setInteractiveObject(interactiveObject);
		}
		
		public static function getInstance(interactiveObject:InteractiveObject = null):qb2FlashKeyboard
		{
			if ( interactiveObject )
			{
				var instance:qb2FlashKeyboard = s_instanceMap[interactiveObject] as qb2FlashKeyboard;
				
				if ( instance )
				{
					//instance.setInteractiveObject(interactiveObject);
				}
				else
				{
					instance = new qb2FlashKeyboard(interactiveObject);
					s_instanceMap[interactiveObject] = instance;
				}
				
				s_lastInstanceCreated = instance;
				
				return instance;
			}
			else
			{
				if ( !s_lastInstanceCreated )
				{
					s_lastInstanceCreated = new qb2FlashKeyboard();
				}
				
				return s_lastInstanceCreated;
			}
			
			return s_instance;
		}
		
		private static var s_lastInstanceCreated:qb2FlashKeyboard = null;
		private static const s_instanceMap:Dictionary = new Dictionary(true);
		
		public function getInteractiveObject():InteractiveObject
		{
			return m_interactiveObject;
		}
		
		public function setInteractiveObject(interactiveObject:InteractiveObject):void
		{
			if ( m_interactiveObject)
			{
				m_interactiveObject.removeEventListener(KeyboardEvent.KEY_DOWN, keyEvent, false);
				m_interactiveObject.removeEventListener(KeyboardEvent.KEY_UP,   keyEvent, false);
			}
			
			m_interactiveObject = interactiveObject;
			
			if ( m_interactiveObject )
			{
				m_interactiveObject.addEventListener(KeyboardEvent.KEY_DOWN, keyEvent, false, 0, true );
				m_interactiveObject.addEventListener(KeyboardEvent.KEY_UP,   keyEvent, false, 0, true );	
			}
		}
		private var m_interactiveObject:InteractiveObject;
		
		private function keyEvent(evt:KeyboardEvent):void
		{
			var keyCode:uint = evt.keyCode;
			var down:Boolean = evt.type == KeyboardEvent.KEY_DOWN;
			
			var event:qb2KeyboardEvent = qb2GlobalEventPool.checkOut(down ? qb2KeyboardEvent.KEY_DOWN : qb2KeyboardEvent.KEY_UP) as qb2KeyboardEvent;
			event.m_keyCode = keyCode;
			dispatchEvent(event);
		}
	}
}