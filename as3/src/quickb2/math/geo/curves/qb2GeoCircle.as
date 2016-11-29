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
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.display.immediate.style.qb2U_Style;
	import quickb2.lang.*
	import quickb2.math.geo.qb2PU_Circle;
	import quickb2.math.geo.qb2PU_Ellipse;
	import quickb2.math.qb2S_Math;
	import quickb2.math.qb2U_Formula;
	import quickb2.math.qb2U_MomentOfInertia;
	import quickb2.utils.prop.qb2PropMap;
	
	import quickb2.math.geo.bounds.qb2A_GeoBoundingRegion;
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoCircularEntity;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoCurveBoundedPlane;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoPlanarSurface;
	import quickb2.math.geo.surfaces.planar.qb2GeoCircularDisk;
	import quickb2.math.geo.surfaces.planar.qb2GeoEllipticalDisk;
	import quickb2.event.qb2EventDispatcher;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	
	public class qb2GeoCircle extends qb2A_GeoCurve implements qb2I_GeoCircularEntity
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		
		private const m_center:qb2GeoPoint = new qb2GeoPoint();
		private var m_radius:Number = 0;
		private var m_isFlipped:Boolean = false;
		
		public function qb2GeoCircle(center_nullable_copied:qb2GeoPoint = null, radius:Number = 0)
		{
			set(center_nullable_copied != null ? center_nullable_copied : m_center, radius);
		}
		
		private function init(sourceCenter:qb2GeoPoint, radius:Number):void
		{
			this.set(sourceCenter, radius);
			
			this.addEventListenerToSubEntity(m_center, false);
		}
		
		public override function getCurveType():qb2F_GeoCurveType
		{
			return qb2F_GeoCurveType.IS_CLOSED;
		}
		
		public override function flip():void
		{
			m_isFlipped = !m_isFlipped;
		}
		
		public override function isEqualTo(otherEntity:qb2A_GeoEntity, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			return qb2PU_Circle.isEqualTo(this, otherEntity, tolerance_nullable);
		}
		
		public function set(center_copied:qb2GeoPoint, radius:Number):void
		{
			m_radius = radius;
			m_center.copy(center_copied);
		}
		
		protected override function copy_protected(source:*):void
		{
			qb2PU_Circle.copy(source, this);
		}
		
		public function getRadius():Number
		{
			return m_radius;
		}
		
		public function setRadius(radius:Number):void
		{
			m_radius = radius;
			
			this.dispatchChangedEvent();
		}
		
		public function getCenter():qb2GeoPoint
		{
			return m_center;
		}
		
		public function setCenter(x:Number, y:Number, z:Number = 0):void
		{
			m_center.set(x, y, z);
		}
		
		public override function calcLength():Number
		{
			return qb2U_Formula.circleCircumference(m_radius);
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			point_out.copy(m_center);
		}
		
		protected override function calcSimpleMomentOfInertia(mass:Number, curveThickness:Number = 0):Number
		{
			if ( curveThickness == 0 )
			{
				return qb2U_MomentOfInertia.circle(mass, this.getRadius());
			}
			else
			{
				var curveThicknessDiv2:Number = curveThickness / 2;
				var radius1:Number = this.getRadius() - curveThicknessDiv2;
				var radius2:Number = this.getRadius() + curveThicknessDiv2;
				
				return qb2U_MomentOfInertia.flatRing(mass, radius1, radius2);
			}
		}
		
		public override function calcArea(startParam:Number, endParam:Number):Number
		{
			var startAngle:Number = startParam * qb2S_Math.TAU;
			var endAngle:Number = endParam * qb2S_Math.TAU;
			
			var area:Number = qb2U_Formula.circleSegmentArea(m_radius, Math.abs(endAngle - startAngle));
			
			return m_isFlipped ? -area : area;
		}
		
		public override function calcPointAtParam(param:Number, point_out:qb2GeoPoint):void
		{
			qb2PU_Circle.calcCircleStartPoint(m_center, m_radius, point_out);
			
			var theta:Number = param * qb2S_Math.TAU;
			theta = m_isFlipped ? -theta : theta;
			
			point_out.rotateBy(theta, m_center);
		}
		
		public function calcPointAtAngle(radians:Number, point_out:qb2GeoPoint):void
		{
			calcPointAtParam(radians / qb2S_Math.RADIANS_360, point_out);
		}
		
		public override function calcNormalAtParam(param:Number, vector_out:qb2GeoVector, normalizeVector:Boolean):void
		{
			qb2PU_Circle.calcNormalAtParam(this, m_center, param, vector_out, m_isFlipped, normalizeVector);
		}
		
		public override function calcBoundingBall(ball_out:qb2GeoBoundingBall):void
		{
			ball_out.copy(this);
		}
		
		public override function calcBoundingBox(box_out:qb2GeoBoundingBox):void
		{
			box_out.set(m_center, m_center);
			box_out.swell(m_radius);
		}
		
		protected override function nextDecomposition(progress:int):qb2A_GeoEntity
		{
			return progress == 0 ? m_center : null;
		}
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			qb2U_Style.populateGraphics(graphics, propertyMap_nullable);
			graphics.drawCircle(m_center, m_radius);
			qb2U_Style.depopulateGraphics(graphics, propertyMap_nullable);
		}
		
		/*public override function convertTo(T:Class):*
		{
			var entity:* = qb2PU_Circle.convertTo(this, T);
				
			if ( entity != null )
			{
				return entity;
			}
			
			return super.convertTo(T);
		}*/
	}
}