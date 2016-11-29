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
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.iterators.qb2ChildIterator;
	
	import quickb2.math.geo.*;
	import quickb2.lang.*;
	
	import quickb2.debugging.*;
	import quickb2.debugging.drawing.*;
	import quickb2.debugging.logging.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.surfaces.planar.qb2GeoPolygon;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	
	import quickb2.physics.core.*;
	import quickb2.physics.core.joints.*;
	import quickb2.physics.core.tangibles.*;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2SoftPoly extends qb2Group
	{
		private var _subdivision:uint = 1;
		private var _numVertices:uint = 0;
		
		private var revJoints:Vector.<qb2RevoluteJoint> = new Vector.<qb2RevoluteJoint>();
		
		public var drawSplinarOutlines:Boolean = true;
		
		private var _isCircle:Boolean = false;
		
		public function qb2SoftPoly():void
		{
			setSharedProperty(qb2S_PhysicsProps.SPRING_K, 10.0);
			setSharedProperty(qb2S_PhysicsProps.SPRING_DAMPING, 10.0);
			setSharedProperty(qb2S_PhysicsProps.LOWER_LIMIT, 10.0);
			setSharedProperty(qb2S_PhysicsProps.UPPER_LIMIT, 10.0);
		}
		
		/*public override function clone():*
		{
			var jelloPoly:qb2SoftPoly = super.clone() as qb2SoftPoly;
			
			jelloPoly.drawSplinarOutlines = this.drawSplinarOutlines;
		
			//--- Here we have to make sure to populate the joints array so that the draw function has something to go off of.
			var iterator:qb2ChildIterator = qb2ChildIterator.getInstance(jelloPoly, qb2RevoluteJoint);
			for ( var joint:qb2RevoluteJoint; joint = iterator.next() as qb2RevoluteJoint; )
			{
				jelloPoly.revJoints.push(joint);
			}
			jelloPoly.revJoints.unshift(jelloPoly.revJoints.pop());  // move the last joint to the beginning...just makes looping more intuitive
			
			jelloPoly._isCircle    = this._isCircle;
			jelloPoly._numVertices = this._numVertices;
			jelloPoly._subdivision = this._subdivision;
			
			return jelloPoly;
		}
		
		public function set(vertices:Vector.<qb2GeoPoint> = null, subdivision:uint = 1, mass:Number = 1, groupIndex:int = -1):qb2SoftPoly
		{
			_isCircle = false;
			removeAllChildren();
			revJoints.length = 0;
			_numVertices = 0;
			_subdivision = 1;
			
			if ( !vertices || vertices.length < 3)  return null;
			
			_numVertices = vertices.length;
			_subdivision = subdivision;
			//setSharedProperty(qb2S_PhysicsProps.CONTACT_GROUP_INDEX, groupIndex);
			
			var poly:qb2GeoPolygon = new qb2GeoPolygon(vertices);
			var centroid:qb2GeoPoint = new qb2GeoPoint();
			poly.calcCenterOfMass(centroid);
			
			var lastBody:qb2Body = null;
			
			for (var i:int = 0; i < vertices.length; i++) 
			{
				var ithVert:qb2GeoPoint = vertices[i];
				var nextVert:qb2GeoPoint = vertices[i < vertices.length - 1 ? i + 1 : 0];
				
				if ( _subdivision > 1 )
				{
					var vec:qb2GeoVector = nextVert.minus(ithVert);
					var scaler:qb2GeoVector = new qb2GeoVector(1 / Number(_subdivision), 1 / Number(_subdivision));
					vec.scaleByNumber(scaler);
					var movePnt:qb2GeoPoint = ithVert.clone() as qb2GeoPoint;
					for ( var j:int = 0; j < _subdivision; j++ )
					{
						var nextMove:qb2GeoPoint = movePnt.clone() as qb2GeoPoint;
						nextMove.translate(vec);
						
						var body:qb2Body = new qb2Body();
						body.getPosition().copy(centroid);
						var geom:qb2GeoPolygon = new qb2GeoPolygon(Vector.<qb2GeoPoint>([movePnt.clone() as qb2GeoPoint, nextMove.clone() as qb2GeoPoint, centroid.clone() as qb2GeoPoint]));
						var shape:qb2Shape = new qb2Shape(geom);
						shape.getPosition().subtract(body.getPosition()); // move it to body's local coordinates.
						body.addChild(shape);
						addChild(body);
		
						if ( this.getChildCount() > 1 )  stitch(lastBody, body, movePnt);
						
						movePnt.translate(vec);
						
						lastBody = body;
					}
				}
				else
				{
					body = new qb2Body();
					body.getPosition().copy(centroid);
					shape = qb2U_Stock.newPolygonShape(new qb2GeoPoint(), Vector.<qb2GeoPoint>([ithVert.clone() as qb2GeoPoint, nextVert.clone() as qb2GeoPoint, centroid.clone() as qb2GeoPoint]));
					shape.getPosition().subtract(body.getPosition()); // move it to body's local coordinates.
					body.addChild(shape);
					addChild(body);
					
					if ( this.getChildCount() > 1 )  stitch(lastBody, body, ithVert);
					
					lastBody = body;
				}
			}
			
			stitch(lastBody, this.getFirstChild() as qb2Body, vertices[0]);
			
			revJoints.unshift(revJoints.pop());  // move the last joint to the beginning...just makes looping more intuitive
			
			this.setMass(mass);
			
			return this;
		}
		
		private function stitch(body1:qb2Body, body2:qb2Body, point:qb2GeoPoint):void
		{
			var joint:qb2RevoluteJoint = new qb2RevoluteJoint(body1, body2, point);
			addChild(joint);
			revJoints.push(joint);
		}
			
		/*protected override function propertyChanged(propertyEnum:int):void
		{
			super.propertyChanged(propertyEnum);
			
			var value:Number = getProperty(propertyEnum);
			var i:int;
			
			if ( propertyEnum == qb2S_PhysicsProps.SPRING_K )
			{
				for ( i = 0; i < revJoints.length; i++) 
				{
					revJoints[i].setSpringK(value);
				}
			}
			else if ( propertyEnum == qb2S_PhysicsProps.SPRING_DAMPING )
			{
				for ( i = 0; i < revJoints.length; i++) 
				{
					revJoints[i].setSpringDamping(value);
				}
			}
			else if ( propertyEnum == qb2S_PhysicsProps.LOWER_LIMIT )
			{
				for ( i = 0; i < revJoints.length; i++) 
				{
					revJoints[i].setLowerLimit(value);
				}
			}
			else if ( propertyEnum == qb2S_PhysicsProps.UPPER_LIMIT )
			{
				for ( i = 0; i < revJoints.length; i++) 
				{
					revJoints[i].setUpperLimit(value);
				}
			}
		}*/
		
		/*public function setAsCircle(center:qb2GeoPoint, radius:Number, numSegments:uint = 12, mass:Number = 1, groupIndex:int = -1):qb2SoftPoly
		{
			var rotPoint:qb2GeoPoint = center.clone() as qb2GeoPoint;
			rotPoint.m_y -= radius;
			var inc:Number = (Math.PI * 2) / numSegments;
			const verts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>(numSegments, true);
			for ( var i:int = 0; i < numSegments; i++ )
			{
				verts[i] = new qb2GeoPoint();  
				verts[i].copy(rotPoint);
				rotPoint.rotate(inc, center);
			}

			set(verts, 1, mass, groupIndex);
			
			_isCircle = true;
			
			return this;
		}
		
		public function setAsRect(center:qb2GeoPoint, width:Number, height:Number, numSubdivisions:uint = 2, mass:Number = 1, groupIndex:int = -1):qb2SoftPoly
		{
			const verts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>(4, true);
			verts[0] = new qb2GeoPoint(center.m_x - width / 2, center.m_y - height / 2);
			verts[1] = new qb2GeoPoint(center.m_x + width / 2, center.m_y - height / 2);
			verts[2] = new qb2GeoPoint(center.m_x + width / 2, center.m_y + height / 2);
			verts[3] = new qb2GeoPoint(center.m_x - width / 2, center.m_y + height / 2);
			
			set(verts, numSubdivisions, mass, groupIndex);
			
			return this;
		}
		
		public function setAsStar(center:qb2GeoPoint, outerRadius:Number, innerRadius:Number, numPoints:uint = 6, numSubdivisions:uint = 2, mass:Number = 1, groupIndex:int = -1):qb2SoftPoly
		{
			const verts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>();
			
			var startOuter:qb2GeoPoint = center.clone() as qb2GeoPoint;
			startOuter.incY( -outerRadius);
			var startInner:qb2GeoPoint = center.clone() as qb2GeoPoint;
			startInner.incY( -innerRadius);
			
			var incAngle:Number = (qb2S_Math.PI * 2) / (numPoints as Number);
			startInner.rotate(incAngle / 2, center);
			for (var i:int = 0; i < numPoints; i++) 
			{
				verts.push(startOuter.clone().rotate(i * incAngle, center) as qb2GeoPoint );
				verts.push(startInner.clone().rotate(i * incAngle, center) as qb2GeoPoint );
			}
			
			return set(verts, numSubdivisions, mass, groupIndex);
		}
		
		public function getSubdivision():uint
		{
			return _subdivision;
		}
		
		public function getVertexCount():uint
		{
			return _numVertices;
		}
		
		public function isCircle():Boolean
		{
			return _isCircle;
		}
		
		public function calcRoughRotation():Number
		{
			var iterator:qb2ChildIterator = qb2ChildIterator.getInstance(this, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next() as qb2I_RigidObject; )
			{
				return rigid.getRotation();
			}
			
			return 0;
		}
		
		public function calcRoughPosition(point_out:qb2GeoPoint):void
		{
			return this.calcCenterOfMass(point_out);
		}
		
		public override function draw(graphics:qb2I_Graphics2d):void
		{
			if ( !drawSplinarOutlines )
			{
				var basePoint:qb2GeoPoint = new qb2GeoPoint();
				revJoints[0].calcWorldAnchor(basePoint);
				graphics.moveTo(basePoint);
				
				var worldPoint:qb2GeoPoint = new qb2GeoPoint();
				for (var i:int = 1; i < revJoints.length; i++) 
				{
					revJoints[i].calcWorldAnchor(worldPoint);
					graphics.drawLineTo(worldPoint);
				}
				
				graphics.drawLineTo(basePoint);
			}
			else
			{
				if ( _subdivision == 1 )
				{
					var verts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>(revJoints.length, true);
					
					for (i = 0; i < revJoints.length; i++) 
					{
						var point_out:qb2GeoPoint = new qb2GeoPoint();
						revJoints[i].calcWorldAnchor(point_out);
						verts[i] = point_out;
					}
					
					//graphics.drawClosedCubicSpline(verts);
				}
				else
				{
					revJoints[0].calcWorldAnchor(basePoint);
					graphics.moveTo(basePoint);
				
					verts = new Vector.<qb2GeoPoint>();
					var count:uint = 0;
					for ( i = 0; i <= revJoints.length;  i++) 
					{
						var revJoint:qb2RevoluteJoint = revJoints[i < revJoints.length ? i : 0];
						point_out = new qb2GeoPoint();
						revJoint.calcWorldAnchor(point_out);
						verts.push(point_out);
						
						count++;
						
						if ( count > _subdivision )
						{
							var tangent:qb2GeoVector = point_out.minus(verts[0]);
							var scaler:qb2GeoVector = new qb2GeoVector(1 / Number(_subdivision), 1 / Number(_subdivision));
							tangent.scaleByNumber(scaler);
							
							//graphics.drawCubicSpline(tangent, tangent, verts, false);
							verts.length = 0;
							verts.push(point_out);
							count = 1;
						}
					}
				}
			}
		}
		
		/*public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			if ( !revJoints.length )  return;
			
			var drawFlags:uint = qb2S_DebugDraw.flags;
			var drawDecomp:Boolean   = drawFlags & qb2F_DebugDrawOption.DECOMPOSITION ? true : false;
			var drawOutlines:Boolean = drawFlags & qb2F_DebugDrawOption.OUTLINES ?      true : false;
			var drawFills:Boolean    = drawFlags & qb2F_DebugDrawOption.FILLS ?         true : false;
			var drawVerts:Boolean    = drawFlags & qb2F_DebugDrawOption.VERTICES ?      true : false;

			if ( drawOutlines || drawFills )
			{
				if ( drawOutlines )
				{
					graphics.pushLineStyle(qb2S_DebugDraw.lineThickness, getDebugOutlineColor(graphics) | qb2S_DebugDraw.outlineAlpha);
				}
				else
				{
					graphics.pushLineStyle();
				}
				
				if ( drawFills )
				{
					graphics.pushFillColor(getDebugFillColor(graphics) | qb2S_DebugDraw.fillAlpha);
				}
				else
				{
					graphics.pushFillColor();
				}
					
				draw(graphics);
				
				graphics.popFillColor();
				graphics.popLineStyle();
			}
			
			if ( drawVerts && !_isCircle )
			{
				graphics.pushLineStyle();
				{
					graphics.pushFillColor(qb2S_DebugDraw.vertexColor | qb2S_DebugDraw.vertexAlpha);
					{
						var numJoints:int = revJoints.length / _subdivision;
						for (var i:int = 0; i < numJoints; i++) 
						{
							var worldPoint:qb2GeoPoint = revJoints[i * _subdivision].calcWorldAnchor();
							worldPoint.draw(graphics);
						}
					}
					graphics.popFillColor();
				}
				graphics.popLineStyle();
			}
			
			if ( _isCircle )
			{
				if ( drawOutlines && (drawFlags & qb2F_DebugDrawOption.CIRCLE_SPOKES) )
				{
					graphics.pushLineStyle(qb2S_DebugDraw.lineThickness, getDebugOutlineColor(graphics) | qb2S_DebugDraw.outlineAlpha);
					{
						var center:qb2GeoPoint = calcCenterOfMass();
						
						if ( !center )  return;
						
						var spokeFlags:Array =
						[
							qb2F_DebugDrawOption.CIRCLE_SPOKE_1, qb2F_DebugDrawOption.CIRCLE_SPOKE_2,
							qb2F_DebugDrawOption.CIRCLE_SPOKE_3, qb2F_DebugDrawOption.CIRCLE_SPOKE_4
						];
						
						var fourth:int = revJoints.length / 4;
						for ( i = 0; i < spokeFlags.length; i++) 
						{
							if ( drawFlags & spokeFlags[i] )
							{
								var point:qb2GeoPoint = revJoints[i * fourth].calcWorldAnchor();
								graphics.moveTo(point);
								graphics.drawLineTo(center);
							}
						}
					}
					graphics.popLineStyle();
				}
			}
			
			if ( drawDecomp )
			{
				graphics.pushLineStyle(qb2S_DebugDraw.lineThickness, getDebugOutlineColor(graphics) | qb2S_DebugDraw.outlineAlpha);
				{
					var iterator:qb2ChildIterator = qb2ChildIterator.getInstance(this, qb2I_RigidObject);
					for ( var rigid:qb2I_RigidObject; iterator.next() as qb2I_RigidObject; )
					{
						rigid.draw(graphics);
					}
				}
				graphics.popLineStyle();
			}
		}*/
		
		public override function convertTo(T:Class):*
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this, "qb2SoftPoly");
			}
			
			return super.convertTo(T);
		}
	}
}