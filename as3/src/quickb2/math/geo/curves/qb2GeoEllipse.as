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
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.graphics.qb2U_Graphics;
	import quickb2.display.immediate.style.qb2U_Style;
	import quickb2.lang.*
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2E_PerpVectorDirection;
	import quickb2.math.geo.qb2GeoIntersectionOptions;
	import quickb2.math.geo.qb2GeoIntersectionResult;
	import quickb2.math.geo.qb2PU_Ellipse;
	import quickb2.math.geo.qb2U_Transform;
	import quickb2.math.qb2S_Math;
	import quickb2.math.qb2U_Formula;
	import quickb2.math.qb2U_Math;
	import quickb2.utils.prop.qb2PropMap;
	
	import quickb2.lang.operators.*;
	import quickb2.math.geo.bounds.qb2A_GeoBoundingRegion;
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoEllipticalEntity;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoCurveBoundedPlane;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoPlanarSurface;
	import quickb2.math.geo.surfaces.planar.qb2GeoCircularDisk;
	import quickb2.math.geo.surfaces.planar.qb2GeoEllipticalDisk;
	import quickb2.event.qb2EventDispatcher;
	
	
	public class qb2GeoEllipse extends qb2A_GeoCurve implements qb2I_GeoEllipticalEntity
	{
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector:qb2GeoVector = new qb2GeoVector();
		
		private const m_center:qb2GeoPoint = new qb2GeoPoint();
		private const m_majorAxis:qb2GeoVector = new qb2GeoVector();
		private var m_minorAxis:Number = 0;
		private var m_isFlipped:Boolean;
		
		public function qb2GeoEllipse(center_copied_nullable:qb2GeoPoint = null, majorAxis_copied_nullable:qb2GeoVector = null, minorAxis:Number = 0)
		{
			init(center_copied_nullable, majorAxis_copied_nullable, minorAxis);
		}
		
		private function init(sourceCenter:qb2GeoPoint, sourceMajorAxis:qb2GeoVector, minorAxis:Number):void
		{
			this.set(sourceCenter, sourceMajorAxis, minorAxis);
			
			this.addEventListenerToSubEntity(m_center, false);
			
			m_isFlipped = false;
		}
		
		public override function getCurveType():qb2F_GeoCurveType
		{
			return qb2F_GeoCurveType.IS_CLOSED;
		}
		
		public function setIsFlipped(value:Boolean):void
		{
			m_isFlipped = true;
		}
		
		public function isFlipped():Boolean
		{
			return m_isFlipped;
		}
		
		public function set(center_nullable:qb2GeoPoint, majorAxis:qb2GeoVector, minorAxis:Number):void
		{
			this.pushEventDispatchBlock();
			{
				m_minorAxis = minorAxis;
				
				if ( center_nullable != null )
				{
					m_center.copy(center_nullable);
				}
				
				if ( majorAxis != null)
				{
					m_majorAxis.copy(majorAxis);
				}
			}
			this.popEventDispatchBlock();
		}
		
		public function getMinorAxis():Number
		{
			return m_minorAxis;
		}
		
		public function setMinorAxis(minorAxis:Number):void
		{
			m_minorAxis = minorAxis;
			
			this.dispatchChangedEvent();
		}
		
		public function getMajorAxis():qb2GeoVector
		{
			return m_majorAxis;
		}
		
		public function setMajorAxis(x:Number, y:Number, z:Number = 0):void
		{
			m_majorAxis.set(x, y, z);
		}
		
		public function getCenter():qb2GeoPoint
		{
			return m_center;
		}
		
		public function setCenter(x:Number, y:Number, z:Number = 0):void
		{
			m_center.set(x, y, z);
		}
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			qb2U_Style.populateGraphics(graphics, propertyMap_nullable);
			qb2U_Graphics.drawEllipse(graphics, m_center, m_majorAxis, m_minorAxis);
			qb2U_Style.depopulateGraphics(graphics, propertyMap_nullable);
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			point_out.copy(m_center);
		}
		
		public override function calcArea(startParam:Number, endParam:Number):Number
		{
			if ( startParam <= 0 && endParam >= 1 )
			{
				var area:Number = qb2U_Formula.ellipseArea(m_majorAxis.calcLength(), m_minorAxis);
				
				return m_isFlipped ? -area : area;
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			}
			
			return 0;
		}
		
		public override function calcIsLinear(line_out_nullable:qb2GeoLine = null, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			var majorLength:Number = m_majorAxis.calcLength();
			var isLinear:Boolean = false;
			var axisVector:qb2GeoVector;
			
			if ( qb2U_Math.equals(m_minorAxis, 0, tolerance_nullable.equalComponent) && majorLength != 0 )
			{
				axisVector = m_majorAxis;
				isLinear = true;
			}
			else if ( qb2U_Math.equals(majorLength, 0, tolerance_nullable.equalComponent) && m_minorAxis != 0 )
			{
				axisVector = s_utilVector;
				axisVector.set(0, m_minorAxis, 0);
				
				isLinear = true;
			}
			
			if ( isLinear && line_out_nullable != null )
			{
				line_out_nullable.copy(m_center);
				line_out_nullable.getPointA().translateBy(axisVector, true);
				line_out_nullable.getPointB().translateBy(axisVector, false);
			}
			
			return isLinear;
		}
		
		public override function calcIsIntersecting(otherEntity:qb2A_GeoEntity, options_nullable:qb2GeoIntersectionOptions = null, output_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			var tolerance:qb2GeoTolerance = qb2GeoIntersectionOptions.getDefaultTolerance(options_nullable);
			
			if ( qb2U_Type.isKindOf(otherEntity, qb2GeoPoint) )
			{
				qb2U_Transform.toWorldAligned(otherEntity, getCenter(), getMajorAxis(), s_utilPoint);
				var result:Number = qb2U_Formula.ellipse(getMajorAxis().calcLength(), getMinorAxis(), s_utilPoint.getX(), s_utilPoint.getY());
				
				return result == 1;
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			}
			
			return false;
		}
		
		public override function calcNormalAtParam(param:Number, vector_out:qb2GeoVector, normalizeVector:Boolean):void
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			///qb2PU_CurveWithCenter.calcNormalAtParam(this, m_center, param, vector_out, m_isFlipped, normalizeVector);
		}
		
		public override function calcPointAtParam(param:Number, point_out:qb2GeoPoint):void
		{
			param = param % 1;
			var radians:Number = qb2S_Math.TAU * param;
			radians = m_isFlipped ? -radians : radians;
			
			var x:Number = qb2U_Formula.ellipseParametricX(m_majorAxis.calcLength(), radians);
			var y:Number = qb2U_Formula.ellipseParametricY(m_minorAxis, radians);
			point_out.set(x, y);
			
			qb2U_Transform.toEntityAligned(point_out, m_center, m_majorAxis, point_out);
		}
		
		public function calcPointAtAngle(radians:Number, point_out:qb2GeoPoint):void
		{
			s_utilPoint.copy(m_center);
			
			radians = radians > 0 ? radians % qb2S_Math.TAU : radians % -qb2S_Math.TAU;
			radians = m_isFlipped ? -radians : radians;
			var a:Number = m_majorAxis.calcLength();
			var b:Number = m_minorAxis;
			var a_2:Number = a * a;
			var b_2:Number = b * b;
			var theta:Number = radians;
			var tanTheta:Number = Math.tan(theta);
			var tanTheta_2:Number = tanTheta * tanTheta;
			var denominator:Number = Math.sqrt(b_2 + a_2 * tanTheta_2);
			
			var x:Number = (a * b) / denominator;
			var y:Number = (a * b * tanTheta) / denominator;
			
			if ( theta > qb2S_Math.RADIANS_90 && theta < qb2S_Math.RADIANS_270 )
			{
				x = -x;
				y = -y;
			}
			
			point_out.set(x, y);
			
			qb2U_Transform.toEntityAligned(point_out, m_center, m_majorAxis, point_out);
		}
		
		public override function calcBoundingBall(ball_out:qb2GeoBoundingBall):void
		{
			ball_out.set(this.getCenter(), Math.max(this.getMinorAxis(), this.getMajorAxis().calcLength()));
		}
		
		public override function calcBoundingBox(box_out:qb2GeoBoundingBox):void
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
		}
		
		public override function calcLength():Number
		{
			return qb2U_Formula.ellipseCircumferenceApproximate(this.getMajorAxis().calcLength(), this.getMinorAxis());
		}
		
		protected override function nextDecomposition(progress:int):qb2A_GeoEntity
		{
			if ( progress == 0 )
			{
				return m_center;
			}
			else if ( progress == 1 )
			{
				return m_majorAxis;
			}
			
			return null;
		}
		
		public override function isEqualTo(otherEntity:qb2A_GeoEntity, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			return qb2PU_Ellipse.isEqualTo(this, otherEntity, tolerance_nullable);
		}
		
		protected override function copy_protected(source:*):void
		{
			qb2PU_Ellipse.copy(source, this);
		}

		/*public override function convertTo(T:Class):*
		{
			var entity:* = qb2PU_Ellipse.convertTo(this, T);
			
			if ( entity != null )
			{
				return entity;
			}
			
			return super.convertTo(T);
		}*/
	}
}