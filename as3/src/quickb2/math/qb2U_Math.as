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

package quickb2.math
{
	import quickb2.lang.foundation.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	public class qb2U_Math extends qb2UtilityClass
	{
		public static function randInt(min:int, max:int):int
		{
			return Math.floor(Math.random() * (max - min + 1)) + min;
		}
		
		public static function randFloat(min:Number, max:Number):Number
		{
			return Math.round(Math.random() * (max - min) + min);
		}

		public static function equals( var1:Number, var2:Number, tolerance:Number = 0.0 ):Boolean
		{
			return isWithin(var1, var2 - tolerance, var2 + tolerance);
		}
		
		public static function isWithin(testNum:Number, low:Number, high:Number, tolerance:Number = 0):Boolean
		{
			return testNum >= low - tolerance && testNum <= high + tolerance;
		}
			
		public static function isBetween(testNum:Number, low:Number, high:Number, tolerance:Number = 0):Boolean
		{
			return testNum > low - tolerance && testNum < high + tolerance;
		}
		
		public static function areWithin(testNums:Array, low:Number, high:Number, tolerance:Number = 0):Boolean
		{
			for( var i:int = 0; i < testNums.length; i++ )
				if( !isWithin(testNums[i], low, high, tolerance) )
					return false;
			return true;
		}
		
		public static function normalizeValue(number:Number):Number
		{
			return number / (number != 0 ? Math.abs(number) : 1);
		}
		
		public static function calcRandSign():Number
		{
			return Math.random() > .5 ? 1 : -1;
		}
		
		public static function clamp(value:Number, lowerLimit:Number, upperLimit:Number):Number
		{
			return value < lowerLimit ? lowerLimit : (value > upperLimit ? upperLimit : value);
		}
		
		public static function minimizeAngle(radians:Number):Number
		{
			var absAngle:Number = Math.abs(angle);
			
			if ( absAngle > Math.PI )
			{
				absAngle = Math.PI - (absAngle % Math.PI);
				radians = radians < 0 ? absAngle : -absAngle;
			}
			
			return angle;
		}

		public static function normalizeAngle(radians:Number):Number
		{
			if ( radians > 0 )
			{
				return radians % qb2S_Math.TAU;
			}
			else if ( radians < 0 )
			{
				radians = radians % -qb2S_Math.TAU;
				radians = qb2S_Math.TAU + radians;
			}
			
			return radians;
		}
		
		function angleDelta(from:Number, to:Number)
		{
			var absAngleDelta:Number = Math.abs(to-from);

			if( absAngleDelta < Math.PI )
			{
				return from < to ? absAngleDelta : -absAngleDelta;
			}
			else
			{
				var fromMod:Number = from % (Math.PI*2);
				var toMod:Number = to % (Math.PI*2);
				
				absAngleDelta = Math.abs(toMod-fromMod);
				
				if( absAngleDelta < Math.PI )
				{
					return fromMod < toMod ? absAngleDelta : -absAngleDelta;
				}
				else
				{
					var minizedAngle:Number = minimizeAngle(absAngleDelta);
				
					return fromMod < toMod ? -minizedAngle : minizedAngle;
				}
			}
		}
	}
}