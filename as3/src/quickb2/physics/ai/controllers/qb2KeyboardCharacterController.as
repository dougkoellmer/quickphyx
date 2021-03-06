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
	import flash.ui.*;
	import TopDown.objects.*;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2I_KeyboardCharacterController extends qb2I_KeyboardController
	{
		public const keyqb2U_nToggle:Vector.<uint> = new Vector.<uint>();
		
		public var walkSpeed:Number = 4;
		public var runSpeed:Number  = 8;
		
		public function qb2I_KeyboardCharacterController(keySource:Stage):void
		{
			super(keySource);
			
			keyqb2U_nToggle.push(Keyboard.SHIFT);
		}
		
		protected override function activated():void
		{
			if ( host is qb2CharacterBody )
			{
				brainPort.open = true;
				super.activated();
			}
			else
			{
				brainPort.open = false;
			}
		}
		
		protected override function update():void
		{
			super.update();
			
			brainPort.clear();
			
			var forwardDown:Boolean = keyboard.isDown(keysForward);
			var backDown:Boolean = keyboard.isDown(keysBack);
			var leftDown:Boolean = keyboard.isDown(keysLeft);
			var rightDown:Boolean = keyboard.isDown(keyqb2I_ght);
			
			var lastLeftRightDown:uint = keyboard.lastKeyPressed(keysLeft, keyqb2I_ght);
			var lastForwardBackDown:uint = keyboard.lastKeyPressed(keysForward, keysBack);
			
			//--- Find out which direction (N, S, E, W, NW, SW, NE, or SE) the character should be moving.
			//--- This directional vector is normalized by qb2CharacterBody so as not to move faster in NE, SE, NW, SW directions.
			if ( lastForwardBackDown )
			{
				brainPort.NUMBER_PORT_1 = keysForward.indexOf(lastForwardBackDown) >= 0 ? -1.0 : 1.0;
			}
			if ( lastLeftRightDown )
			{
				brainPort.NUMBER_PORT_2 = keysLeft.indexOf(lastLeftRightDown) >= 0 ? -1.0 : 1.0;
			}
			
			//--- Provide a 'facing' direction indicated by the last key pressed.  This provides qb2CharacterBody
			//--- (or subclasses) a way to know which direction the character graphically should be facing.
			if ( !host.brainPort.INTEGER_PORT_2 )
			{
				var lastDown:uint = keyboard.lastKeyPressed(lastLeftRightDown, lastForwardBackDown);
				if (keysForward.indexOf(lastDown) >= 0 )
				{
					brainPort.INTEGER_PORT_2 = qb2CharacterBody.FACING_UP;
				}
				else if ( keysBack.indexOf(lastDown) >= 0  )
				{
					brainPort.INTEGER_PORT_2 = qb2CharacterBody.FACING_DOWN;
				}
				else if ( keysLeft.indexOf(lastDown) >= 0  )
				{
					brainPort.INTEGER_PORT_2 = qb2CharacterBody.FACING_LEFT;
				}
				else if ( keyqb2I_ght.indexOf(lastDown) >= 0  )
				{
					brainPort.INTEGER_PORT_2 = qb2CharacterBody.FACING_RIGHT;
				}
				else
				{
					brainPort.INTEGER_PORT_2 = qb2CharacterBody.FACING_LAST;
				}
			}
			
			var multiplier:Number = keyboard.isDown(keyqb2U_nToggle) ? runSpeed : walkSpeed;
			var vector:qb2GeoVector = qb2GeoVector.reusable.set(brainPort.NUMBER_PORT_1, brainPort.NUMBER_PORT_2);
			vector.setLength(multiplier);
			
			brainPort.NUMBER_PORT_1 = vector.x;
			brainPort.NUMBER_PORT_2 = vector.y;
		}
	}
}