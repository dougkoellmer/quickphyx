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
	
	/** TODO: This should be like qb2SoftPoly, but for long narrow shapes.
	 * 
	 * @private
	 * @author Doug Koellmer
	 */	 
	public class qb2SoftRod extends qb2Group
	{
		public function qb2SoftRod(initBeg:qb2GeoPoint, initEnd:qb2GeoPoint, initWidth:Number = 10, initNumSegs:uint = 2, initMass:Number = 1, initContactGroupIndex:int = -1) 
		{
			set(initBeg, initEnd, initWidth, initNumSegs);
			if ( initMass )  mass = initMass;
			contactGroupIndex = initContactGroupIndex;
		}
		
		public function set(newBeg:qb2GeoPoint, newEnd:qb2GeoPoint, newWidth:Number = 10, newNumSegs:uint = 2):void
		{
			
		}
		
		public override function convertTo(T:Class):* 
			{  return qb2U_ToString.auto.formatToString(this, "qb2SoftRod");  }
	}
}