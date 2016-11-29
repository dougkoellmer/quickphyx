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

package quickb2.math.geo.curves
{
	import quickb2.debugging.logging.qb2I_LogWriter;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.display.immediate.style.qb2U_Style;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.iterators.qb2GeoPolylinePointIterator;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2GeoGeometryIterator;
	import quickb2.math.geo.qb2GeoPolygonAnalyzer;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	import quickb2.math.geo.qb2I_GeoHyperPlane;
	import quickb2.math.geo.qb2I_GeoPointContainer;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoCurveBoundedPlane;
	import quickb2.math.geo.surfaces.planar.qb2GeoPolygon;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.lang.operators.*;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2U_Prop;
	
	import quickb2.event.qb2EventDispatcher;
	
	import quickb2.lang.*;
	
	
	public class qb2GeoPolyline extends qb2A_GeoCurve implements qb2I_GeoTessellatedCurve, qb2I_GeoPointContainer
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		
		private static const s_utilLine:qb2GeoLine = new qb2GeoLine();
		private static const s_geoIterator:qb2GeoGeometryIterator = new qb2GeoGeometryIterator();
		private static const s_polylinePointIterator:qb2GeoPolylinePointIterator = new qb2GeoPolylinePointIterator();
		
		private static const s_pointAnalyzer:qb2GeoPolygonAnalyzer = new qb2GeoPolygonAnalyzer();
		
		private const m_verts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>();
		
		private var m_isClosed:Boolean = false;
		
		public function qb2GeoPolyline()
		{
			//set(vertices);
		}
	
		public override function getCurveType():qb2F_GeoCurveType
		{
			if ( isClosed() )
			{
				return qb2F_GeoCurveType.IS_TESSELLATED.or(qb2F_GeoCurveType.IS_BOUNDED);
			}
			else
			{
				return qb2F_GeoCurveType.IS_TESSELLATED.or(qb2F_GeoCurveType.IS_CLOSED);
			}
		}
		
		public function setIsClosed(value:Boolean):void
		{
			var wasClosed:Boolean = this.isClosed();
			
			m_isClosed = value;
			
			if (wasClosed != m_isClosed)
			{
				this.dispatchChangedEvent();
			}
		}
		
		public function isClosed():Boolean
		{
			return m_isClosed;
		}
		
		private function areEndPointsOverlapped():Boolean
		{
			return m_verts[0].isEqualTo(m_verts[m_verts.length - 1]);
		}
		
		public function set(points_nullable:Vector.<qb2GeoPoint>):void
		{
			this.pushEventDispatchBlock();
			{
				this.removeAllPoints();
				
				if ( points_nullable != null )
				{
					for (var i:int = 0; i < points_nullable.length; i++)
					{
						this.addPoint(points_nullable[i]);
					}
				}
			}
			this.popEventDispatchBlock();
		}
		
		public function addPoint(point:qb2GeoPoint):void
		{
			this.addPoints_private(point);
		}
		
		public function addPoints(... pointOrPoints):void
		{
			addPoints_private.apply(this, pointOrPoints);
		}
		
		private function addPoints_private(... pointOrPoints):void
		{
			for (var i:int = 0; i < pointOrPoints.length; i++)
			{
				m_verts.push(pointOrPoints[i]);
				
				this.addEventListenerToSubEntity(pointOrPoints[i], false);
			}
			
			this.dispatchChangedEvent();
		}
		
		public function getPointAt(index:int):qb2GeoPoint
		{
			return m_verts[index];
		}
		
		public function setPointAt(index:uint, point:qb2GeoPoint):void
		{
			this.removeEventListenerFromSubEntity(m_verts[index], false);
			
			m_verts[index] = point;
			
			this.addEventListenerToSubEntity(point, true);
		}
		
		public function insertPointAt(index:uint, point:qb2GeoPoint):void
		{
			m_verts.splice(index, 0, point);
			
			this.addEventListenerToSubEntity(point, true);
		}
		
		public function removePoint(point:qb2GeoPoint):void
		{
			return removePointAt(m_verts.indexOf(point));
		}
		
		public function removePointAt(index:uint):void
		{
			var vertex:qb2GeoPoint = m_verts.splice(index, 1)[0];
			
			this.removeEventListenerFromSubEntity(vertex, true);
		}
		
		public function removeAllPoints():void
		{
			this.pushEventDispatchBlock();
			{
				for (var i:int = m_verts.length - 1; i >= 0; i--)
				{
					this.removePointAt(i);
				}
			}
			this.popEventDispatchBlock();
		}
		
		public function getPointCount():int
		{
			return m_verts.length;
		}
		
		public function getSegmentCount():int
		{
			if (m_verts.length >= 1)
			{
				if (isClosed())
				{
					return m_verts.length >= 2 ? m_verts.length : 0;
				}
				else
				{
					return m_verts.length - 1;
				}
			}
			else
			{
				return 0;
			}
		}
		
		protected override function copy_protected(otherObject:*):void
		{
			if (otherObject as qb2GeoPolyline)
			{
				this.set(otherObject.convertToArray(qb2GeoPoint));
			}
			else if ( otherObject as qb2GeoPolygon )
			{
				return this.copy((otherObject as qb2GeoPolygon).getBoundary());
			}
		}
		
		public override function calcPointAtParam(param:Number, point_out:qb2GeoPoint):void
		{
			this.calcPointAtDistance(this.calcLength() * param, point_out);
		}
		
		public override function calcPointAtDistance(distance:Number, point_out:qb2GeoPoint):void
		{
			s_geoIterator.initialize(this, qb2GeoLine);
			
			qb2PU_CompositeCurve.calcPointAtDistance(s_geoIterator, distance, point_out);
		}
		
		public override function calcParamAtPoint(pointOnCurve:qb2GeoPoint):Number
		{
			/*var segIndex:int = closestSegmentTo(pointOnCurve);
			   if ( segIndex == -1 )
			   {
			   return NaN;
			   }
			
			   var dist:Number = lines[segIndex].getDistAtPoint(pointOnCurve);
			
			   for( var i:int = 0; i < segIndex; i++ )
			   dist += lines[i].length;
			 return dist;*/
			
			qb2_assert(false);
			
			return NaN;
		}
		
		public override function calcSubcurve(startParam:Number, endParam:Number):qb2A_GeoCurve
		{return null;
			/*var toReturn:qb2GeoPolyline;
			   var point1:qb2GeoPoint = new qb2GeoPoint(), point2:qb2GeoPoint = new qb2GeoPoint();
			   if ( getSubcurveHelper(pointOrDistStart, pointOrDistFinish, point1, point2) )
			   {
			   var index1:int = this.closestSegmentTo(point1);
			   var index2:int = this.closestSegmentTo(point2);
			   if ( index1 >= 0 && index2 >= 0 )
			   {
			   if ( index1 == index2 )
			   {
			   return lines[index1].getSubcurve(pointOrDistStart, pointOrDistFinish);
			   }
			   else if( index1 < index2 )
			   {
			   toReturn = new qb2GeoPolyline();
			   toReturn.addVertex(point1);
			   for( var i:int = index1; i < index2; i++ )
			   {
			   toReturn.addVertex(lines[i].point2.clone());
			   }
			   toReturn.addVertex(point2);
			
			   var startLine:qb2GeoLine = lines[index1];
			   var endLine:qb2GeoLine   = lines[index2];
			   }
			   }
			   }
			 return toReturn;*/
			 
			 return null;
		}
		
		public override function flip():void
		{
			m_verts.reverse();
			
			this.dispatchChangedEvent();
		}
		
		public override function calcIsLinear(line_out_nullable:qb2GeoLine = null, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			s_geoIterator.initialize(this, qb2GeoLine);
			
			return qb2PU_CompositeCurve.calcIsLinear(s_geoIterator, line_out_nullable, tolerance_nullable);
		}
		
		public override function calcLength():Number
		{
			s_geoIterator.initialize(this, qb2GeoLine);
			
			return qb2PU_CompositeCurve.calcLength(s_geoIterator);
		}
		
		/*public override function calcSelfIntersection(outputPoints:Vector.<qb2GeoPoint> = null, stopAtFirstPointFound:Boolean = true, distanceTolerance:Number = 0, radianTolerance:Number = 0):Boolean
		   {
		   var intersecting:Boolean = false;
		   var ithLine:qb2GeoLine = qb2_poolNew(qb2GeoLine);
		   var jthLine:qb2GeoLine = qb2_poolNew(qb2GeoLine);
		
		   var limit:int = m_verts.length;
		
		   if ( m_isClosed && !this.areEndPointsOverlapped() )
		   {
		   limit++;
		   }
		
		   for( var i:int = 0; i < limit; i++ )
		   {
		   var ithPlusOnePoint:qb2GeoPoint = i == m_verts.length ? m_verts[0] : m_verts[i];
		
		   ithLine.set(m_verts[i], ithPlusOnePoint);
		
		   for( var j:int = i+1; j < limit; j++ )
		   {
		   var jthPlusOnePoint:qb2GeoPoint = j == m_verts.length ? m_verts[0] : m_verts[j];
		
		   jthLine.set(m_verts[j], jthPlusOnePoint);
		
		   var outputPoint:qb2GeoPoint = outputPoints ? new qb2GeoPoint() : null;
		   if ( ithLine.intersectsLine(jthPlusOnePoint, outputPoint, distanceTolerance, radianTolerance) )
		   {
		   if ( outputPoints )
		   {
		   outputPoints.push(outputPoint);
		   }
		
		   intersecting = true;
		
		   if ( stopAtFirstPointFound )  return true;
		   }
		   }
		   }
		
		   qb2_poolDelete(ithLine);
		   qb2_poolDelete(jthLine);
		
		   return intersecting;
		 }*/
		
		//--- Draws this polyline to the given graphics object.
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			if (m_verts.length == 1)
			{
				m_verts[0].draw(graphics);
				return;
			}
			
			qb2U_Style.populateGraphics(graphics, propertyMap_nullable);
			
			graphics.moveTo(m_verts[0]);
			
			for (var i:int = 1; i < m_verts.length; i++)
			{
				graphics.drawLineTo(m_verts[i]);
			}
			
			if ( m_isClosed )
			{
				graphics.drawLineTo(m_verts[0]);
			}
			
			qb2U_Style.depopulateGraphics(graphics, propertyMap_nullable);
		}
		
		protected final override function isContainer():Boolean
		{
			return true;
		}
		
		protected override function nextDecomposition(progress:int):qb2A_GeoEntity
		{
			if (progress < m_verts.length)
			{
				return m_verts[progress];
			}
			
			return null;
		}
		
		protected override function nextGeometry(progress:int, returnType:Class, progressOffset_out:qb2Integer):qb2A_GeoEntity
		{			
			if (qb2U_Type.isInChain(returnType, qb2GeoLine, qb2A_GeoCurve))
			{
				if (m_verts.length >= 2)
				{
					if (isClosed())
					{
						if (progress <= m_verts.length - 1)
						{
							var pointB:qb2GeoPoint = progress == m_verts.length - 1 ? m_verts[0] : m_verts[progress + 1];
							s_utilLine.set(m_verts[progress], pointB);
							
							return s_utilLine;
						}
					}
					else
					{
						if (progress <= m_verts.length - 2)
						{
							s_utilLine.set(m_verts[progress], m_verts[progress + 1]);
							
							return s_utilLine;
						}
					}
				}
			}
			else if (qb2U_Type.isKindOf(returnType, qb2GeoPoint) )
			{
				return nextDecomposition(progress);
			}
			
			return null;
		}
		
		public override function calcArea(startParam:Number, endParam:Number):Number
		{
			s_polylinePointIterator.initialize(this, startParam, endParam);
			s_pointAnalyzer.initialize(s_polylinePointIterator);
			s_pointAnalyzer.run();
			
			return s_pointAnalyzer.getPolygonArea();
		}
		
		/*public override function convertTo(T:Class):*
		{
			if (T === String)
			{
				return qb2U_ToString.auto(this);
			}
			
			return super.convertTo(T);
		}*/
	}
}