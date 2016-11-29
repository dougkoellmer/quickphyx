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

package quickb2.physics.utils
{
	
	import flash.geom.Rectangle;
	import quickb2.math.geo.*;
	import flash.display.*;
	import quickb2.lang.*
	import quickb2.event.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.curves.qb2GeoPolyline;
	import quickb2.math.geo.surfaces.planar.qb2GeoCircularDisk;
	import quickb2.math.geo.surfaces.planar.qb2GeoEllipticalDisk;
	import quickb2.math.geo.surfaces.planar.qb2GeoPolygon;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.platform.qb2I_Window;
	
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.platform.input.qb2I_Mouse;

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2U_Stock
	{
		/*public static const ENDS_SQUARE:uint = 1;
		public static const ENDS_ROUND:uint = 2;
		
		public static const CORNERS_SHARP:uint = 1;
		public static const CORNERS_ROUND:uint = 2;
		public static const CORNERS_NONE:uint = 3;*/
		
		public static function newCircleShape(radius:Number, mass:Number = 0.0):qb2Shape
		{
			var geometry:qb2GeoCircularDisk = new qb2GeoCircularDisk(null, radius);
			var shape:qb2Shape = new qb2Shape(geometry);
			shape.setProp(qb2S_PhysicsProps.MASS, mass);
			
			return shape;
		}
		
		public static function newRectangleShape(width:Number, height:Number, mass:Number = 0.0):qb2Shape
		{
			var geometry:qb2GeoPolygon = new qb2GeoPolygon();
			qb2U_GeoPointLayout.createRectangle(null, width, height, geometry);
			
			var shape:qb2Shape = new qb2Shape(geometry);
			
			shape.setProp(qb2S_PhysicsProps.MASS, mass);
			
			return shape;
		}
		
		public static function newEllipseShape(majorAxis:qb2GeoVector, minorAxisLength:Number, mass:Number = 0.0):qb2Shape
		{
			var geometry:qb2GeoEllipticalDisk = new qb2GeoEllipticalDisk();
			
			geometry.set(null, majorAxis, minorAxisLength);
			
			var shape:qb2Shape = new qb2Shape(geometry);
			
			shape.setProp(qb2S_PhysicsProps.MASS, mass);
			
			return shape;
		}
		
		public static function newRegularPolygonShape(radius:Number, sideCount:int, mass:Number = 0.0):qb2Shape
		{
			var geometry:qb2GeoPolygon = new qb2GeoPolygon();
			qb2U_GeoPointLayout.createRegularPolygon(null, radius, sideCount, geometry);
			
			var shape:qb2Shape = new qb2Shape(geometry);
			
			shape.setProp(qb2S_PhysicsProps.MASS, mass);
			
			return shape;
		}
		
		public static function newIsoscelesTriangleShape(baseWidth:Number, height:Number, mass:Number = 0.0):qb2Shape
		{
			var geometry:qb2GeoPolygon = new qb2GeoPolygon();
			qb2U_GeoPointLayout.createIsoscelesTriangle(null, baseWidth, height, geometry);
			
			var shape:qb2Shape = new qb2Shape(geometry);
			
			shape.setProp(qb2S_PhysicsProps.MASS, mass);
			
			return shape;
		}
		
		/*public static function newRectBody(width:Number, height:Number, mass:Number = 0.0):qb2Body
		{
			var body:qb2Body = new qb2Body();
			body.addChild(newRectShape(width, height, mass));
			
			return body;
		}
		
		public static function newCircleBody(center:qb2GeoPoint, radius:Number, mass:Number = 0.0):qb2Body
		{
			var body:qb2Body = new qb2Body();
			body.getPosition().copy(center);
			body.addChild(newCircleShape(new qb2GeoPoint(), radius, mass));
			return body;
		}
		
		public static function newRectSensor(center:qb2GeoPoint, width:Number, height:Number, rotation:Number = 0, tripCallback:Function = null, tripTime:Number = 0):qb2TripSensor
		{
			var sensor:qb2TripSensor = new qb2TripSensor();
			sensor.getPosition().copy(center);
			sensor.setRotation(rotation);
			sensor.addChild(newRectShape(new qb2GeoPoint(), width, height));
			sensor.tripTime = tripTime;
			if ( tripCallback != null)  sensor.addEventListener(qb2TripSensorEvent.SENSOR_TRIPPED, tripCallback );
			return sensor;
		}
		
		public static function newCircleSensor(center:qb2GeoPoint, radius:Number, tripTime:Number = 0, tripCallback:Function = null):qb2TripSensor
		{
			var sensor:qb2TripSensor = new qb2TripSensor();
			sensor.getPosition().copy(center);
			sensor.addChild(newCircleShape(new qb2GeoPoint(), radius));
			sensor.tripTime = tripTime;
			if ( tripCallback != null )  sensor.addEventListener(qb2TripSensorEvent.SENSOR_TRIPPED, tripCallback );
			return sensor;
		}
		
		public static function newLineBody(beg:qb2GeoPoint, end:qb2GeoPoint, thickness:Number = 1, mass:Number = 0.0, ends:uint = ENDS_SQUARE):qb2Body
		{
			var midPoint:qb2GeoPoint = new qb2GeoPoint();
			beg.calcMidwayPoint(end, midPoint)
			return newPolylineBody(Vector.<qb2GeoPoint>([beg, end]), thickness, mass, CORNERS_NONE, ends, midPoint);
		}
		
		public static function newEllipticalArcBody(center:qb2GeoPoint, majorAxis:qb2GeoVector, minorAxisLength:Number, numSegs:uint, startAngle:Number = 0, endAngle:Number = 6.283185307179586, thickness:Number = 1, mass:Number = 0.0, corners:uint = CORNERS_SHARP, ends:uint = ENDS_SQUARE):qb2Body
		{
			const verts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>();
			
			var majorAxisLength:Number = majorAxis.calcLength();
			
			var refVec:qb2GeoVector = new qb2GeoVector(0, -1);
			var offsetAngle:Number = refVec.calcSignedAngleTo(majorAxis);
			
			var sinBeta:Number = Math.sin(offsetAngle - qb2S_Math.PI / 2);
			var cosBeta:Number = Math.cos(offsetAngle - qb2S_Math.PI / 2);
			
			var sweepAngle:Number = endAngle - startAngle;
			var closed:Boolean = sweepAngle  == qb2S_Math.PI * 2;
			var solid:Boolean = false;
			var inc:Number = sweepAngle / Number( closed ? numSegs : numSegs - 1);
			
			for (var i:int = 0; i < numSegs; i++) 
			{
				var alpha:Number = i * inc;
				var sinAlpha:Number = Math.sin(alpha + startAngle);
				var cosAlpha:Number = Math.cos(alpha + startAngle);
				
				var x:Number = center.getX() + (majorAxisLength * cosAlpha * cosBeta - minorAxisLength * sinAlpha * sinBeta);
				var y:Number = center.getY() + (majorAxisLength * cosAlpha * sinBeta + minorAxisLength * sinAlpha * cosBeta);
				
				verts.push(new qb2GeoPoint(x, y));
			}
			
			return newPolylineBody(verts, thickness, mass, corners, ends, center, closed);
		}
			
		public static function newPolylineBody(vertices:Vector.<qb2GeoPoint>, thickness:Number = 1, mass:Number = 0.0, corners:uint = CORNERS_SHARP, ends:uint = ENDS_SQUARE, registrationPoint:qb2GeoPoint = null, closed:Boolean = false):qb2Body
		{
			/*var body:qb2Body = new qb2Body();
			registrationPoint ? body.getPosition().copy(registrationPoint) : body.getPosition().copy(vertices[0]) as qb2GeoPoint;;
			
			if ( thickness == 0 )
			{
				if ( closed )
				{
					vertices.push(vertices[0].clone());
				}
				var poly:qb2Shape = new qb2Shape();
				poly.set(vertices, registrationPoint.clone() as qb2GeoPoint, false);
				poly.getPosition().set(0, 0);
				body.addChild(poly);
				
				if ( closed )
				{
					vertices.pop();
				}
			}
			else if ( vertices.length == 2 )
			{
				var vec:qb2GeoVector = vertices[1].minus(vertices[0]);
				var rect:qb2Shape = newRectShape(vertices[1].calcMidwayPoint(vertices[0]), thickness, vec.calcLength(), 0, vec.calcAngleTo(new qb2GeoVector(0, -1)))
				rect.getPosition().subtract(body.getPosition());
				body.addChild(rect);
			}
			else
			{
				if ( closed )
				{
					vertices.push(vertices[0].clone() as qb2GeoPoint, vertices[1].clone() as qb2GeoPoint);
				}
				
				const newVerts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>();
				
				if ( corners == CORNERS_NONE || corners == CORNERS_ROUND )
				{
					var limit:int = (!closed ? vertices.length - 1 : vertices.length - 2);
					for (var i:int = 0; i < limit; i++) 
					{
						var point1:qb2GeoPoint = vertices[i];
						var point2:qb2GeoPoint = vertices[i + 1];
						vec = point2.minus(point1);
						rect = newRectShape(point1.calcMidwayPoint(point2), thickness, vec.calcLength(), 0, vec.calcAngleTo(new qb2GeoVector(0, -1)));
						rect.getPosition().subtract(body.getPosition());
						body.addChild(rect);
						
						if ( corners == CORNERS_ROUND && i > 0 )
						{
							body.addChild(newCircleShape((point1.clone() as qb2GeoPoint).subtract(body.getPosition()) as qb2GeoPoint, thickness / 2));
						}
					}
				}
				else
				{
					var polyVerts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>();
					
					point1 = vertices[0];
					point2 = vertices[1];
					
					var seg:qb2GeoLine = new qb2GeoLine(point1, point2);
						
					if ( !closed )
					{
						var mover:qb2GeoVector = seg.calcDirection().setToPerpVector(1).scale(thickness / 2, thickness / 2) as qb2GeoVector;
						var elbow1:qb2GeoPoint = seg.getStartPoint().clone().translate(mover) as qb2GeoPoint;
						polyVerts.push(elbow1);
						mover.negate();
						var elbow2:qb2GeoPoint = seg.getStartPoint().clone().translate(mover) as qb2GeoPoint;
						polyVerts.push(elbow2);
					}
					else
					{
						var tailSeg:qb2GeoLine = new qb2GeoLine(vertices[vertices.length - 3], vertices[vertices.length - 2]);
						var firstJoint:qb2GeoLine = tailSeg.calcBisector(seg, thickness, Infinity);
						polyVerts.push(firstJoint.getStartPoint(), firstJoint.getEndPoint());
					}
					
					var lastBisector:qb2GeoLine = new qb2GeoLine(polyVerts[0].clone() as qb2GeoPoint, polyVerts[1].clone() as qb2GeoPoint);
					
					for ( i = 0; i < vertices.length-2; i++) 
					{
						var nextSeg:qb2GeoLine = new qb2GeoLine(vertices[i + 1], vertices[i + 2]);
						
						var elbow:qb2GeoLine = seg.calcBisector(nextSeg, thickness, Infinity);
						
						if ( seg.calcIsIntersecting(new qb2GeoLine(polyVerts[0], elbow.getEndPoint())) )
						{
							polyVerts.push(elbow.getEndPoint().clone(), elbow.getStartPoint().clone());
						}
						else
						{
							polyVerts.push(elbow.getStartPoint().clone(), elbow.getEndPoint().clone());
						}
						
						rect = newPolygonShape(polyVerts, seg.calcPointAtDistance(seg.calcLength()/2.0).clone() as qb2GeoPoint);
						rect.getPosition().subtract(body.getPosition());
						body.addChild(rect);
						
						polyVerts.length = 0;
						
						
						polyVerts.push(elbow.getStartPoint(), elbow.getEndPoint() );
						
						seg = nextSeg;
						lastBisector = elbow;
					}
					
					if ( !closed )
					{
						var lastSeg:qb2GeoLine = seg;
						mover = lastSeg.calcDirection().setToPerpVector(1).scale(thickness / 2, thickness / 2) as qb2GeoVector;
						elbow1 = lastSeg.getEndPoint().clone().translate(mover) as qb2GeoPoint;
						mover.negate()
						
						// TODO: elbow2 is being used as the output to intersectsLine here it seems...cuold be causing that weird elbow tweakage.
						/*elbow2 = lastSeg.getEndPoint().clone().translate(mover) as qb2GeoPoint;
						
						if ( !lastSeg.intersectsLine(new qb2GeoLine(polyVerts[0], elbow2)) )
						{
							polyVerts.push(elbow1, elbow2);
						}
						else
						{
							polyVerts.push(elbow2, elbow1);
						}*/
						
						/*rect = newPolygonShape(polyVerts, seg.calcPointAtDistance(seg.calcLength()/2.0).clone() as qb2GeoPoint);
						rect.getPosition().subtract(body.getPosition());
						body.addChild(rect);
					}
				}
				
				if ( closed )
				{
					vertices.pop();
					vertices.pop();
				}
			}
			
			if ( closed )
			{
				if ( corners == CORNERS_ROUND )
				{
					body.addChild(newCircleShape((vertices[0].clone()as qb2GeoPoint).subtract(body.getPosition()) as qb2GeoPoint, thickness / 2));	
				}
			}
			else
			{
				if ( ends == ENDS_ROUND )
				{
					body.addChild(newCircleShape((vertices[0].clone() as qb2GeoPoint).subtract(body.getPosition()) as qb2GeoPoint, thickness / 2));
					body.addChild(newCircleShape((vertices[vertices.length - 1].clone() as qb2GeoPoint).subtract(body.getPosition()) as qb2GeoPoint, thickness / 2));	
				}
			}
			
			if ( mass )
			{
				body.setProperty(qb2S_PhysicsProps.MASS, mass);
			}
			
			return body;
			
			return null;
		}*/

		public static function newRoundedRectBody(width:Number, height:Number, cornerRadius:Number, mass:Number = 0.0):qb2Body
		{
			var body:qb2Body = new qb2Body();
			var shape:qb2Shape;
			
			shape = newRectangleShape(width, height - cornerRadius * 2);
			body.addChild(shape);
			
			shape = newRectangleShape(width - cornerRadius * 2, cornerRadius);
			shape.getPosition().setY( -height / 2 + cornerRadius / 2);
			body.addChild(shape);
			
			shape = newRectangleShape(width - cornerRadius * 2, cornerRadius);
			shape.getPosition().setY(height / 2 - cornerRadius / 2);
			body.addChild(shape);
			
			shape = newCircleShape(cornerRadius);
			shape.getPosition().set( -width / 2 + cornerRadius, -height / 2 + cornerRadius);
			body.addChild(shape);
			
			shape = newCircleShape(cornerRadius);
			shape.getPosition().set( width / 2 - cornerRadius, -height / 2 + cornerRadius);
			body.addChild(shape);
			
			shape = newCircleShape(cornerRadius);
			shape.getPosition().set( width / 2 - cornerRadius, height / 2 - cornerRadius);
			body.addChild(shape);
			
			shape = newCircleShape(cornerRadius);
			shape.getPosition().set( -width / 2 + cornerRadius, height / 2 - cornerRadius);
			body.addChild(shape);
			
			body.setProp(qb2S_PhysicsProps.MASS, mass);
			
			return body;
		}
		
		/*public static function newDebugWorld(gravity:qb2GeoVector = null, debugGraphics:qb2I_Graphics2d = null, debugMouse:qb2I_Mouse = null, debugWindowForWalls:qb2I_Window = null, autoStart:Boolean = true):qb2World
		{
			var world:qb2World = new qb2World();
			if ( gravity )
			{
				world.getGravity().copy(gravity);
			}
	
			world.setGraphics(debugGraphics);
			world.setDebugMouse(debugMouse);
			
			if ( debugWindowForWalls != null )
			{
				world.addChild(new qb2WindowWalls(debugWindowForWalls));
			}
			
			if ( autoStart )
			{
				world.start();
			}
			
			return world;
		}*/
		
		public static function newPillBody(width:Number, height:Number, mass:Number = 0.0):qb2Body
		{
			var body:qb2Body = new qb2Body();
			var shape:qb2Shape;
			
			shape = newRectangleShape(width - height, height);
			body.addChild(shape);
			
			shape = newCircleShape(height / 2);
			shape.getPosition().setX( -width / 2 + height / 2);
			body.addChild(shape);
			
			shape = newCircleShape(height / 2);
			shape.getPosition().setX(width/2 - height/2);
			body.addChild(shape);
			
			body.setProp(qb2S_PhysicsProps.MASS, mass);
			
			return body;
		}
	}
}