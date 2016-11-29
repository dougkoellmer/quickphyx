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
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2U_Units extends qb2UtilityClass
	{		
		public static function metersPerSecond_to_pixelsPerFrame(velocity:Number, pixelsPerMeter:Number, timeStep:Number):Number
			{  return velocity * pixelsPerMeter * timeStep;  }
		
		public static function pixelsPerFrame_to_metersPerSecond(velocity:Number, pixelsPerMeter:Number, timeStep:Number):Number
			{  return velocity / pixelsPerMeter / timeStep;  }
		
		public static function metersPerSecond_to_milesPerHour(velocity:Number):Number
			{  return velocity * qb2S_Units.SECONDS_PER_HOUR * qb2S_Units.MILES_PER_METER;  }
		
		public static function milesPerHour_to_metersPerSecond(velocity:Number):Number
			{  return velocity / qb2S_Units.SECONDS_PER_HOUR / qb2S_Units.MILES_PER_METER;  }
		
		public static function radsPerSec_to_rpm(radsPerSec:Number):Number
			{  return radsPerSec * qb2S_Units.SECONDS_PER_MINUTE / qb2S_Math.TAU  }
		
		public static function rpm_to_radsPerSec(rpm:Number):Number
			{  return rpm / qb2S_Units.SECONDS_PER_MINUTE * qb2S_Math.TAU;  }
		
		public static function pixelArea_to_metricArea(pixelArea:Number, pixelsPerMeter:Number):Number
			{  return pixelArea / (pixelsPerMeter * pixelsPerMeter);  }
			
		public static function metricArea_to_pixelArea(metricArea:Number, pixelsPerMeter:Number):Number
			{  return metricArea * (pixelsPerMeter * pixelsPerMeter);  }
		
		public static function pixelDensityUsingMass_to_metricDensity(mass:Number, pixelArea:Number, pixelsPerMeter:Number):Number
			{  return mass / pixelArea_to_metricArea(pixelArea, pixelsPerMeter);  }
			
		public static function pixelDensity_to_metricDensity(pixelDensity:Number, pixelsPerMeter:Number):Number
			{  return pixelDensity * (pixelsPerMeter * pixelsPerMeter);  }
			
		public static function metricDensity_to_pixelDensity(metricDensity:Number, pixelsPerMeter:Number):Number
			{  return metricDensity / (pixelsPerMeter * pixelsPerMeter);  }
		
		public static function pixelPoint_to_metricPoint(pixelPoint:qb2GeoPoint, pixelsPerMeter:Number):qb2GeoPoint
			{  return new qb2GeoPoint(pixelPoint.getX() / pixelsPerMeter, pixelPoint.getX() / pixelsPerMeter);  }
		
		public static function density_to_mass(density:Number, surfaceArea:Number):Number
			{  return density * surfaceArea;  }
		
		public static function mass_to_density(mass:Number, surfaceArea:Number):Number
			{  return mass / surfaceArea;  }
			
		public static function deg_to_rad(degrees:Number):Number
		{
			return degrees * (qb2S_Math.PI / 180.0);
		}
		
		public static function rad_to_deg(radians:Number):Number
		{
			return radians * (180.0 / qb2S_Math.PI);
		}
	}
}