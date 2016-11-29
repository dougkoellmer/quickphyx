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

package quickb2.physics.driving 
{
	import quickb2.internals.qb2InternalSkidEntry;
	import quickb2.lang.operators.qb2_poolDelete;
	import quickb2.lang.operators.qb2_poolNew;
	import quickb2.math.geo.*;
	import flash.display.*;
	import flash.utils.*;
	import quickb2.event.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.objects.driving.configs.qb2CarTerrainConfig;
	import quickb2.lang.*
	import TopDown.internals.qb2InternalSkidEntry;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarTerrain extends qb2Terrain
	{
		public static const SKID_TYPE_ROLLING:uint = 1;
		public static const SKID_TYPE_SLIDING:uint = 2;
		
		public function qb2Terrain(ubiquitous:Boolean = false, config:qb2CarTerrainConfig) 
		{
			super(ubiquitous);
			
			init(config:qb2CarTerrainConfig);
		}
		
		private function init():void
		{
			setConfig(qb2CarTerrainConfig.useSharedInstanceByDefault ? qb2CarTerrainConfig.getInstance() : new qb2CarTerrainConfig());
		}
		
		public function getConfig():qb2CarTerrainConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2CarTerrainConfig):void
		{
			m_config = config;
		}
		private var m_config:qb2CarTerrainConfig = null;
		
		public function getRollingFrictionZMultiplier():Number
			{  return _frictionZMultiplier;  }
		public function setRollingFrictionZMultiplier(value:Number):void 
		{
			_rollingFrictionZMultiplier = value;
		}
		private var _rollingFrictionZMultiplier:Number = 1;

		public function addSkid(start:qb2GeoPoint, end:qb2GeoPoint, thickness:Number, type:uint):void
		{
			var entry:qb2InternalSkidEntry = qb2_poolNew(qb2InternalSkidEntry);
			entry.start = start;
			entry.end   = end;
			entry.thickness = thickness;
			entry.startTime = world.clock;
			entry.type = type;
			
			skidEntries[entry] = true;
		}
		
		private var skidEntries:Dictionary = new Dictionary(false);
		
		public override function draw(graphics:qb2I_Graphics2d):void
		{
			super.draw(graphics);
			
			drawSkids(graphics);
		}
		
		public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			super.drawDebug(graphics);
			
			if ( qb2F_DebugDrawOption.SKIDS & qb2S_DebugDraw.flags )
			{
				drawSkids(graphics);
			}
		}
		
		public override function drawSkids(graphics:qb2I_Graphics2d):void
		{
			var time:Number = world.clock;
			
			graphics.pushFillColor();
			{
				for ( var key:* in skidEntries )
				{
					var entry:qb2InternalSkidEntry = key as qb2InternalSkidEntry;
					var startAlpha:Number = entry.type == SKID_TYPE_SLIDING ? slidingSkidAlpha : rollingSkidAlpha;
					var color:uint = entry.type == SKID_TYPE_SLIDING ? slidingSkidColor : rollingSkidColor;
					
					if ( time - entry.startTime > skidDuration )
					{
						qb2_poolDelete(key);
						delete skidEntries[key];
					}
					else
					{
						var alpha:Number = startAlpha * (1 - (time - entry.startTime) / m_config.skidDuration );
						var alphaHex:uint = uint(alpha * (0xFF as Number)) << 24;
						
						graphics.pushLineStyle(entry.thickness, color | alphaHex);
						{
							graphics.moveTo(entry.start.x, entry.start.y);
							graphics.lineTo(entry.end.x,   entry.end.y);
						}
						graphics.popLineStyle();
						
					}
				}
			}
			graphics.popFillColor();
		}
		
		private var carContactDict:Dictionary = new Dictionary(true);
		
		protected override function contact(evt:qb2ContactEvent):void
		{
			super.contact(evt);
			
			var otherShape:qb2Shape = evt.otherShape;
			var carBody:qb2CarBody = otherShape.getAncestorOfType(qb2CarBody) as qb2CarBody;
			
			if ( !carBody )  return;
			
			if ( evt.type == qb2ContactEvent.CONTACT_STARTED )
			{
				if ( !carContactDict[carBody] )
				{
					carContactDict[carBody] = 0 as int;
					
					carBody.registerContactTerrain(this);
				}
				
				carContactDict[carBody]++;
			}
			else
			{
				carContactDict[carBody]--;
				
				if ( carContactDict[carBody] == 0 ) 
				{
					delete carContactDict[carBody];
					carBody.unregisterContactTerrain(this);
				}
			}
		}
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var cloned:qb2CarTerrain = super.clone(deep) as qb2CarTerrain;
			
			cloned.m_config.copy(this.m_config);
			
			return cloned;
		}
	}
}


import quickb2.math.geo.coords.qb2GeoPoint;

qb2_friend class qb2InternalSkidEntry
{
	qb2_friend var start:qb2GeoPoint;
	qb2_friend var end:qb2GeoPoint;
	qb2_friend var type:uint;
	qb2_friend var thickness:Number;
	qb2_friend var startTime:Number;
}