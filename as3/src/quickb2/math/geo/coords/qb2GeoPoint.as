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

package quickb2.math.geo.coords
{
	import quickb2.debugging.logging.*;
	import quickb2.display.immediate.style.qb2U_Style;
	import quickb2.lang.*;
	import quickb2.lang.errors.*;
	import quickb2.lang.operators.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.qb2I_Matrix;
	import quickb2.math.qb2U_Matrix;
	import quickb2.math.qb2U_MomentOfInertia;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2U_Prop;
	
	import quickb2.math.geo.*;
	import quickb2.math.geo.bounds.qb2A_GeoBoundingRegion;
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.curves.*;
	import quickb2.math.geo.surfaces.*;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	public class qb2GeoPoint extends qb2A_GeoCoordinate
	{
		private static var s_utilVector:qb2GeoVector = null;
		
		private static const s_transformPoint:qb2GeoPoint = new qb2GeoPoint();
		
		public function qb2GeoPoint( x:Number = 0, y:Number = 0, z:Number = 0):void
		{
			super(x, y, z);
		}
		
		//--- DRK > Needed because of reference loop during class initialization.
		private static function initUtilVector():void
		{
			s_utilVector = s_utilVector != null ? s_utilVector : new qb2GeoVector();
		}
		
		public override function isEqualTo(otherEntity:qb2A_GeoEntity, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			var asPoint:qb2GeoPoint = otherEntity as qb2GeoPoint;
			
			if ( asPoint != null )
			{
				if ( tolerance_nullable.equalPoint == 0 )
				{
					return this.m_x == asPoint.m_x && this.m_y == asPoint.m_y && this.m_z == asPoint.m_z;
				}
				else
				{
					return this.calcDistanceTo(otherEntity) <= tolerance_nullable.equalPoint;
				}
			}
			
			return false;
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			point_out.copy(this);
		}
		
		public override function transformBy(matrix:qb2I_Matrix):void
		{
			qb2U_Matrix.multiply(matrix, this, s_transformPoint);
			this.copy(s_transformPoint);
		}
		
		public override function expandBoundingRegion(region:qb2A_GeoBoundingRegion):void
		{
			region.expandToPoint(this, 0);
		}
		
		public override function calcBoundingBox(outBox:qb2GeoBoundingBox):void
		{
			outBox.set(this, this);
		}
		
		public override function calcBoundingBall(outBall:qb2GeoBoundingBall):void
		{
			outBall.set(this, 0.0);
		}
		
		public function calcDeltaTo(otherPoint:qb2GeoPoint, vector_out:qb2GeoVector):void
		{
			vector_out.set(otherPoint.m_x - m_x, otherPoint.m_y - m_y, otherPoint.m_z - m_z);
		}

		public function minus(otherPoint:qb2GeoPoint):qb2GeoVector
		{
			var vec:qb2GeoVector = new qb2GeoVector();
			vec.set(m_x - otherPoint.m_x, m_y - otherPoint.m_y, m_z - otherPoint.m_z);
			
			return vec;
		}
		
		public override function calcDistanceSquaredTo(otherEntity:qb2A_GeoEntity, line_out:qb2GeoLine = null):Number
		{
			var otherPoint:qb2GeoPoint = otherEntity as qb2GeoPoint;
			if ( otherPoint != null )
			{				
				if ( line_out != null )
				{
					line_out.set(this, otherPoint);
				}
				
				initUtilVector();
				this.calcDelta(otherPoint, s_utilVector);
				
				return s_utilVector.calcLengthSquared();
			}
			
			return super.calcDistanceSquaredTo(otherEntity, line_out);
		}
		
		public override function calcMomentOfInertia(mass:Number, axis_nullable:qb2I_GeoHyperAxis = null, centerOfMass_out_nullable:qb2GeoPoint = null):Number
		{
			if ( centerOfMass_out_nullable != null )
			{
				this.calcCenterOfMass(centerOfMass_out_nullable);
			}
			
			if ( axis_nullable == null || qb2U_Type.isKindOf(axis_nullable, qb2GeoVector) )
			{
				return 0;
			}
			else if( qb2U_Type.isKindOf(axis_nullable, qb2GeoPoint) )
			{
				var axisAsPoint:qb2GeoPoint = axis_nullable as qb2GeoPoint;
				return qb2U_MomentOfInertia.point(mass, this.calcDistanceSquaredTo(axisAsPoint));
			}
			else
			{
				// TODO: Implement for line axis.
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			}
			
			return NaN;
		}

		public function calcMidwayPoint(otherPoint:qb2GeoPoint, point_out:qb2GeoPoint):void
		{
			initUtilVector();
			otherPoint.calcDelta(this, s_utilVector);
			s_utilVector.scaleByNumber(.5);
			point_out.copy(this);
			point_out.translateBy(s_utilVector);
		}

		public function calcManhattanDistanceTo(otherPoint:qb2GeoPoint):Number
		{
			return Math.abs(otherPoint.m_x - this.m_x) + Math.abs(otherPoint.m_y - this.m_y) + Math.abs(otherPoint.m_z - this.m_z)
		}
		
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			qb2U_Style.populateGraphics(graphics, propertyMap_nullable);
			
			var radius:Number = qb2U_Prop.getPropValue(qb2S_GeoStyle.POINT_RADIUS, propertyMap_nullable);
			graphics.drawCircle(this, radius);
			
			qb2U_Style.depopulateGraphics(graphics, propertyMap_nullable);
		}
		
		public override function calcIsIntersecting(otherEntity:qb2A_GeoEntity, options_nullable:qb2GeoIntersectionOptions = null, result_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			var tolerance:qb2GeoTolerance = qb2GeoIntersectionOptions.getDefaultTolerance(options_nullable);
			
			if ( qb2U_Type.isKindOf(otherEntity, qb2GeoPoint) )
			{
				return this.calcDistanceTo(otherEntity) <= tolerance.equalPoint
			}
			else if ( qb2U_Type.isKindOf(otherEntity, qb2GeoVector) )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			}
			else
			{
				return otherEntity.calcIsIntersecting(this, options_nullable, result_out_nullable);
			}
			
			return false;
		}
		
		/*public override function convertTo(T:Class):*
		{
			if ( T === qb2GeoVector )
			{
				var vector:qb2GeoVector = new qb2GeoVector();
				vector.set(m_x, m_y, m_z);
				
				return vector;
			}
			
			return super.convertTo(T);
		}*/
	}
}