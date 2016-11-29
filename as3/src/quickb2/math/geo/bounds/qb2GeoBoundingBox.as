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

package quickb2.math.geo.bounds
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.math.qb2U_MassFormula;
	import quickb2.math.qb2U_MomentOfInertia;
	import quickb2.utils.prop.qb2PropMap;
	
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.math.geo.curves.qb2GeoCompositeCurve;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	import quickb2.math.geo.qb2I_GeoHyperPlane;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoCurveBoundedPlane;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoPlanarSurface;
	import quickb2.math.geo.surfaces.planar.qb2GeoCurveBoundedPlane;
	import quickb2.math.geo.surfaces.planar.qb2GeoPolygon;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.curves.qb2GeoPolyline;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.event.qb2EventDispatcher;
	
	import quickb2.lang.*
	

	public class qb2GeoBoundingBox extends qb2A_GeoBoundingRegion
	{
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilLine:qb2GeoLine = new qb2GeoLine();
		
		private const m_min:qb2GeoPoint = new qb2GeoPoint();
		private const m_max:qb2GeoPoint = new qb2GeoPoint();

		public function qb2GeoBoundingBox(min_copied_nullable:qb2GeoPoint = null, max_copied_nullable:qb2GeoPoint = null)
		{
			init(min_copied_nullable, max_copied_nullable);
		}
		
		private function init(min_copied_nullable:qb2GeoPoint = null, max_copied_nullable:qb2GeoPoint = null):void
		{
			this.set(min_copied_nullable, max_copied_nullable);
			
			this.addEventListenerToSubEntity(m_min, false);
			this.addEventListenerToSubEntity(m_max, false);
		}
	
		public function set(min_copied_nullable:qb2GeoPoint, max_copied_nullable:qb2GeoPoint):void
		{
			this.pushEventDispatchBlock();
			{
				m_min.copy(min_copied_nullable);
				m_max.copy(max_copied_nullable);
			}
			this.popEventDispatchBlock();
		}
		
		public function setAsRect(center_copied_nullable:qb2GeoPoint, width:Number, height:Number):void
		{
			this.pushEventDispatchBlock();
			{
				if ( center_copied_nullable == null )
				{
					center_copied_nullable = s_utilPoint;
					this.calcCenterOfMass(center_copied_nullable);
				}
				
				m_min.copy(center_copied_nullable);
				m_max.copy(center_copied_nullable);
				
				m_min.inc( -width / 2, -height / 2);
				m_max.inc( width / 2, height / 2);
			}
			this.popEventDispatchBlock();
		}
		
		public override function calcMomentOfInertia(mass:Number, axis_nullable:qb2I_GeoHyperAxis = null, centerOfMass_out_nullable:qb2GeoPoint = null):Number
		{
			if ( axis_nullable == null )
			{
				if ( centerOfMass_out_nullable != null )
				{
					this.calcCenterOfMass(centerOfMass_out_nullable);
				}
				
				return qb2U_MomentOfInertia.rectangle(mass, this.calcWidth(), this.calcHeight());
			}
			else if ( qb2U_Type.isKindOf(axis_nullable, qb2GeoPoint) )
			{
				var axisAsPoint:qb2GeoPoint = axis_nullable as qb2GeoPoint;
				centerOfMass_out_nullable = centerOfMass_out_nullable != null ? centerOfMass_out_nullable : s_utilPoint;
				this.calcCenterOfMass(centerOfMass_out_nullable);
				
				var centerOfMassInertia:Number = qb2U_MomentOfInertia.rectangle(mass, this.calcWidth(), this.calcHeight());
				
				return qb2U_MassFormula.parallelAxisTheorem(centerOfMassInertia, mass, axisAsPoint.calcDistanceSquaredTo(centerOfMass_out_nullable));
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
				
				return NaN;
			}
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.CENTER, point_out);
		}
			
		public function getMin():qb2GeoPoint
		{
			return m_min;
		}
		
		public function getMax():qb2GeoPoint
		{
			return m_max;
		}
		
		public function calcContainment(point:qb2GeoPoint):qb2F_GeoBoundingBoxContainment
		{
			var bits:uint = 0;
	
			if ( point.getX() < getLeft() )		bits |= qb2F_GeoBoundingBoxContainment.TO_LEFT.getBits();
			if ( point.getX() > getRight() )	bits |= qb2F_GeoBoundingBoxContainment.TO_RIGHT.getBits();
			if ( point.getY() < getTop() )		bits |= qb2F_GeoBoundingBoxContainment.TO_TOP.getBits();
			if ( point.getY() > getBottom() )	bits |= qb2F_GeoBoundingBoxContainment.TO_BOTTOM.getBits();
			
			return new qb2F_GeoBoundingBoxContainment(bits);
		}
		
		public function getExtent(edge:qb2E_GeoBoundingBoxEdge):Number
		{
			switch(edge)
			{
				case qb2E_GeoBoundingBoxEdge.TOP:
				{
					return m_min.getY();
				}
				
				case qb2E_GeoBoundingBoxEdge.RIGHT:
				{
					return m_max.getX();
				}
				
				case qb2E_GeoBoundingBoxEdge.BOTTOM:
				{
					return m_max.getY();
				}
				
				case qb2E_GeoBoundingBoxEdge.LEFT:
				{
					return m_min.getX();
				}
			}
			
			return 0;
		}

		public function getLeft():Number
		{
			return m_min.getX();
		}
			
		public function getRight():Number
		{
			return m_max.getX();
		}

		public function getTop():Number
		{
			return m_min.getY();
		}
			
		public function getBottom():Number
		{
			return m_max.getY();
		}
			
		public function calcHeight():Number
		{
			return m_max.getY() - m_min.getY();
		}
		
		public function calcWidth():Number
		{
			return m_max.getX() - m_min.getX();
		}
		
		public function calcBoundaryPoint(ePoint:qb2E_GeoBoundingBoxPoint, point_out:qb2GeoPoint):void
		{
			switch(ePoint)
			{
				case qb2E_GeoBoundingBoxPoint.CENTER:
				{
					m_max.calcMidwayPoint(m_min, point_out);
					
					break;
				}
				
				case qb2E_GeoBoundingBoxPoint.TOP_LEFT:
				{
					point_out.copy(m_min);
					
					break;
				}
				
				case qb2E_GeoBoundingBoxPoint.TOP_CENTER:
				{
					point_out.copy(m_min);
					point_out.incX(this.calcWidth() / 2);
					
					break;
				}
				
				case qb2E_GeoBoundingBoxPoint.TOP_RIGHT:
				{
					point_out.copy(m_min);
					point_out.incX(this.calcWidth());
					
					break;
				}
				
				case qb2E_GeoBoundingBoxPoint.RIGHT_CENTER:
				{
					point_out.copy(m_max);
					point_out.incY(-this.calcHeight() / 2);
					
					break;
				}
				
				case qb2E_GeoBoundingBoxPoint.BOTTOM_RIGHT:
				{
					point_out.copy(m_max);
					
					break;
				}
				
				case qb2E_GeoBoundingBoxPoint.BOTTOM_CENTER:
				{
					point_out.copy(m_max);
					point_out.incX( -this.calcWidth() / 2);
					break;
				}
				
				case qb2E_GeoBoundingBoxPoint.BOTTOM_LEFT:
				{
					point_out.copy(m_max);
					point_out.incX( -this.calcWidth());
					
					break;
				}
				
				case qb2E_GeoBoundingBoxPoint.LEFT_CENTER:
				{
					point_out.copy(m_min);
					point_out.incY(this.calcHeight() / 2);
					break;
				}
			}
		}
		
		public function calcBoundaryEdge(eEdge:qb2E_GeoBoundingBoxEdge, line_out:qb2GeoLine):void
		{
			switch(eEdge)
			{
				case qb2E_GeoBoundingBoxEdge.TOP:
				{
					this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.TOP_LEFT, line_out.getPointA());
					this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.TOP_RIGHT, line_out.getPointB());
					
					break;
				}
				
				case qb2E_GeoBoundingBoxEdge.RIGHT:
				{
					this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.TOP_RIGHT, line_out.getPointA());
					this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.BOTTOM_RIGHT, line_out.getPointB());
					
					break;
				}
				
				case qb2E_GeoBoundingBoxEdge.BOTTOM:
				{
					this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.BOTTOM_RIGHT, line_out.getPointA());
					this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.BOTTOM_LEFT, line_out.getPointB());
					
					break;
				}
				
				case qb2E_GeoBoundingBoxEdge.LEFT:
				{
					this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.BOTTOM_LEFT, line_out.getPointA());
					this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.TOP_LEFT, line_out.getPointB());
					
					break;
				}
			}
		}
		
		public override function calcBoundingBox(outBox:qb2GeoBoundingBox):void
		{
			outBox.copy(this);
		}
	
		/*public function containsArea(otherArea:qb2A_GeoBoundingRegion, tolerance:Number = 0, includeEdges:Boolean = true):Boolean
		{
			if ( otherArea is qb2GeoBoundingBox )
			{
				var otherBox:qb2GeoBoundingBox = otherArea as qb2GeoBoundingBox
				return containsPoint(otherBox.m_min, tolerance, includeEdges) && containsPoint(otherBox.m_max, tolerance, includeEdges);
			}
			else if( otherArea is qb2GeoBoundingBall )
			{
				var circle:qb2GeoBoundingBall = otherArea as qb2GeoBoundingBall;
				if ( includeEdges )
				{
					return qb2U_Math.isWithin(circle.m_center.m_x - circle.m_radius, m_min.m_x, m_max.m_x) && qb2U_Math.isWithin(circle.m_center.m_x + circle.m_radius, m_min.m_x, m_max.m_x) &&
						   qb2U_Math.isWithin(circle.m_center.getY() - circle.m_radius, m_min.getY(), m_max.getY()) && qb2U_Math.isWithin(circle.m_center.getY() + circle.m_radius, m_min.getY(), m_max.getY());   
				}
				else
				{
					return qb2U_Math.isBetween(circle.m_center.m_x - circle.m_radius, m_min.m_x, m_max.m_x) && qb2U_Math.isBetween(circle.m_center.m_x + circle.m_radius, m_min.m_x, m_max.m_x) &&
						   qb2U_Math.isBetween(circle.m_center.getY() - circle.m_radius, m_min.getY(), m_max.getY()) && qb2U_Math.isBetween(circle.m_center.getY() + circle.m_radius, m_min.getY(), m_max.getY());
				}
			}
			
			return false;
		}*/
		
		public override function swell(byAmount:Number):void
		{
			this.pushEventDispatchBlock();
			{
				m_min.inc( -byAmount, byAmount);
				m_max.inc( byAmount, byAmount);
			}
			this.popEventDispatchBlock();
		}
		
		public override function expandBoundingRegion(region:qb2A_GeoBoundingRegion):void
		{
			region.pushEventDispatchBlock();
			{
				region.expandToPoint(m_min);
				region.expandToPoint(m_max);
				
				calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.TOP_RIGHT, s_utilPoint);
				region.expandToPoint(s_utilPoint);
				calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.BOTTOM_LEFT, s_utilPoint);
				region.expandToPoint(s_utilPoint);
			}
			region.popEventDispatchBlock();
		}
		
		public override function expandToPoint(point:qb2GeoPoint, radius:Number = 0 ):void
		{
			this.pushEventDispatchBlock();
			{
				if ( point.getX() - radius < m_min.getX() )  m_min.setX(point.getX() - radius);
				if ( point.getY() - radius < m_min.getY() )  m_min.setY(point.getY() - radius);
				
				if ( point.getX() + radius > m_max.getX() )  m_max.setX(point.getX() + radius);
				if ( point.getY() + radius > m_max.getY() )  m_max.setY(point.getY() + radius);
			}
			this.popEventDispatchBlock();
		}
		
		BoundBox.prototype.setHeight = function(value)
		{
			this.m_min.calcMidwayPoint(this.m_max, utilPoint_bb);
			
			this.m_min.setY(utilPoint_bb.getY() - value/2);
			this.m_max.setY(utilPoint_bb.getY() + value/2);
		};

		BoundBox.prototype.setWidth = function(value)
		{
			this.m_min.calcMidwayPoint(this.m_max, utilPoint_bb);
			
			this.m_min.setX(utilPoint_bb.getX() - value/2);
			this.m_max.setX(utilPoint_bb.getX() + value/2);
		};

		BoundBox.prototype.setDimensions = function(width, height)
		{
			this.m_min.calcMidwayPoint(this.m_max, utilPoint_bb);
			
			this.m_min.setX(utilPoint_bb.getX() - width/2);
			this.m_max.setX(utilPoint_bb.getX() + width/2);
			this.m_min.setY(utilPoint_bb.getY() - height/2);
			this.m_max.setY(utilPoint_bb.getY() + height/2);
		};
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			graphics.moveTo(m_min);
			var drawPnt:qb2GeoPoint = m_min.clone() as qb2GeoPoint;
			drawPnt.incX(calcWidth());
			graphics.drawLineTo(drawPnt);
			graphics.drawLineTo(m_max);
			drawPnt.copy(m_max);
			drawPnt.incX( -calcWidth());
			graphics.drawLineTo(drawPnt);
			graphics.drawLineTo(m_min);
		}
		
		protected override function nextDecomposition(progress:int):qb2A_GeoEntity
		{			
			if ( progress == 0 )
			{
				return m_min;
			}
			else if ( progress == 1 )
			{
				return m_max;
			}
			
			return null;
		}
		
		protected override function nextGeometry(progress:int, T_extends_qb2A_GeoEntity:Class, progressOffset_out:qb2Integer):qb2A_GeoEntity
		{
			if ( qb2U_Type.isKindOf(T_extends_qb2A_GeoEntity, qb2GeoPoint) )
			{
				if ( progress <= 3)
				{
					switch(progress)
					{
						case 0:  this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.TOP_LEFT, s_utilPoint);		break;
						case 1:  this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.TOP_RIGHT, s_utilPoint);		break;
						case 2:  this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.BOTTOM_RIGHT, s_utilPoint);	break;
						case 3:  this.calcBoundaryPoint(qb2E_GeoBoundingBoxPoint.BOTTOM_LEFT, s_utilPoint);		break;
					}
					
					return s_utilPoint;
				}
			}
			else if ( qb2U_Type.isKindOf(T_extends_qb2A_GeoEntity, qb2GeoLine) )
			{
				var enumCount:int = qb2Enum.getCount(qb2E_GeoBoundingBoxEdge);
				
				if ( progress <= enumCount )
				{
					this.calcBoundaryEdge(qb2Enum.getEnumForOrdinal(qb2E_GeoBoundingBoxEdge, progress), s_utilLine);
					
					return s_utilLine;
				}
			}
			
			return null;
		}
		
		/*public override function convertTo(T:Class):*
		{
			if ( T == String )
			{
				return qb2U_ToString.auto(this, "min", m_min, "max", m_max);
			}
			/*else if ( qb2U_Type.isInChain(T, qb2GeoPolygon, qb2A_GeoCurveBoundedPlane) )
			{
				var polygon:qb2GeoPolygon = qb2Class.getInstance(T).newInstance();
				polygon.addPoints(this.convertToArray(qb2GeoPoint) as Vector.<qb2GeoPoint>);
				
				return polygon;
			}
			else if ( qb2U_Type.isKindOf(T, qb2GeoCurveBoundedPlane) )
			{
				var plane:qb2GeoCurveBoundedPlane = qb2Class.getInstance(T).newInstance();
				plane.setBoundary(this.convertTo(qb2GeoPolyline));
				
				return plane;
			}
			else if ( qb2U_Type.isInChain(T, qb2GeoPolyline, qb2A_GeoCurve) )
			{
				var polyline:qb2GeoPolyline = qb2Class.getInstance(T).newInstance();
				polyline.set(this.convertToArray(qb2GeoPoint) as Vector.<qb2GeoPoint>);
				
				return polyline;
			}
			else if ( qb2U_Type.isKindOf(T, qb2GeoCompositeCurve) )
			{
				var compositeCurve:qb2GeoCompositeCurve = qb2Class.getInstance(T).newInstance();
				
				compositeCurve.set(this.convertToArray(qb2A_GeoCurve) as Vector.<qb2A_GeoCurve>);
				
				return compositeCurve;
			}
			
			
			return super.convertTo(T);
		}*/
		
		protected override function copy_protected(otherObject:*):void
		{
			if ( qb2U_Type.isKindOf(otherObject, qb2GeoPoint) )
			{
				this.pushEventDispatchBlock();
				{
					m_min.copy(otherObject);
					m_max.copy(otherObject);
				}
				this.popEventDispatchBlock();
				
				return;
			}
			
			return super.copy(otherObject);
		}
	}	
}