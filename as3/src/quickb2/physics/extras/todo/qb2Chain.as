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

package quickb2.physics.extras.todo 
{
	import quickb2.math.geo.*;
	import quickb2.debugging.qb2U_ToString.auto;
	
	import quickb2.objects.tangibles.*;
	
	/** TODO: This will be a bunch of links that are joined not by joints, but by actual geometry, using contact filters cleverly to actually link bodies.
	 *        This will probably require the whole chain to be a "bullet" so links don't easily pass through each other, which might make the chain too perforqb2Geoce heavy, who knows.
	 *        It should have an option to "simulate until rest", so that when it is added to the world it is already in a nice catenary curve.
	 * 
	 * @private
	 * @author Doug Koellmer
	 */	 
	public class qb2Chain extends qb2Group
	{
		public static const DISTANCE_BETWEEN_POINTS:Number = Number.NaN;
		public static const DEFAULT_GRAVITY:qb2GeoVector = new qb2GeoVector(0, 1);
		
		private static const negYGrav:qb2GeoVector = new qb2GeoVector(0, 1);
		
		public function qb2Chain()
		{
		}
		
		public function set(startPoint:qb2GeoPoint, endPoint:qb2GeoPoint, linkWidth:Number = 30, linkThickness:Number = 10, numLinks:uint = 10, length:Number = DISTANCE_BETWEEN_POINTS, gravity:qb2GeoVector = null):void
		{
			var lowestY:Number = Math.min(startPoint.y, endPoint.y);
		}
		
		public override function convertTo(T:Class):* 
			{  return qb2U_ToString.auto.formatToString(this, "qb2Chain");  }
	}
}