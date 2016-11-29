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

package quickb2.physics.extras 
{
	import flash.display.*;
	import flash.utils.*;
	import quickb2.lang.*;
	
	import quickb2.debugging.*;
	import quickb2.debugging.drawing.qb2S_DebugDraw;
	import quickb2.event.*;
	import quickb2.physics.core.events.*;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.tangibles.qb2ContactEvent;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2Shape;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Terrain extends qb2Body
	{
		public function qb2Terrain(ubiquitous:Boolean = false) { init(ubiquitous); }
		
		private function init(ubiquitous:Boolean = false):void
		{
			_ubiquitous = ubiquitous;
			
			this.setPhysicsBoolean(qb2S_PhysicsProps.IS_GHOST, true);
			
			if ( !_ubiquitous )
			{
				addContactListeners();
			}
			
			addEventListener(qb2ContainerEvent.ADDED_TO_WORLD,     addedOrRemoved, null, true);
			addEventListener(qb2ContainerEvent.REMOVED_FROM_WORLD, addedOrRemoved, null, true);
		}
		
		private function addContactListeners():void
		{
			addEventListener(qb2ContactEvent.CONTACT_STARTED, contact, null, true);
			addEventListener(qb2ContactEvent.CONTACT_ENDED,   contact, null, true);
		}
		
		private function removeContactListeners():void
		{
			removeEventListener(qb2ContactEvent.CONTACT_STARTED, contact);
			removeEventListener(qb2ContactEvent.CONTACT_ENDED,   contact);
		}
		
		public function get ubiquitous():Boolean
			{  return _ubiquitous;  }
		private var _ubiquitous:Boolean = false;
		
		//--- Terrain is organized z-wise with other terrains globally whenever one is added to the world.
		private function addedOrRemoved(evt:qb2ContainerEvent):void
		{
			if ( evt.getType() == qb2ContainerEvent.ADDED_TO_WORLD )
			{
				m_world.registerGlobalTerrain(this);
			}
			else
			{
				evt.getAncestor().getWorld().unregisterGlobalTerrain(this);
			}
		}
		
		public function getFrictionZMultiplier():Number
			{  return _frictionZMultiplier;  }
		public function setFrictionZMultiplier(value:Number):void 
		{
			_frictionZMultiplier = value;
			
			if ( _ubiquitous )
			{
				if ( m_world )
				{
					//m_world.updateFrictionJoints();
				}
			}
			else
			{
				for (var key:* in shapeContactDict )
				{
					//(key as qb2A_PhysicsObject).updateFrictionJoints();
				}
			}
		}
		private var _frictionZMultiplier:Number = 1;
		
		private var shapeContactDict:Dictionary = new Dictionary(true);
		
		protected function contact(evt:qb2ContactEvent):void
		{
			var otherShape:qb2Shape = evt.getOtherShape();
			
			/*if ( evt.getType() == qb2ContactEvent.CONTACT_STARTED )
			{
				if ( !shapeContactDict[otherShape] )
				{
					shapeContactDict[otherShape] = 0 as int;
					
					otherShape.registerContactTerrain(this);
				}
				
				shapeContactDict[otherShape]++;
			}
			else
			{
				shapeContactDict[otherShape]--;
				
				if ( shapeContactDict[otherShape] == 0 ) 
				{
					delete shapeContactDict[otherShape];
					otherShape.unregisterContactTerrain(this);
				}
			}*/
		}
		
		/*public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			graphics.pushFillColor(qb2S_DebugDraw.terrainFillColor | qb2S_DebugDraw.fillAlpha);
			{
				super.drawDebug(graphics);
			}
			graphics.popFillColor();
		}*/
		
		public override function clone():*
		{
			var cloned:qb2Terrain = super.clone() as qb2Terrain;
			
			cloned.setFrictionZMultiplier(this.getFrictionZMultiplier());
			cloned._ubiquitous = this._ubiquitous;
			
			if ( cloned._ubiquitous )
			{
				cloned.removeContactListeners();
			}
			
			return cloned;
		}
	}
}