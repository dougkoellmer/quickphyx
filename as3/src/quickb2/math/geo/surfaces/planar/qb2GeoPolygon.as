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

package quickb2.math.geo.surfaces.planar
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.curves.qb2GeoCachedPolyline;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2GeoIntersectionOptions;
	import quickb2.math.geo.qb2GeoIntersectionResult;
	import quickb2.math.geo.qb2GeoPolygonAnalyzer;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	import quickb2.math.geo.qb2I_GeoPointContainer;
	import quickb2.math.qb2U_MassFormula;
	
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.curves.qb2GeoPolyline;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventDispatcher;
	
	import quickb2.lang.*
	
	public class qb2GeoPolygon extends qb2A_GeoCurveBoundedPlane implements qb2I_GeoPointContainer
	{
		private static const ORIGIN:qb2GeoPoint = new qb2GeoPoint();
		private static const s_analyzer:qb2GeoPolygonAnalyzer = new qb2GeoPolygonAnalyzer();
		private static const s_pointIterator:qb2GeoDecompositionIterator = new qb2GeoDecompositionIterator();
		
		public function qb2GeoPolygon() 
		{
			var polyline:qb2GeoPolyline = new qb2GeoCachedPolyline();
			polyline.setIsClosed(true);
			
			super.setBoundary_protected(polyline);
		}
		
		private function getPolyline():qb2GeoPolyline
		{
			return this.getBoundary() as qb2GeoPolyline;
		}
		
		private function initAnalyzer(mass:Number, analyzer_out:qb2GeoPolygonAnalyzer):void
		{
			s_pointIterator.initialize(this);
			analyzer_out.initialize(s_pointIterator, mass);
		}
		
		public function analyze(mass:Number, analyzer_out:qb2GeoPolygonAnalyzer):void
		{
			initAnalyzer(mass, analyzer_out);
			
			var pointCount:int = this.getPointCount();
			for ( var i:int = 0; i < pointCount; i++ )
			{
				var point1:qb2GeoPoint = i == 0 ? this.getPointAt(pointCount - 1) : this.getPointAt(i - 1);
				var point2:qb2GeoPoint = this.getPointAt(i);
				var point3:qb2GeoPoint = i == pointCount - 1 ? this.getPointAt(0) : this.getPointAt(i + 1);
				
				analyzer_out.step(point1, point2, point3);
			}
			
			analyzer_out.finish();
		}
		
		protected override function calcSimpleMomentOfInertia(mass:Number):Number
		{
			this.analyze(mass, s_analyzer);
			
			return qb2U_MassFormula.parallelAxisTheoremInverse(s_analyzer.getMomentOfIntertia(), mass, ORIGIN.calcDistanceSquaredTo(s_analyzer.getCenterOfMass()));
		}
		
		public override function calcMomentOfInertia(mass:Number, axis_nullable:qb2I_GeoHyperAxis = null, centerOfMass_out_nullable:qb2GeoPoint = null):Number
		{
			this.analyze(mass, s_analyzer);
			
			if ( centerOfMass_out_nullable != null )
			{
				centerOfMass_out_nullable.copy(s_analyzer.getCenterOfMass());
			}
			
			var momentOfInertiaForCenterOfMass:Number = qb2U_MassFormula.parallelAxisTheoremInverse(s_analyzer.getMomentOfIntertia(), mass, ORIGIN.calcDistanceSquaredTo(s_analyzer.getCenterOfMass()));
			
			if ( axis_nullable == null )
			{
				return momentOfInertiaForCenterOfMass;
			}
			else if ( qb2U_Type.isKindOf(axis_nullable, qb2GeoPoint) )
			{
				var axisAsPoint:qb2GeoPoint = axis_nullable as qb2GeoPoint;
				return qb2U_MassFormula.parallelAxisTheorem(momentOfInertiaForCenterOfMass, mass, axisAsPoint.calcDistanceSquaredTo(s_analyzer.getCenterOfMass()));
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
				
				return NaN;
			}
		}

		public function calcPolygonType():qb2F_GeoPolygonType
		{
			//TODO: USE point analyzer.
			
			/*var polyline:qb2GeoPolyline = this.getPolyline();
			
			
			//TODO: include more types here (i.e. simple, or something).
			var area:Number = 0;
			var isConvex:Boolean = true, isPositive:Boolean = false;
			var numVerts:uint = polyline.getVertexCount();
			for (var i:int = 0; i < numVerts; i++)
			{
				var prevPnt:qb2GeoPoint = i == 0 ? polyline.getVertexAt(numVerts - 1) : polyline.getVertexAt(i - 1);
				var ithPnt:qb2GeoPoint = polyline.getVertexAt(i);
				var nextPnt:qb2GeoPoint = (i + 1) < numVerts ? polyline.getPointAt(i + 1) : polyline.getPointAt(0);
				
				var D:Number = ithPnt.getX() * nextPnt.getY() - ithPnt.getY() * nextPnt.getX();
				var triangleArea:Number = 0.5 * D;
				area += triangleArea;
				
				//--- Determine if polygon remains convex at the i-th corner.
				if ( isConvex )
				{
					var vec1:qb2GeoVector = ithPnt.minus(prevPnt);
					var vec2:qb2GeoVector = nextPnt.minus(ithPnt);
					var cross:Number = vec1.getX() * vec2.getY() - vec2.getX() * vec1.getY();
					var subIsPositive:Boolean = cross > 0;
					if (i == 0)
					{
						isPositive = subIsPositive;
					}
					else if (isPositive != subIsPositive)
					{
						isConvex = false;
					}
				}
			}
			
			var type:uint = 0;
			if ( numVerts >= 3 )
			{
				if ( isConvex )
				{
					type |= qb2F_GeoPolygonType.IS_CONVEX.getBits();
				}
				else
				{
					type |= qb2F_GeoPolygonType.IS_CONCAVE.getBits();
				}
				
				if ( area >= 0 )
				{
					type |= qb2F_GeoPolygonType.IS_CLOCKWISE.getBits();
				}
				else
				{
					type |= qb2F_GeoPolygonType.IS_COUNTER_CLOCKWISE.getBits();
				}
			}*/
			
			return new qb2F_GeoPolygonType(0x0);
		}
		
		/*public override function calcInertia():Number
		{
			const k_inv3:Number = 1.0 / 3.0;
			var numVerts:uint = m_verts.length;
			var inertia:Number = 0;
			var totalArea:Number = 0;
			
			for (var i:int = 0; i < numVerts; i++)
			{
				var ithPnt:qb2GeoPoint = m_verts[i];
				var nextPnt:qb2GeoPoint = (i + 1) < numVerts ? m_verts[i + 1] : m_verts[0];
				
				var px:Number = 0;
				var py:Number = 0;
				var ex1:Number = ithPnt.getX()/30;
				var ey1:Number = ithPnt.getY()/30;
				var ex2:Number = nextPnt.getX() / 30;
				var ey2:Number = nextPnt.getY()/30;
				
				var intx2:Number = k_inv3 * (0.25 * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5*px*px;
				var inty2:Number = k_inv3 * (0.25 * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5*py*py;
				
				var modD:Number = ex1 * ey2 - ey1 * ex2;
				inertia += modD * (intx2 + inty2);
			}
			
			return inertia;
		}*/
		
		/*public override function calcSelfIntersection(output:* = null):Boolean
		{
			// TODO: register intersections to output.
			
			const iLine:qb2GeoLine = new qb2GeoLine(), jLine:qb2GeoLine = new qb2GeoLine();
		
			var intersections:Array = [];
			for ( var i:int = 0; i < m_verts.length; i++)
			{
				var ith:qb2GeoPoint = m_verts[i];
				var iNext:qb2GeoPoint = (i + 1) < m_verts.length ? m_verts[i + 1] : m_verts[0];
				
				iLine.getPointA().copy(ith);
				iLine.getPointB().copy(iNext);
				
				// Test against not the next line, but 2 lines after...it's impossible for adjacent lines to intersect.
				var cap:int = i == 0 ? m_verts.length - 1 : m_verts.length; // don't want to compare first and last lines.
				for ( var j:int = i+2; j < cap; j++)
				{
					var jth:qb2GeoPoint = m_verts[j];
					var jNext:qb2GeoPoint = (j + 1) < m_verts.length ? m_verts[j + 1] : m_verts[0];
					jLine.getPointA().copy(jth);
					jLine.getPointB().copy(jNext);
					
					var intPoint:qb2GeoPoint = new qb2GeoPoint();
					
					if ( iLine.calcIsIntersecting(jLine, intPoint) )
					{
						intersections.push(new geInternalPolygonIntersection(intPoint, i, j));
					}
				}
			}
			
			return intersections.length >= 1;
		}*/
		
		public function calcNormalAtIndex(index:uint, vector_out:qb2GeoVector):void
		{
			//TODO: optimize normal calculation (only calculate one normal).
			var normals:Array = [];
			var polyline:qb2GeoPolyline = this.getPolyline();
			var numVerts:int = polyline.getPointCount();
			
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
		}
		
		public override function calcIsIntersecting(otherEntity:qb2A_GeoEntity, options_nullable:qb2GeoIntersectionOptions = null, result_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			if ( qb2U_Type.isKindOf(otherEntity, qb2GeoPoint) )
			{
				var point:qb2GeoPoint = otherEntity as qb2GeoPoint;
				var x:Number = point.getX();
				var y:Number = point.getY();
				
				var pointCount:int = this.getPointCount();
				var j:int = pointCount - 1;
				var oddNodes:Boolean = false;

				for (var i:int = 0; i < pointCount; i++)
				{
					var ithPoint:qb2GeoPoint = this.getPointAt(i);
					var jthPoint:qb2GeoPoint = this.getPointAt(j);
					
					if ( (ithPoint.getY() < y && jthPoint.getY() >= y || jthPoint.getY() < y && ithPoint.getY() >= y) && (ithPoint.getX() <= x || jthPoint.getX() <= x) )
					{
						if (ithPoint.getX() + (y - ithPoint.getY()) / (jthPoint.getY() - ithPoint.getY()) * (jthPoint.getX() - ithPoint.getX()) < x)
						{
							oddNodes = !oddNodes;
						}
					}
					
					j = i;
				}

				return oddNodes;
			}
			
			return false;
		}
		
		public function flip():void
		{
			getBoundary().flip();
		}
		
		public function addPoint(point:qb2GeoPoint):void
		{
			getPolyline().addPoint(point);
		}
		
		public function addPoints(... oneOrMoreVertices):void
		{
			getPolyline().addPoints.apply(getPolyline(), oneOrMoreVertices);
		}

		public function getPointAt(index:uint):qb2GeoPoint
		{
			return getPolyline().getPointAt(index);
		}
		
		public function getPointCount():int
		{
			return getPolyline().getPointCount();
		}
			
		public function setPointAt(index:uint, point:qb2GeoPoint):void
		{
			getPolyline().setPointAt(index, point);
		}
			
		public function insertPointAt(index:uint, point:qb2GeoPoint):void
		{
			getPolyline().insertPointAt(index, point);
		}
		
		public function removePoint(vertex:qb2GeoPoint):void
		{
			getPolyline().removePoint(vertex);
		}
		
		public function removePointAt(index:uint):void
		{
			getPolyline().removePointAt(index);
		}
			
		public function removeAllPoints():void
		{
			getPolyline().removeAllPoints();
		}
	}
}