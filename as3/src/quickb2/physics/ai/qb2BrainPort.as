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

package quickb2.physics.ai
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public final class qb2BrainPort
	{
		public static const PORT_COUNT:int = 4;
		
		public const numberPorts:Vector.<Number> = new Vector.<Number>(PORT_COUNT, true);
		public const integerPorts:Vector.<int> = new Vector.<int>(PORT_COUNT, true));
		public var flagPort:uint = 0x0;
		
		public var open:Boolean = true;
		
		public function clear():void
		{
			var i:int;
			for ( i = 0; i < numberPorts.length; i++ )
			{
				numberPorts[i] = 0.0;
			}
			
			for ( i = 0; i < integerPorts.length; i++ )
			{
				integerPorts[i] = 0.0;
			}
			
			flagPort = 0x0;
		}
	}
}