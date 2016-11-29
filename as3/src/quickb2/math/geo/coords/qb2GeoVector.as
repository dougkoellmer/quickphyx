/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * in the Software without restriction, including without limitation the rights
 * of this software and associated documentation files (the "Software"), to deal
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
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.style.qb2U_Style;
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.*;
	import quickb2.math.geo.bounds.qb2A_GeoBoundingRegion;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoHyperPlane;
	import quickb2.math.geo.qb2PU_Geo;
	import quickb2.math.geo.qb2S_GeoStyle;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2U_Prop;
	
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.qb2U_Math;
	
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventDispatcher;
	
	import quickb2.lang.*
	

	public class qb2GeoVector extends qb2A_GeoCoordinate
	{
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		private static const s_utilVector2:qb2GeoVector = new qb2GeoVector();
		private static const s_utilVector3:qb2GeoVector = new qb2GeoVector();
		
		private static var s_utilPoint:qb2GeoPoint = null;
		
		public function qb2GeoVector( x:Number = 0, y:Number = 0, z:Number = 0):void
		{
			super(x, y, z);
		}
		
		//--- DRK > Needed because of class reference loop during initialization.
		private static function initUtilPoint():void
		{
			s_utilPoint = s_utilPoint != null ? s_utilPoint : new qb2GeoPoint();
		}

		public static function newRotVector(baseX:Number, baseY:Number, radians:Number):qb2GeoVector
		{
			var newVec:qb2GeoVector = new qb2GeoVector(baseX, baseY);
			newVec.rotateBy(radians);
			return newVec;
		}
		
		public override function isEqualTo(otherEntity:qb2A_GeoEntity, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
		
			/*if ( qb2U_Type.isKindOf(otherEntity, qb2GeoVector) )
			{
				return false;
			}*/
			
			return super.isEqualTo(otherEntity);
		}
		
		public override function expandBoundingRegion(region:qb2A_GeoBoundingRegion):void
		{
			// do nothing.
		}
		
		public override function transformBy(matrix:qb2I_Matrix):void
		{
			qb2U_Matrix.multiply(matrix, this, s_utilVector1);
			this.copy(s_utilVector1);
		}
		
		/*public override function convertTo(T:Class):*
		{
			if ( qb2U_Type.isKindOf(T, qb2GeoPoint) )
			{
				var point:qb2GeoPoint = qb2Class.getInstance(T).newInstance();
				point.set(m_x, m_y, m_z);
				return point;
			}
			else if ( qb2U_Type.isKindOf(T, qb2GeoLine) )
			{
				var line:qb2GeoLine = qb2Class.getInstance(T).newInstance();
				line.getPointA().set(0, 0);
				line.getPointB().set(m_x, m_y, m_z);
				return line;
			}
			
			return super.convertTo(T);
		}*/

		public function isZeroLength(tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			return qb2U_Math.equals(calcLengthSquared(), 0, tolerance_nullable.equalPoint);
		}

		public function calcNormal(vector_out:qb2GeoVector):void
		{
			vector_out.copy(this);
			vector_out.normalize();
		}

		public function normalize():void
		{
			var mag:Number = this.calcLength();
			if ( mag != 0 )
			{
				this.set(m_x / mag, m_y / mag, m_z / mag);
			}
			else
			{
				this.zeroOut();
			}
		}

		public function calcDotProduct(otherVector:qb2GeoVector):Number
		{
			return m_x * otherVector.m_x + m_y * otherVector.m_y + m_z * otherVector.m_z;
		}

		public function calcPerpVector(eDirection:qb2E_PerpVectorDirection, vector_out:qb2GeoVector):void
		{
			vector_out.setToPerpVector(eDirection);
		}
			
		public function setToPerpVector(eDirection:qb2E_PerpVectorDirection):void
		{
			var direction:int = eDirection == qb2E_PerpVectorDirection.RIGHT ? 1 : -1;
			
			if ( qb2S_Math.FLIPPED_Y )
			{
				//--- Because in flash and many other 2d graphics rendering systems the y-axis is flipped, flip the direction internally.
				direction = -direction;
			}
			
			var tempX:Number = m_x;
			var tempY:Number = m_y;
			
			if ( direction >= 0 )
			{
				m_y = -tempX;
				m_x = tempY;
				
				set(tempY, -tempX);
			}
			else
			{
				set(-tempY, tempX);
			}
		}

		
		public function isUnitLength(tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			return qb2U_Math.equals(1.0, this.calcLength(), tolerance_nullable.equalVector);
		}

		public function isCodirectionalTo(otherVector:qb2GeoVector, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			return this.calcAbsoluteAngleTo(otherVector) <= tolerance_nullable.equalAngle;
		}

		public function isAntidirectionalTo(otherVector:qb2GeoVector, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			return this.calcAbsoluteAngleTo(otherVector) >= Math.PI - tolerance_nullable.equalAngle;
		}
			
		public function isParallelTo(otherVector:qb2GeoVector, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			var angle:Number = this.calcAbsoluteAngleTo(otherVector);
			return angle <= tolerance_nullable.equalAngle || angle >= Math.PI - tolerance_nullable.equalAngle;
		}
		
		public function isPerpendicularTo(otherVector:qb2GeoVector, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			return qb2U_Math.equals(this.calcAbsoluteAngleTo(otherVector), Math.PI / 2, tolerance_nullable.equalAngle);
		}

		/*public override function mirror(plane:qb2I_GeoHyperPlane):void
		{
			var line:qb2GeoLine = plane as qb2GeoLine;
			var lineNormal:qb2GeoVector = new qb2GeoVector();
			line.calcDirection(lineNormal, true);
			var dot:Number = -m_x * lineNormal.m_x - m_y * lineNormal.m_y;
			m_x = m_x + 2 * lineNormal.m_x * dot;
			m_y = m_y + 2 * lineNormal.m_y * dot;
			negate();
		}*/

		public function negate():void
		{
			this.scaleByNumber( -1);
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			point_out.copy(this);
			point_out.scaleByNumber(.5);
		}
		
		public function calcSignedAngleTo(otherVector:qb2GeoVector):Number
		{
			var angle:Number =  -(Math.atan2(otherVector.m_y, otherVector.m_x) - Math.atan2(m_y, m_x));
			
			if ( qb2S_Math.FLIPPED_Y )
			{
				angle = -angle;
			}
			
			angle = qb2U_Math.minimizeAngle(angle);
			
			return angle;
		}

		public function calcClockwiseAngleTo(otherVector:qb2GeoVector):Number
		{
			var signedAngle:Number = calcSignedAngleTo(otherVector);
			return signedAngle < 0 ? qb2S_Math.PI + (qb2S_Math.PI + signedAngle) : signedAngle;
		}
		
		public function calcAbsoluteAngleTo(otherVector:qb2GeoVector):Number
		{
			var thisNormal:qb2GeoVector = s_utilVector2
			this.calcNormal(thisNormal);
			var otherNormal:qb2GeoVector = s_utilVector3;
			otherVector.calcNormal(otherNormal);
			return Math.acos(thisNormal.calcDotProduct(otherNormal));
		}
		
		public function calcLength():Number
		{
			return Math.sqrt(calcLengthSquared());
		}
		
		public function setLength(value:Number):void
		{
			var mag:Number = this.calcLength();
			
			if ( mag != 0)
			{
				m_x /= mag;
				m_y /= mag;
				m_z /= mag;
			}
			
			this.scaleByNumber(value);
		}
		
		public function calcLengthSquared():Number
		{
			return m_x * m_x + m_y * m_y + m_z * m_z;
		}
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			if ( isZeroLength() )
			{
				return;
			}
			
			var angle:Number = qb2U_Prop.getPropValue(qb2S_GeoStyle.VECTOR_ARROWANGLE, propertyMap_nullable);
			var size:Number = qb2U_Prop.getPropValue(qb2S_GeoStyle.VECTOR_ARROWSIZE, propertyMap_nullable);
			
			if ( angle == 0 || size == 0 )
			{
				return;
			}
			
			initUtilPoint();
			
			qb2U_Style.populateGraphics(graphics, propertyMap_nullable);
			
			graphics.pushParam(qb2E_DrawParam.FILL_COLOR, 0);
			
			initUtilPoint();
			
			s_utilPoint.zeroOut();
			
			graphics.drawLine(s_utilPoint, this);
			
			s_utilVector1.copy(this);
			s_utilVector1.negate();
			s_utilVector1.setLength(size);
			
			s_utilPoint.copy(this);
			s_utilPoint.translateBy(s_utilVector1);
			
			s_utilPoint.rotateBy(angle / 2, this);
			graphics.drawLine(this, s_utilPoint);
			
			s_utilPoint.rotateBy( -angle, this);
			graphics.drawLine(this, s_utilPoint);
			
			graphics.popParam(qb2E_DrawParam.FILL_COLOR);
			
			qb2U_Style.depopulateGraphics(graphics, propertyMap_nullable);
		}
	}
}