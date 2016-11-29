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
	import flash.display.Graphics;
	
	public class qb2U_Formula extends qb2UtilityClass
	{		
		public static function circleArea(radius:Number):Number
		{
			return (radius * radius) * qb2S_Math.PI;
		}
		
		private static function circleSegmentArea_theta_lte_PI(radius:Number, theta_lte_PI:Number):Number
		{
			return ((radius * radius) / 2) * (theta_lte_PI - Math.sin(theta_lte_PI));
		}
		
		public static function circleSegmentArea(radius:Number, theta:Number):Number
		{
			if ( theta >= qb2S_Math.TAU )
			{
				return circleArea(radius);
			}
			else if ( theta > qb2S_Math.PI )
			{
				var thetaRemainder:Number = theta - qb2S_Math.PI;
				var remainderArea:Number = circleSegmentArea_theta_lte_PI(radius, thetaRemainder);
				return circleArea(radius) - remainderArea;
			}
			else
			{
				return circleSegmentArea_theta_lte_PI(radius, theta);
			}
		}
		
		public static function circleCircumference(radius:Number):Number
		{
			return 2 * qb2S_Math.PI * radius;
		}
		
		public static function ellipseArea(majorRadius:Number, minorRadius:Number):Number
		{
			return qb2S_Math.PI * majorRadius * minorRadius;
		}
		
		public static function ellipse(majorAxis:Number, minorAxis:Number, x:Number, y:Number):Number
		{
			var first:Number = x / majorAxis;
			var second:Number = y / minorAxis;
			return first * first + second * second;
		}
		
		public static function ellipseCircumferenceApproximate(majorAxis:Number, minorAxis:Number):Number
		{
			var a:Number = majorAxis;
			var b:Number = minorAxis;
			var component:Number = (a - b) / (a + b);
			var component_2:Number = component * component;
			var numerator:Number = 3 * component_2;
			var denominator:Number = 10 + Math.sqrt(4 - 3 * component_2);
			
			var approximation:Number = Math.PI * (a + b) * (1 + (numerator / denominator));
			
			return approximation;
		}
		
		public static function ellipseParametricX(majorAxis:Number, radians:Number):Number
		{
			return majorAxis * Math.cos(radians);
		}
		
		public static function ellipseParametricY(minorAxis:Number, radians:Number):Number
		{
			return minorAxis * Math.sin(radians);
		}
		
		public static function quadraticFormula(a:Number, b:Number, c:Number, values_out:Vector.<Number>):Boolean
		{
			var determinant:Number = b * b - 4.0 * a * c;
			
			if ( determinant > 0.0 )
			{
				var denominator:Number = 2 * a;
				
				if ( denominator != 0 )
				{
					var determinantRoot:Number = Math.sqrt(determinant);
					
					values_out[0] = ( -b + determinantRoot) / denominator;
					values_out[1] = ( -b - determinantRoot) / denominator;
					
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
	}
}