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
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import quickb2.lang.*
	import quickb2.lang.foundation.qb2E_ErrorCode;
	import quickb2.lang.qb2_throw;
	import quickb2.lang.foundation.qb2Error;
	import quickb2.event.qb2KeyboardEvent;
	import quickb2.input.qb2I_Keyboard;
	import quickb2.input.qb2I_Keyboard;
	
	
	import TopDown.*;
	

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2I_KeyboardController extends qb2Controller
	{
		public const keysUp:Vector.<uint> 	= new Vector.<uint>();
		public const keysDown:Vector.<uint>    = new Vector.<uint>();
		public const keysLeft:Vector.<uint>    = new Vector.<uint>();
		public const keyqb2I_ght:Vector.<uint>   = new Vector.<uint>();
	
		public function qb2I_KeyboardController(keyboard:qb2I_Keyboard):void
		{
			m_keyboard = keyboard;
			
			keysForward.push( 87, Keyboard.UP    );
			keysBack.push(    83, Keyboard.DOWN  )
			keysLeft.push(    65, Keyboard.LEFT  );
			keyqb2I_ght.push(   68, Keyboard.RIGHT );
			
			if ( (this as Object).constructor == qb2I_KeyboardController )
			{
				qb2_throw(new qb2Error(qb2E_ErrorCode.ABSTRACT_CLASS));
			}
		}
		
		protected override function activated():void
		{
			m_keyboard.addEventListener(qb2KeyboardEvent.KEY_DOWN, keyPressed);
			m_keyboard.addEventListener(qb2KeyboardEvent.KEY_UP,   keyPressed);
		}
		
		protected override function deactivated():void
		{
			m_keyboard.removeEventListener(qb2KeyboardEvent.KEY_DOWN, keyPressed);
			m_keyboard.removeEventListener(qb2KeyboardEvent.KEY_UP,   keyPressed);
		}
		
		protected override function update():void
		{
			
		}
		
		private function keyPressed(evt:qb2KeyboardEvent):void
		{
			if ( brainPort.open )
			{
				keyEvent(evt.getKeyCode(), evt.type == qb2KeyboardEvent.KEY_DOWN);
			}
		}

		protected virtual function keyEvent(keyCode:uint, down:Boolean):void
		{
		}
		
		public function getKeyboard():qb2I_Keyboard
			{  return m_keyboard;  }
		private var m_keyboard:qb2I_Keyboard;
	}
}