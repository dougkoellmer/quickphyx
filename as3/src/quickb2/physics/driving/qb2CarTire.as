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
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	
	import quickb2.math.general.*;
	import quickb2.math.geo.*;
	import flash.events.*;
	import quickb2.debugging.*;
	import quickb2.debugging.drawing.qb2S_DebugDraw;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.event.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.objects.driving.configs.qb2CarTireConfig;
	import QuickB2.objects.driving.qb2CarBody;
	import quickb2.event.qb2Event;
	
	import TopDown.*;
	import TopDown.debugging.*;
	import TopDown.internals.*;
	import TopDown.objects.*;

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarTire extends qb2Body
	{
		qb2_friend static const QUAD_LEFT:uint = 1;
		qb2_friend static const QUAD_RIGHT:uint = 2;
		qb2_friend static const QUAD_TOP:uint = 4;
		qb2_friend static const QUAD_BOT:uint = 8;
		
		qb2_friend var quadrant:uint = 0;

		qb2_friend var _position:qb2GeoPoint;
		
		qb2_friend var _radius:Number = 10;
		qb2_friend var _width:Number = 7;
		
		qb2_friend var _rotation:Number = 0;
		
		qb2_friend var _metricInertia:Number;
		qb2_friend var _metricRadius:Number;
		qb2_friend var _metricWidth:Number;
		
		qb2_friend var m_mass:Number = 20;
		
		qb2_friend const _linearVelocity:qb2GeoVector = new qb2GeoVector();
		
		qb2_friend var _isSkidding:Boolean = false, _wasSkidding:Boolean = false;
		qb2_friend var _currTurnAngle:Number = 0;
		qb2_friend var _baseRadsPerSec:Number = 0;
		qb2_friend var _extraRadsPerSec:Number = 0;
		
		//qb2_friend var terrains:Vector.<qb2Terrain> = new Vector.<qb2Terrain>();

		qb2_friend var _load:Number = 0;
		qb2_friend var m_massShare:Number = 0;
		
		public function qb2CarTire(config_nullable:qb2CarTireConfig = null)
		{
			super();
			
			init(config_nullable);
		}
		
		private function init(config:qb2CarTireConfig):void
		{
			addEventListener(qb2ContainerEvent.REMOVED_FROM_WORLD, addedOrRemoved, null, true);
			
			setConfig(config ? config : (qb2CarTireConfig.useSharedInstanceByDefault ? qb2CarTireConfig.getInstance() : new qb2CarTireConfig()));
		}
		
		public function getConfig():qb2CarTireConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2CarTireConfig):void
		{
			m_config = config;
		}
		private var m_config:qb2CarTireConfig = null;
		
		private function addedOrRemoved(evt:qb2Event):void
		{
			lastWorldPos = null;
		}
		
		qb2_friend var lastWorldPos:qb2GeoPoint = null;
		
		public function getCarBody():qb2CarBody
			{  return _carBody;  }
		qb2_friend var _carBody:qb2CarBody;
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var tire:qb2CarTire = super.clone(deep) as qb2CarTire;
			
			tire.position.copy(this.position);
			tire.mass = this.mass;
			tire.radius = this.radius;
			tire.width = this.width;
			
			return tire;
		}
		
		private function updateActor():void
		{
			if ( !actor )  return;
			
			actor.setPosition(position);
			actor.setRotation(_currTurnAngle * TO_DEG);
		}
		
		public function getLinearVelocity():qb2GeoVector
			{  return _linearVelocity;  }
		
		/*public function get numTerrains():uint
			{  return terrains.length;  }
		
		public function getTerrainAt(index:uint):qb2Terrain
			{  return terrains[index];  }
			
		public function get highestTerrain():qb2Terrain
		{
			if ( !terrains.length )  return null;
		
			var highest:qb2Terrain = terrains[0];
			for ( var i:uint = 1; i < terrains.length; i++)
			{
				var terrain:qb2Terrain = terrains[i];
				if ( terrain.priority > highest.priority )
				{
					highest = terrain;
				}
			}
			
			return highest;
		}*/

		
		
		private var metricsValidated:Boolean = false;
		
		qb2_friend function calcMetricInertia():Number
		{
			validateMetrics();
			return _metricInertia;
		}
		
		qb2_friend function calcMetricRadius():Number
		{
			validateMetrics();
			return _metricRadius;
		}
		qb2_friend function setMetricRadius(value:Number):void
			{  radius = value * worldPixelsPerMeter;  }
		
		qb2_friend function calcMetricWidth():Number
		{
			validateMetrics();
			return _metricWidth;
		}
		qb2_friend function setMetricWidth(value:Number):void
			{  width = value * worldPixelsPerMeter;  }
		
		public function getRadius():Number
			{  return _radius;  }
		public function setRadius(value:Number):void
		{
			_radius = value;
			invalidateMetrics();
		}
		
		public function getWidth():Number
			{  return _width;  }
		public function setWidth(value:Number):void
		{
			_width = value;
			invalidateMetrics();
		}
		
		private function validateMetrics():void
		{
			if ( metricsValidated )  return;
			
			_metricRadius = _radius / worldPixelsPerMeter;
			_metricWidth = _width / worldPixelsPerMeter;
			_metricInertia = (m_mass * (_metricRadius * _metricRadius)) / 2;
			
			metricsValidated = true;
		}
		
		qb2_friend function invalidateMetrics():void
		{
			metricsValidated = false;
		}
		
		
		public function getPosition():qb2GeoPoint
			{  return _position;  }
		public function setPosition(newPoint:qb2GeoPoint):void
		{
			if ( _position )  _position.removeEventListener(qb2MathEvent.ENTITY_UPDATED, pointUpdated);
			_position = newPoint;
			_position.addEventListener(qb2MathEvent.ENTITY_UPDATED, pointUpdated, null, true);
			pointUpdated(null);
		}
		
		public override function scale(xValue:Number, yValue:Number, origin:qb2GeoPoint = null):void
		{
			_position.scaleByNumber(xValue, yValue, origin);
			width *= Math.abs(xValue);
			radius *= Math.abs(yValue);
		}
		
		private function pointUpdated(evt:qb2MathEvent):void
		{
			if ( _carBody )
			{
				_carBody.calcTireShares();
			}
				
			updateActor();
		}

		public function calcWorldPosition(point_out:qb2GeoPoint):void
		{
			if ( _carBody )
			{
				return _carBody.calcWorldPoint(_position);
			}
		}
		
		public function calcWorldNormal(vector_out:qb2GeoVector):void
		{
			var localVec:qb2GeoVector = qb2GeoVector.newRotVector(0, -1, _currTurnAngle);
			if ( _carBody )
			{
				return _carBody.getWorldVector(localVec);
			}
			
			return localVec;
		}
			
		public function isSkidding():Boolean
			{  return _isSkidding;  }
			
		public function wasSkidding():Boolean
			{  return _wasSkidding;  }
			
		public function getCurrentTurnAngle():Number
			{  return _currTurnAngle;  }

		/// The total force pushing down on this tire in Newtons, as of the last time step taken.
		/// This considers the world's zGravity, the mass of the car, the number of other tires and their positions, and load transfer while accelerating/turning.
		public function getLoad():Number
			{  return _load;  }
			
		public function getMassShare():Number
			{  return m_massShare;  }
			
		public function setMass(value:Number):void
		{
			m_mass = mass;
			invalidateMetrics();
		}
		
		public function getMass():Number
			{  return m_mass;  }
			
		public function setTireRotation(value:Number):void
		{
			_rotation = value % (Math.PI * 2);
			_rotation = _rotation < 0 ? Math.PI * 2 + _rotation : _rotation;
		}
			
		public function getTireRotation():Number
			{  return _rotation;  }
	
		public function calcCircumference():Number
			{  return 2 * _radius * Math.PI;  }

		public function getRadsPerSec():Number
			{  return _baseRadsPerSec + _extraRadsPerSec;  }

		public function calcRpm():Number
			{  return qb2U_UnitConversion.radsPerSec_to_RPM(radsPerSec);  }
			
			
		public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			var drawFlags:uint = qb2S_DebugDraw.flags;
			var drawTires:Boolean = drawFlags & qb2F_DebugDrawOption.TIRES ? true : false;
			var drawLoads:Boolean = drawFlags & qb2F_DebugDrawOption.TIRE_LOADS ? true : false;
			
			if ( drawTires || drawLoads )
			{
				var tireScale:Number = qb2S_DebugDraw.tireScale;
				var pixPerMeter:Number = this.worldPixelsPerMeter;
				var realRadius:Number = _radius * tireScale;
				var realWidth:Number = _width * tireScale;
				
				var worldPoint:qb2GeoPoint = this.getWorldPosition();
				var localVec:qb2GeoVector = qb2GeoVector.newRotVector(0, -realRadius, _currTurnAngle);
				var worldVec:qb2GeoVector = _carBody ? _carBody.getWorldVector(localVec) : localVec;
				var sideVec:qb2GeoVector = worldVec.perpVector( -1).setLength( realWidth / 2);
				
				worldPoint.translate(worldVec).translate(sideVec);
				sideVec.negate().scale(2);
				worldVec.negate().scale(2);
				
				if ( drawTires )
				{
					graphics.pushLineStyle(qb2S_DebugDraw.lineThickness, qb2S_DebugDraw.tireOutlineColor | qb2S_DebugDraw.outlineAlpha);
					{
						graphics.pushFillColor(qb2S_DebugDraw.tireFillColor | qb2S_DebugDraw.fillAlpha);
						{
							graphics.moveTo(worldPoint.x, worldPoint.y);
							
							worldPoint.translate(sideVec);
							graphics.lineTo(worldPoint.x, worldPoint.y);
							
							worldPoint.translate(worldVec);
							graphics.lineTo(worldPoint.x, worldPoint.y);
							
							worldPoint.translate(sideVec.negate());
							graphics.lineTo(worldPoint.x, worldPoint.y);
							
							worldPoint.translate(worldVec.negate());
							graphics.lineTo(worldPoint.x, worldPoint.y);
						}
						graphics.popFillColor();
					}
					graphics.popLineStyle();
				}
				
				if ( drawLoads )
				{
					var avgAlpha:Number = 0;
					var carLoad:Number = _carBody.mass * world.gravityZ;
					for ( var i:int = 0; i < _carBody.tires.length; i++ )
					{
						var tire:qb2CarTire = _carBody.tires[i]
						avgAlpha += tire._load / carLoad;
					}
					avgAlpha /= _carBody.tires.length;
					
					var loadAlpha:Number = this._load / carLoad;
					loadAlpha += (loadAlpha - avgAlpha) * qb2S_DebugDraw.tireLoadAlphaScale;
					loadAlpha = loadAlpha > 1.0 ? 1.0 : loadAlpha;
					var loadAlphaHex:uint = uint(loadAlpha * (0xFF as Number)) << 24;
					loadAlphaHex <<= 24;
					
					if ( drawTires )
					{
						sideVec.negate();
						worldVec.negate();
					}
					
					graphics.pushLineStyle();
					{
						graphics.pushFillColor(qb2S_DebugDraw.tireLoadColor | loadAlphaHex);
						{
							graphics.moveTo(worldPoint.x, worldPoint.y);
							
							worldPoint.translate(sideVec);
							graphics.lineTo(worldPoint.x, worldPoint.y);
							
							worldPoint.translate(worldVec);
							graphics.lineTo(worldPoint.x, worldPoint.y);
							
							worldPoint.translate(sideVec.negate());
							graphics.lineTo(worldPoint.x, worldPoint.y);
							
							worldPoint.translate(worldVec.negate());
							graphics.lineTo(worldPoint.x, worldPoint.y);
						}
						graphics.popFillColor();
					}
					graphics.popLineStyle();
				}
				
				const numRotLines:int = qb2S_DebugDraw.tireNumRotLines;
				
				if ( numRotLines ) // this block draws the tire rotation lines.
				{
					graphics.pushLineStyle(qb2S_DebugDraw.lineThickness, qb2S_DebugDraw.tireOutlineColor | qb2S_DebugDraw.outlineAlpha);
					{
						sideVec.negate();
						worldPoint.translate(sideVec).translate(worldVec.negated().scale(.5));
						sideVec.negate();// .scale(2);
						worldVec.normalize();
						
						var rotInc:Number = (Math.PI * 2) / numRotLines;
						var currRot:Number = _rotation;
						for ( i = 0; i < numRotLines; i++ )
						{
							if ( currRot > Math.PI / 2 && currRot < Math.PI * 1.5)
							{
								currRot += rotInc;
								currRot = currRot % (Math.PI * 2);
								continue;  // Line is underneath the tire.
							}
							var yScale:Number = Math.sin(currRot);
							var vecClone:qb2GeoVector = worldVec.clone();
							vecClone.scaleByNumber(realRadius * yScale);
							var pntClone:qb2GeoPoint = worldPoint.translatedBy(vecClone);
							graphics.moveTo(pntClone.x, pntClone.y);
							pntClone.translate(sideVec);
							graphics.lineTo(pntClone.x, pntClone.y);
							
							currRot += rotInc;
							currRot = currRot % (Math.PI * 2);
						}
					}
					graphics.popLineStyle();
				}
			}
		}
			
		public override function draw(graphics:qb2I_Graphics2d):void
		{
			
		}
		
		public override function convertTo(T:Class):*
		{
			return qb2U_ToString.auto(this);
		}
	}
}