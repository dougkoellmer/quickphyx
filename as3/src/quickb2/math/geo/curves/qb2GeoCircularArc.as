package quickb2.math.geo.curves 
{
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.coords.qb2E_PerpVectorDirection;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2PU_Circle;
	import quickb2.math.qb2S_Math;
	import quickb2.math.qb2U_Formula;
	/**
	 * ...
	 * @author 
	 */
	public class qb2GeoCircularArc extends qb2A_GeoCurve
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint3:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		
		private const m_center:qb2GeoPoint = new qb2GeoPoint();
		private var m_radius:Number = 0;
		private var m_startAngle:Number;
		private var m_endAngle:Number;
		
		public function qb2GeoCircularArc(center_copied_nullable:qb2GeoPoint = null, radius:Number = 0, startAngle:Number = 0, endAngle:Number = 0) 
		{
			this.set(center_copied_nullable, radius, startAngle, endAngle);
			
			this.init();
		}
		
		public function set(center_copied_nullable:qb2GeoPoint, radius:Number, startAngle:Number, endAngle:Number):void
		{
			m_radius = radius;
			m_startAngle = startAngle;
			m_endAngle = endAngle;
			
			if ( center_copied_nullable != null )
			{
				m_center.copy(center_copied_nullable);
			}
			else
			{
				this.dispatchChangedEvent();
			}
		}
		
		public override function getCurveType():qb2F_GeoCurveType
		{
			return qb2F_GeoCurveType.IS_BOUNDED;
		}
		
		private function init():void
		{
			this.addEventListenerToSubEntity(m_center, false);
		}
		
		public function getCenter():qb2GeoPoint
		{
			return m_center;
		}
		
		public function setCenter(x:Number, y:Number, z:Number = 0):void
		{
			m_center.set(x, y, z);
		}
		
		public function getRadius():Number
		{
			return m_radius;
		}
		
		public function setRadius(value:Number):void
		{
			m_radius = value;
			
			this.dispatchChangedEvent();
		}
		
		public function getStartAngle():Number
		{
			return m_startAngle;
		}
		
		public function setStartAngle(angle:Number):void
		{
			m_startAngle = angle;
			
			this.dispatchChangedEvent();
		}
		
		public function getEndAngle():Number
		{
			return m_endAngle;
		}
		
		public function setEndAngle(angle:Number):void
		{
			m_endAngle = angle;
			
			this.dispatchChangedEvent();
		}
		
		public function calcSignedAngleSweep():Number
		{
			return m_endAngle - m_startAngle;
		}
		
		public function calcAbsoluteAngleSweep():Number
		{
			if ( m_endAngle >= m_startAngle )
			{
				return m_endAngle - m_startAngle;
			}
			else
			{
				return m_startAngle - m_endAngle;
			}
		}
		
		public override function calcLength():Number
		{
			var circumference:Number = qb2U_Formula.circleCircumference(m_radius);
			var angleRatio:Number = this.calcAbsoluteAngleSweep() / qb2S_Math.TAU;
			
			return angleRatio * circumference;
		}
		
		public override function calcArea(startParam:Number, endParam:Number):Number
		{
			var angleSweep:Number = calcSignedAngleSweep();
			var startAngle:Number = m_startAngle + angleSweep * startParam;
			var endAngle:Number = m_startAngle + angleSweep * endParam;
			var area:Number = qb2U_Formula.circleSegmentArea(m_radius, Math.abs(endAngle - startAngle));
			
			return angleSweep < 0 ? -area : area;
		}
		
		public override function calcIsLinear(line_out_nullable:qb2GeoLine = null, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			return false;
		}
		
		public override function calcNormalAtParam(param:Number, vector_out:qb2GeoVector, normalizeVector:Boolean):void
		{
			qb2PU_Circle.calcNormalAtParam(this, m_center, param, vector_out, calcSignedAngleSweep() < 0, normalizeVector);
		}
		
		public override function calcPointAtParam(param:Number, point_out:qb2GeoPoint):void
		{
			qb2PU_Circle.calcCircleStartPoint(m_center, m_radius, point_out);
			
			var sweep:Number = calcSignedAngleSweep();
			var theta:Number = m_startAngle + sweep*param;
			
			point_out.rotateBy(theta, m_center);
		}
		
		public override function calcBoundingBall(ball_out:qb2GeoBoundingBall):void
		{
			var theta:Number = m_startAngle - m_endAngle;
			
			if ( theta >= qb2S_Math.PI )
			{
				ball_out.set(m_center, m_radius);
			}
			else
			{
				this.calcPointAtParam(0, s_utilPoint1);
				this.calcPointAtParam(1, s_utilPoint2);
				
				s_utilPoint1.calcMidwayPoint(s_utilPoint2, ball_out.getCenter());
				ball_out.setRadius(s_utilPoint1.calcDistanceTo(s_utilPoint2)/2);
			}
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
		
		public override function draw(graphics:qb2I_Graphics2d):void
		{
			var angleLeft:Number = calcSignedAngleSweep();
			var isFlipped:Boolean = angleLeft < 0;
			angleLeft = Math.abs(angleLeft);
			var currentAngle:Number = m_startAngle;
			
			if ( angleLeft <= 0 )  return;
			
			var startPoint:qb2GeoPoint = s_utilPoint1;
			var controlPoint:qb2GeoPoint = s_utilPoint2;
			var endPoint:qb2GeoPoint = s_utilPoint3;
			
			this.calcPointAtParam(0, startPoint);
			graphics.moveTo(startPoint);
			
			var increment:Number = qb2S_Math.RADIANS_45;
			
			while (angleLeft > 0 )
			{
				var currentSweep:Number = angleLeft % increment;
				currentSweep = currentSweep == 0 ? increment : currentSweep;
				
				var endAngle:Number;
				
				if ( isFlipped )
				{
					endAngle = currentAngle - currentSweep;
				}
				else
				{
					endAngle = currentAngle + currentSweep;
				}
				
				qb2PU_Circle.calcCircleStartPoint(m_center, m_radius, endPoint);
				endPoint.rotateBy(endAngle, m_center);
				startPoint.calcDelta(endPoint, s_utilVector1);
				var chordLengthDiv2:Number = s_utilVector1.calcLength() / 2;
				var arcHumpSize:Number = Math.tan(currentSweep / 2) * chordLengthDiv2;
				var distanceToChord:Number = Math.sqrt(m_radius * m_radius - chordLengthDiv2*chordLengthDiv2);
				var anchorDistance:Number = distanceToChord + arcHumpSize;
				controlPoint.copy(m_center);
				s_utilVector1.setToPerpVector(qb2E_PerpVectorDirection.RIGHT);
				s_utilVector1.setLength(anchorDistance);
				controlPoint.translateBy(s_utilVector1);
				graphics.drawQuadCurveTo(controlPoint, endPoint);
				
				currentAngle = endAngle;
				angleLeft -= currentSweep;
				startPoint.copy(endPoint);
			}
		}
		
		public override function convertTo(T:Class):*
		{
			//TODO: support conversion to ellipse.
			
			return super.convertTo(T);
		}
	}
}