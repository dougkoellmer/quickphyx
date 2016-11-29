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

package quickb2.thirdparty.flash 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.display.retained.qb2I_Actor;
	import quickb2.display.retained.qb2I_ActorContainer;
	import quickb2.display.retained.qb2I_ArrayBasedActorContainer;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2FlashMovieClipActor extends MovieClip implements qb2I_ArrayBasedActorContainer
	{
		public function getX():Number
			{  return x;  }
		public function setX(value:Number):qb2I_Actor
			{  x = value;  return this;  }
		
		public function getY():Number
			{  return y;  }
		public function setY(value:Number):qb2I_Actor
			{  y = value;  return this;  }
		
		/*public function getPosition():qb2GeoPoint
			{  return new qb2GeoPoint(x, y);  }
		public function setPosition(point:qb2GeoPoint):qb2I_Actor
			{  x = point.getX();  y = point.getY();  return this;  }*/
		
		public function getRotation():Number
			{  return rotation;  }
		public function setRotation(value:Number):qb2I_Actor
			{  rotation = value;  return this;  }
			
		public function scale(xValue:Number, yValue:Number):qb2I_Actor
		{
			qb2U_FlashActor.scaleActor(this, xValue, yValue);
			return this;
		}
		
		public function getActorParent():qb2I_ActorContainer
		{
			return parent as qb2I_ActorContainer;
		}
		
		public function clone(deep:Boolean = true):qb2I_Actor
		{
			return qb2U_FlashActor.cloneSprite(this) as qb2I_Actor
		}
		
		public function addActorChild(actor:qb2I_Actor):void
		{
			addChild(actor as DisplayObject);
		}
		
		public function removeActorChild(actor:qb2I_Actor):void
		{
			removeChild(actor as DisplayObject);
		}
		
		public function getActorChildAt(index:int):qb2I_Actor
		{
			return getChildAt(index) as qb2I_Actor;
		}
		
		public function removeActorChildAt(index:int):qb2I_Actor
		{
			return removeChildAt(index) as qb2I_Actor;
		}
		
		public function getActorChildCount():int
		{
			return this.numChildren;
		}
	}
}