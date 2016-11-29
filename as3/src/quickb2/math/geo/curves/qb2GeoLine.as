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
	import quickb2.debugging.logging.*;
	import quickb2.display.immediate.graphics.*;
	import quickb2.lang.*;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.lang.types.*;
	import quickb2.math.*;
	import quickb2.math.geo.*;
	import quickb2.math.geo.coords.*;
	import quickb2.math.geo.curves.intersection.*;
	import quickb2.utils.prop.qb2PropMap;

	

	public class qb2GeoLine extends qb2A_GeoCurve implements qb2I_GeoHyperPlane, qb2I_GeoHyperAxis, qb2I_GeoTessellatedCurve
	{
		private static const s_lineIntValues:Vector.<Number> = new Vector.<Number>(4, true);
		
		private static const SEGMENT_CURVE_TYPE:qb2F_GeoCurveType = qb2F_GeoCurveType.IS_TESSELLATED.or(qb2F_GeoCurveType.IS_BOUNDED);
		
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		private static const s_utilVector2:qb2GeoVector = new qb2GeoVector();
		
		private var m_lineType:qb2E_GeoLineType = qb2E_GeoLineType.SEGMENT;

		private const m_pointA:qb2GeoPoint = new qb2GeoPoint();
		private const m_pointB:qb2GeoPoint = new qb2GeoPoint();

		public function qb2GeoLine(pointA_copied_nullable:qb2GeoPoint = null, pointB_copied_nullable:qb2GeoPoint = null, lineType_nullable:qb2E_GeoLineType = null)
		{
			init(pointA_copied_nullable, pointB_copied_nullable, lineType_nullable);
		}
		
		public override function getCurveType():qb2F_GeoCurveType
		{
			if ( m_lineType == qb2E_GeoLineType.SEGMENT )
			{
				return SEGMENT_CURVE_TYPE;
			}
			else
			{
				return null;
			}
		}
		
		private function init(pointA_copied_nullable:qb2GeoPoint, pointB_copied_nullable:qb2GeoPoint, lineType_nullable:qb2E_GeoLineType):void
		{
			set(pointA_copied_nullable, pointB_copied_nullable, lineType_nullable);
			
			this.addEventListenerToSubEntity(m_pointA, false);
			this.addEventListenerToSubEntity(m_pointB, false);
		}
		
		public function set(pointA_copied_nullable:qb2GeoPoint, pointB_copied_nullable:qb2GeoPoint, lineType_nullable:qb2E_GeoLineType = null):void
		{
			this.pushEventDispatchBlock();
			{
				m_pointA.copy(pointA_copied_nullable);
				m_pointB.copy(pointB_copied_nullable);
				setLineType(lineType_nullable);
			}
			this.popEventDispatchBlock();
		}
		
		public function calcYIntercept():Number
		{
			return m_pointA.getY() / (m_pointA.getX() * calcSlope());
		}
		
		public function calcSlope():Number
		{
			return (m_pointB.getY() - m_pointA.getY()) / (m_pointB.getX() - m_pointA.getX());
		}

		public function calcDirection(vector_out:qb2GeoVector, normalizeVector:Boolean):void
		{
			m_pointB.calcDelta(m_pointA, vector_out);
			
			if ( normalizeVector )
			{
				vector_out.normalize();
			}
		}
			
		public function getLineType():qb2E_GeoLineType
		{
			return m_lineType;
		}
		
		public function setLineType(lineType:qb2E_GeoLineType):void
		{
			var oldLineType:qb2E_GeoLineType = m_lineType;
			
			m_lineType = lineType != null ? lineType : qb2E_GeoLineType.SEGMENT;
			
			if ( oldLineType != m_lineType )
			{
				this.dispatchChangedEvent();
			}
		}

		protected override function copy_protected(otherObject:*):void
		{
			var otherLine:qb2GeoLine = otherObject as qb2GeoLine;
			
			if ( otherLine != null )
			{
				this.set(otherLine.getPointA(), otherLine.getPointB(), otherLine.getLineType());
			}
			else
			{
				var otherVector:qb2GeoVector = otherObject as qb2GeoVector;
				
				if ( otherVector != null )
				{
					this.getPointA().copy(qb2S_Math.ORIGIN);
					this.getPointB().copy(otherVector);
				}
				else
				{
					var otherPoint:qb2GeoPoint = otherObject as qb2GeoPoint;
					
					if ( otherPoint != null )
					{
						this.getPointA().copy(otherPoint);
						this.getPointB().copy(otherPoint);
					}
				}
			}
		}
		
		public function getPointA():qb2GeoPoint
		{
			return m_pointA;
		}
		
		public function getPointB():qb2GeoPoint
		{
			return m_pointB;
		}
		
		public override function calcPointAtParam(param:Number, point_out:qb2GeoPoint):void
		{
			point_out.copy(m_pointA);
			this.calcDirection(s_utilVector1, false);
			s_utilVector1.scaleByNumber(param);
			point_out.translateBy(s_utilVector1);
		}
		
		public override function calcParamAtPoint(pointOnCurve:qb2GeoPoint):Number
		{
			if ( m_lineType == qb2E_GeoLineType.INFINITE )  return Infinity;
			
			var point1Dist:Number = m_pointA.calcDistanceTo(pointOnCurve);
			this.calcDirection(s_utilVector1, /*normalize=*/false);
			pointOnCurve.calcDelta(m_pointA, s_utilVector2);
			var angleBtwn:Number = s_utilVector1.calcAbsoluteAngleTo(s_utilVector2);
			var distanceAlong:Number = 0;
			
			if ( angleBtwn <= Math.PI / 2 )
			{
				distanceAlong = Math.cos(angleBtwn) * point1Dist;
			}
			else
			{
				distanceAlong = -Math.cos(Math.PI - angleBtwn) * point1Dist;
			}
			
			return distanceAlong;
		}
		
		public override function calcSubcurve(startParam:Number, endParam:Number):qb2A_GeoCurve
		{
			var line:qb2GeoLine = new qb2GeoLine();
			
			this.calcPointAtParam(startParam, line.getPointA());
			this.calcPointAtParam(endParam, line.getPointB());
			
			return line;
		}
		
		public override function flip():void
		{
			this.pushEventDispatchBlock();
			
			s_utilPoint.copy(m_pointA);
			m_pointA.copy(m_pointB);
			m_pointB.copy(s_utilPoint);
			
			this.popEventDispatchBlock();
		}
		
		/*public override function splitAtPoints(splitPoints:Vector.<qb2GeoPoint>, fixedVector:Boolean = true):Vector.<qb2A_GeoCurve>
		{
			var toReturn:Vector.<qb2A_GeoCurve> = Vector.<qb2A_GeoCurve>(splitPoints.length + 1, fixedVector);
			
			var closestPoint:qb2GeoPoint = closestPointTo(splitPoints[0]);
			if ( lineType == qb2E_GeoLineType.INFINITE )
				toReturn[0] = new qb2GeoLine(closestPoint, closestPoint.clone().translate(this.direction.negate()), RAY);
			else if ( lineType == RAY || lineType ==qb2E_GeoLineType.SEGMENT )
				toReturn[0] = new qb2GeoLine(m_pointA, closestPoint,qb2E_GeoLineType.SEGMENT);
			
			for ( var i:int = 0; i < splitPoints.length-1; i++ )
			{
				toReturn[i + 1] = getSubcurve(splitPoints[i], splitPoints[i + 1]);
			}
			
			closestPoint = closestPointTo(splitPoints[splitPoints.length - 1]);
			if ( lineType == qb2E_GeoLineType.INFINITE || lineType == RAY )
				toReturn[toReturn.length-1] = new qb2GeoLine(closestPoint, closestPoint.clone().translate(this.direction), RAY);
			else if ( lineType ==qb2E_GeoLineType.SEGMENT )
				toReturn[toReturn.length-1] = new qb2GeoLine(closestPoint, m_pointB,qb2E_GeoLineType.SEGMENT);
			
			return toReturn;
		}
		
		public override function splitAtDists(distances:Vector.<Number>, fixedVector:Boolean = true):Vector.<qb2A_GeoCurve>
		{
			if ( lineType == qb2E_GeoLineType.INFINITE ) return new Vector.<qb2A_GeoCurve>(0, fixedVector);
			return super.splitAtDists(distances, fixedVector);
		}
		
		public override function splitAtDist(distance:Number, fixedVector:Boolean = true):Vector.<qb2A_GeoCurve>
		{
			if ( lineType == qb2E_GeoLineType.INFINITE ) return new Vector.<qb2A_GeoCurve>(0, fixedVector);
			return super.splitAtDist(distance, fixedVector);
		}*/
		
		public override function calcIsLinear(line_out_nullable:qb2GeoLine = null, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			if ( line_out_nullable != null )
			{
				line_out_nullable.copy(this);
			}
			
			return true;
		}
		
		private function isZeroLength():Boolean
		{
			return m_pointA.isEqualTo(m_pointB, qb2GeoTolerance.EXACT);
		}
		
		public override function calcLength():Number
		{
			if ( isZeroLength() )  return 0;
			
			if ( m_lineType == qb2E_GeoLineType.SEGMENT )
			{
				var length:Number = m_pointA.calcDistanceTo(m_pointB);
				
				return length;
			}
			else
			{
				return Infinity;
			}
		}
		
		public function setLength(value:Number):void
		{
			if ( isZeroLength() ) return;
			
			m_pointB.calcDelta(m_pointA, s_utilVector1);
			s_utilVector1.setLength(value);
			m_pointB.copy(m_pointA);
			m_pointB.translateBy(s_utilVector1);
		}
		
		public function isParallelTo(line:qb2GeoLine, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			this.calcDirection(s_utilVector1, true);
			line.calcDirection(s_utilVector2, true);
			
			return s_utilVector1.isParallelTo(s_utilVector2, tolerance_nullable);
		}
			
		public function isPerpendicularTo(line:qb2GeoLine, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			this.calcDirection(s_utilVector1, true);
			line.calcDirection(s_utilVector2, true);
			
			return s_utilVector1.isPerpendicularTo(s_utilVector2, tolerance_nullable);
		}
			
		public function isCodirectionalTo(line:qb2GeoLine, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			this.calcDirection(s_utilVector1, true);
			line.calcDirection(s_utilVector2, true);
			
			return s_utilVector1.isCodirectionalTo(s_utilVector2, tolerance_nullable);
		}
	
		public function isAntidirectionalTo(line:qb2GeoLine, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			this.calcDirection(s_utilVector1, true);
			line.calcDirection(s_utilVector2, true);
			
			return s_utilVector1.isAntidirectionalTo(s_utilVector2, tolerance_nullable);
		}
		
		public override function calcNormalAtParam(param:Number, vector_out:qb2GeoVector, normalizeVector:Boolean):void
		{
			this.calcDirection(vector_out, normalizeVector);
		}
	
		public override function calcIsIntersecting(otherEntity:qb2A_GeoEntity, options_nullable:qb2GeoIntersectionOptions = null, result_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			if ( qb2U_Type.isKindOf(otherEntity, qb2GeoLine) )
			{
				return qb2U_GeoLineToLine.calcIsIntersecting(this, otherEntity as qb2GeoLine, options_nullable, result_out_nullable);
			}
			else if ( qb2U_Type.isKindOf(otherEntity, qb2I_GeoCircularEntity) )
			{
				return qb2U_GeoLineToCircle.calcIsIntersecting(this, otherEntity as qb2I_GeoCircularEntity, options_nullable, result_out_nullable);
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			}
			
			return false;
		}
		
		/**
		 * Determines if the two lines lie on the same imaginary infinite line.  This function doesn't care about overlap.
		 * 
		 * @param otherLine The other line to test against.
		 * @param radianTolerance The angular discrepancy that's allowed between the lines.
		 * @param isTouchingPointTolerance The distance the two lines can be apart. Specifically, how far this line's m_pointA point can be from an imaginary infinite line passing through otherLine.
		 * @param requireCodirectionality If true, the lines also have to be pointing in the same direction.
		 * @return Whether or not the lines are colinear.
		 */
		public function isColinearTo(otherLine:qb2GeoLine, tolerance_nullable:qb2GeoTolerance = null, requireCodirectionality:Boolean = false):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			if ( requireCodirectionality )
			{
				if ( !isCodirectionalTo(otherLine, tolerance_nullable) )  return false;
			}
			else
			{
				if ( !isParallelTo(otherLine, tolerance_nullable) )  return false;
			}
	
			var saveType:qb2E_GeoLineType = otherLine.getLineType();
			otherLine.setLineType(qb2E_GeoLineType.INFINITE);
			var toReturn:Boolean = otherLine.calcDistanceTo(m_pointA) <= tolerance_nullable.equalPoint;
			otherLine.setLineType(saveType);
			return toReturn;
		}
		
		/** Determines if this and otherLine are colinear and overlap each other. This is determined differently depending on the lineType's involved. For example, if both lines are segments,
		 * then one line must have one of its endpoints on the other.  However if both lines are infinite, then the only condition to be satisfied is colinearity.
		 * @param otherLine The other line to test against.
		 * @param radianTolerance The angular discrepancy that's allowed between the lines.
		 * @param isTouchingPointTolerance The distance the two lines can be apart. Specifically, how far this line's m_pointA point can be from an imaginary infinite line passing through otherLine.
		 * @param outputLine Optional output for the overlap found, if any. If non-null, outputLine is set with to the line representing the overlap. If no overlap is found, this line remains unchanged.
		 * Note that the outputLine's lineType can vary depending on the two lineType's tested.  Also, if the lineType of outputLine is set to either qb2E_GeoLineType.INFINITE or RAY, then the line's distance from m_pointA to m_pointB is set to 1.
		 * @return Whether or not the two lines overlap.
		 */		 
		/*public function isOverlappedBy(otherLine:qb2GeoLine, radianTolerance:Number = 0, isTouchingPointTolerance:Number = 0, outputLine:qb2GeoLine = null):Boolean
		{
			if ( !isColinearTo(otherLine, radianTolerance, isTouchingPointTolerance, false) )  return false;
			
			var tempLine:qb2GeoLine;
			
			if ( this.m_lineType == qb2E_GeoLineType.SEGMENT && otherLine.m_lineType == qb2E_GeoLineType.SEGMENT )
			{
				if ( otherLine.calcIsIntersecting(this.m_pointA, null, isTouchingPointTolerance) )
				{
					if ( otherLine.calcIsIntersecting(this.m_pointB, null, isTouchingPointTolerance) )
					{
						if ( outputLine )
						{
							outputLine.copy(this);
						}
						return true;
					}
					
					if ( this.isCodirectionalTo(otherLine, radianTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(this.m_pointA.clone() as qb2GeoPoint, otherLine.m_pointB.clone() as qb2GeoPoint, qb2E_GeoLineType.SEGMENT);
						}
						return true;
					}
					else
					{
						if ( outputLine )
						{
							outputLine.set(this.m_pointA.clone() as qb2GeoPoint, otherLine.m_pointA.clone() as qb2GeoPoint, qb2E_GeoLineType.SEGMENT);
						}
						return true;
					}
				}
				else if ( otherLine.calcIsIntersecting(this.m_pointB, null, isTouchingPointTolerance) )
				{
					if ( this.isCodirectionalTo(otherLine, radianTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(otherLine.m_pointA, this.m_pointB.clone(), qb2E_GeoLineType.SEGMENT);
						}
						return true;
					}
					else
					{
						if ( outputLine )
						{
							outputLine.set(this.m_pointB, otherLine.m_pointB, qb2E_GeoLineType.SEGMENT);
						}
						return true;
					}
				}
				else if ( this.isTouchingPoint(otherLine.m_pointA, isTouchingPointTolerance) )
				{
					if ( outputLine )
					{
						outputLine.set(otherLine.m_pointA, otherLine.m_pointB, qb2E_GeoLineType.SEGMENT);
					}
					return true;
				}
			}
			if ( this.m_lineType == qb2E_GeoLineType.INFINITE && otherLine.m_lineType == qb2E_GeoLineType.INFINITE )
			{
				if ( outputLine )
				{
					outputLine.set(m_pointA, m_pointB, qb2E_GeoLineType.INFINITE);
					outputLine.length = 1;
				}
				return true;
			}
			if ( this.m_lineType == qb2E_GeoLineType.RAY && otherLine.m_lineType == qb2E_GeoLineType.RAY )
			{
				if ( this.isCodirectionalTo(otherLine, radianTolerance) )
				{
					if ( otherLine.isTouchingPoint(this.m_pointA, isTouchingPointTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(m_pointA, m_pointB, qb2E_GeoLineType.RAY);
							outputLine.length = 1;
						}
						return true;
					}
					if ( this.isTouchingPoint(otherLine.m_pointA, isTouchingPointTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(otherLine.m_pointA, otherLine.m_pointB, qb2E_GeoLineType.RAY);
							outputLine.length = 1;
						}
						return true;
					}
				}
				else
				{
					if ( otherLine.isTouchingPoint(this.m_pointA, isTouchingPointTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(this.m_pointA, otherLine.m_pointA, qb2E_GeoLineType.SEGMENT);
						}
						return true;
					}
				}
			}
			if ( this.m_lineType == qb2E_GeoLineType.INFINITE && otherLine.m_lineType == qb2E_GeoLineType.RAY || this.m_lineType == qb2E_GeoLineType.RAY && otherLine.m_lineType == qb2E_GeoLineType.INFINITE )
			{
				tempLine = this.m_lineType == qb2E_GeoLineType.RAY ? this : otherLine;
				
				if ( outputLine )
				{
					outputLine.set(tempLine.m_pointA, tempLine.m_pointB, qb2E_GeoLineType.RAY);
					outputLine.setLength(1);
				}
				return true;
			}
			if ( this.m_lineType == qb2E_GeoLineType.INFINITE && otherLine.m_lineType == qb2E_GeoLineType.SEGMENT || this.m_lineType == qb2E_GeoLineType.SEGMENT && otherLine.m_lineType == qb2E_GeoLineType.INFINITE )
			{
				tempLine = this.lineType == qb2E_GeoLineType.SEGMENT ? this : otherLine;
				
				if ( outputLine )
				{
					outputLine.set(tempLine.m_pointA, tempLine.m_pointB, qb2E_GeoLineType.SEGMENT);
				}
				return true;
			}
			if ( this.m_lineType == qb2E_GeoLineType.RAY && otherLine.m_lineType == qb2E_GeoLineType.SEGMENT || this.m_lineType == qb2E_GeoLineType.SEGMENT && otherLine.m_lineType == qb2E_GeoLineType.RAY )
			{
				var ray:qb2GeoLine = this.m_lineType == qb2E_GeoLineType.RAY ? this : otherLine;
				var seg:qb2GeoLine = this.m_lineType == qb2E_GeoLineType.SEGMENT ? this : otherLine;
				
				if ( ray.isTouchingPoint(seg.m_pointA, isTouchingPointTolerance) )
				{
					if ( ray.isTouchingPoint(seg.m_pointB, isTouchingPointTolerance) )
					{
						if ( outputLine )
						{
							outputLine.copy(seg);
						}
					}
					else
					{
						if ( outputLine )
						{
							outputLine.set(ray.m_pointA, seg.m_pointA,qb2E_GeoLineType.SEGMENT);
						}
					}
					
					return true;
				}
				else if ( ray.isTouchingPoint(seg.m_pointB, isTouchingPointTolerance) )
				{
					if ( outputLine )
					{
						outputLine.set(ray.m_pointA, seg.m_pointB,qb2E_GeoLineType.SEGMENT);
					}
					return true;
				}
			}
			
			return false;
		}*/

		//--- Assuming that you have two lines, with the first's end point overlapping the second's m_pointA point,
		//--- this function finds the line that would split the angle between them. Think of it as if the two lines
		//--- represent pipes of 'diqb2Geo' diqb2Geoeter. The returned line represents the "elbow joint" between the two pipes.
		public function calcBisector(other:qb2GeoLine, diam:Number, limit:Number):qb2GeoLine
		{
			//--- Determine the angle between two lines using some simple trigonometry.
			var a:Number = this.m_pointA.calcDistanceTo(other.m_pointB),
				b:Number = this.calcLength(),
				c:Number = other.calcLength(),
				val:Number = .5 * ( (a * a - b * b - c * c) / (b * c) );
			if ( val > 1 )
				val = 1;
			else if ( val < -1 )
				val = -1;
				
			var alpha:Number = Math.PI - Math.acos(val);
			var finalDiam:Number = diam / Math.sin(alpha / 2.0);
			if ( finalDiam > limit)
				finalDiam = limit;
			
			var translater:qb2GeoVector = new qb2GeoVector();  this.calcDirection(translater, true);
			translater.scaleByNumber(.1);
			translater.negate();
			var backPoint:qb2GeoPoint  = this.m_pointB.clone();
			backPoint.translateBy(translater) as qb2GeoPoint;
			var translater2:qb2GeoVector = new qb2GeoVector();  other.calcDirection(translater2, true);
			translater2.scaleByNumber(.1);
			var frontPoint:qb2GeoPoint = this.m_pointB.clone();
			frontPoint.translateBy(translater2) as qb2GeoPoint;
			var normal:qb2GeoVector    = (frontPoint.minus(backPoint));
			normal.normalize();

			var cross:qb2GeoVector = new qb2GeoVector();
			normal.calcPerpVector(qb2E_PerpVectorDirection.RIGHT, cross);
			cross.scaleByNumber(finalDiam / 2);
			var pnt1:qb2GeoPoint = this.m_pointB.clone() as qb2GeoPoint;
			pnt1.translateBy(cross);
			
			cross.negate();
			var pnt2:qb2GeoPoint = this.m_pointB.clone() as qb2GeoPoint;
			pnt2.translateBy(cross);
			
			return new qb2GeoLine(pnt1, pnt2);
		}

		//--- Draws this line to the given graphics object.
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			/*if ( endPointSize )
			{
				if ( m_lineType ==qb2E_GeoLineType.SEGMENT )
				{
					m_pointA.draw(graphics, endPointSize);
					m_pointB.draw(graphics, endPointSize);
				}
				else if ( m_lineType == qb2E_GeoLineType.RAY )
				{
					m_pointA.draw(graphics, endPointSize);
					m_pointB.drawAsArrow(graphics, direction, endPointSize);
				}
				else if ( lineType == qb2E_GeoLineType.INFINITE )
				{
					m_pointA.drawAsArrow(graphics, direction.negate(), endPointSize);
					m_pointB.drawAsArrow(graphics, direction, endPointSize);
				}
			}*/
			
			var infinite:Number = 10000; // TODO get this from style sheet somehow.
			
			var drawBeg:qb2GeoPoint, drawEnd:qb2GeoPoint;
			if ( m_lineType == qb2E_GeoLineType.SEGMENT )
			{
				drawBeg = m_pointA;  drawEnd = m_pointB;
			}
			else if ( m_lineType == qb2E_GeoLineType.RAY )
			{
				drawBeg = m_pointA;
				
				var translater:qb2GeoVector = new qb2GeoVector()
				this.calcDirection(translater, true);
				translater.scaleByNumber(infinite);
				drawEnd = m_pointB.clone();
				drawEnd.translateBy(translater);
			}
			else if ( m_lineType == qb2E_GeoLineType.INFINITE )
			{
				translater = new qb2GeoVector()
				this.calcDirection(translater, true);
				translater.scaleByNumber(-infinite);
				drawBeg = m_pointA.clone() as qb2GeoPoint;
				drawBeg.translateBy(translater);
				translater.negate();
				drawEnd = m_pointB.clone() as qb2GeoPoint;
				drawEnd.translateBy(translater);
			}
			
			if ( drawBeg )
			{
				graphics.drawLine(drawBeg, drawEnd);
			}
		}
		
		protected override function nextDecomposition(progress:int):qb2A_GeoEntity
		{
			if ( progress == 0 )
			{
				return m_pointA;
			}
			else if ( progress == 1 )
			{
				return m_pointB;
			}
			
			return null;
		}
		
		protected override function nextGeometry(progress:int, T_extends_qb2A_Entity:Class, progressOffset_out:qb2Integer):qb2A_GeoEntity
		{
			if ( qb2U_Type.isKindOf(T_extends_qb2A_Entity, qb2GeoPoint) )
			{
				return this.nextDecomposition(progress);
			}
			
			return null;
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			this.calcPointAtParam(.5, point_out);
		}
		
		protected override function calcSimpleMomentOfInertia(mass:Number, curveThickness:Number = 0):Number
		{
			var length2ed:Number = m_pointA.calcDistanceSquaredTo(m_pointB);
			
			return qb2U_MomentOfInertia.line(mass, length2ed);
		}

		/*public override function convertTo(T:Class):*
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this, "pointA", m_pointA, "pointB", m_pointB, "lineType", m_lineType);
			}
			else if ( qb2U_Type.isKindOf(T, qb2GeoPolyline) )
			{
				var polyline:qb2GeoPolyline = qb2Class.getInstance(T).newInstance();
				polyline.addPoints(m_pointA.clone(), m_pointB.clone());
				
				return polyline;
			}
			else if ( qb2U_Type.isKindOf(T, qb2GeoCompositeCurve) )
			{
				var compositeCurve:qb2GeoCompositeCurve = qb2Class.getInstance(T).newInstance();
				compositeCurve.addCurve(this.clone() as qb2A_GeoCurve);
				
				return compositeCurve;
			}
			
			return super.convertTo(T);
		}*/
		
		public function getPointAt(index:int):qb2GeoPoint 
		{
			switch(index)
			{
				case 0: return m_pointA;
				case 1: return m_pointB;
			}
			
			return null;
		}
		
		public function getPointCount():int 
		{
			return 2;
		}
	}
}