/**
 * Copyright (c) 2010 Doug Koellmer
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

package quickb2.display.retained 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public interface qb2I_Actor 
	{
		function getX():Number;
		function setX(value:Number):void;
		
		function getY():Number;
		function setY(value:Number):void;
		
		function getRotation():Number;
		function setRotation(value:Number):void;
		
		function scale(xValue:Number, yValue:Number):void;
		
		function getActorParent():qb2I_ActorContainer;
		
		function clone():qb2I_Actor;
	}
}