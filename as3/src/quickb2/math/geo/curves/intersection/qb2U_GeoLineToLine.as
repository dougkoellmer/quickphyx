package quickb2.math.geo.curves.intersection 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2E_GeoLineType;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.qb2GeoIntersectionOptions;
	import quickb2.math.geo.qb2GeoIntersectionResult;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoCircularEntity;
	import quickb2.math.qb2U_Math;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_GeoLineToLine extends qb2UtilityClass
	{
		public static const NUME_A:int = 0;
		public static const NUME_B:int = 1;
		public static const UA:int = 2;
		public static const UB:int = 3;
		
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		private static const s_utilVector2:qb2GeoVector = new qb2GeoVector();
		
		private static const s_values:Vector.<Number> = new Vector.<Number>(4, true);
		
		private static function setValues(nume_a:Number, nume_b:Number, ua:Number, ub:Number, values_out:Vector.<Number>):void
		{
			values_out[NUME_A] = nume_a;
			values_out[NUME_B] = nume_a;
			values_out[UA] = ua;
			values_out[UB] = ub;
		}
		
		public static function calcIsIntersecting(line1:qb2GeoLine, line2:qb2GeoLine, options_nullable:qb2GeoIntersectionOptions = null, result_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			var tolerance:qb2GeoTolerance = qb2GeoIntersectionOptions.getDefaultTolerance(options_nullable);
			var intersectionTolerance:Number = tolerance.equalComponent;
			
			var values:Vector.<Number> = helper(line1, line2);
			
			var intersecting:Boolean = false;
			
			//TODO: Take ito account coincident case.
			
			var ua:Number = values[UA];
			var ub:Number = values[UB];
			
			if ( line1.getLineType() == qb2E_GeoLineType.SEGMENT && line2.getLineType() == qb2E_GeoLineType.SEGMENT && qb2U_Math.isWithin(ua, 0, 1, intersectionTolerance) && qb2U_Math.isWithin(ub, 0, 1, intersectionTolerance) )
				intersecting = true;
			else if ( line1.getLineType() == qb2E_GeoLineType.RAY && line2.getLineType() == qb2E_GeoLineType.SEGMENT && ua >= 0-intersectionTolerance && qb2U_Math.isWithin(ub, 0, 1, intersectionTolerance) )
				intersecting = true;
			else if ( line1.getLineType() == qb2E_GeoLineType.SEGMENT && line2.getLineType() == qb2E_GeoLineType.RAY && qb2U_Math.isWithin(ua, 0, 1, intersectionTolerance) && ub >= 0-intersectionTolerance )
				intersecting = true;
			else if ( line1.getLineType() == qb2E_GeoLineType.RAY && line2.getLineType() == qb2E_GeoLineType.RAY && ua >= 0-intersectionTolerance && ub >= 0-intersectionTolerance )
				intersecting = true;
			else if ( line1.getLineType() == qb2E_GeoLineType.SEGMENT && line2.getLineType() == qb2E_GeoLineType.INFINITE && qb2U_Math.isWithin(ua, 0, 1, intersectionTolerance) )
				intersecting = true;
			else if ( line1.getLineType() == qb2E_GeoLineType.INFINITE && line2.getLineType() == qb2E_GeoLineType.SEGMENT && qb2U_Math.isWithin(ub, 0, 1, intersectionTolerance) )
				intersecting = true;
			else if ( line1.getLineType() == qb2E_GeoLineType.RAY && line2.getLineType() == qb2E_GeoLineType.INFINITE && ua >= 0-intersectionTolerance )
				intersecting = true;
			else if ( line1.getLineType() == qb2E_GeoLineType.INFINITE && line2.getLineType() == qb2E_GeoLineType.RAY && ub >= 0-intersectionTolerance )
				intersecting = true;
			else if ( line1.getLineType() == qb2E_GeoLineType.INFINITE && line2.getLineType() == qb2E_GeoLineType.INFINITE && !line1.isParallelTo(line2, tolerance) )
				intersecting = true;
			
			if ( intersecting )
			{
				if ( result_out_nullable != null )
				{
					/*var outputPoint:qb2GeoPoint = output as qb2GeoPoint;
					var outputArray:Vector.<qb2GeoPoint> = output as Vector.<qb2GeoPoint>();
					if ( outputPoint )
					{
						outputPoint.set(this.m_point1.m_x + ua * (this.m_point2.m_x - this.m_point1.m_x), this.m_point1.m_y + ua * (this.m_point2.m_y - this.m_point1.m_y));
					}
					else if ( outputArray )
					{
						outputArray.push(new qb2GeoPoint(this.m_point1.m_x + ua * (this.m_point2.m_x - this.m_point1.m_x), this.m_point1.m_y + ua * (this.m_point2.m_y - this.m_point1.m_y)));
					}*/
				}
				
				return true;
			}
			
			return false;
		}
		
		public static function helper(line1:qb2GeoLine, line2:qb2GeoLine):Vector.<Number>
		{
			var denom:Number  = ((line2.getPointB().getY() - line2.getPointA().getY())*(line1.getPointB().getX() - line1.getPointA().getX())) -
                     			((line2.getPointB().getX() - line2.getPointA().getX())*(line1.getPointB().getY() - line1.getPointA().getY()));

			var nume_a:Number = ((line2.getPointB().getX() - line2.getPointA().getX())*(line1.getPointA().getY() - line2.getPointA().getY())) -
						   		((line2.getPointB().getY() - line2.getPointA().getY())*(line1.getPointA().getX() - line2.getPointA().getX()));
	
			var nume_b:Number = ((line1.getPointB().getX() - line1.getPointA().getX())*(line1.getPointA().getY() - line2.getPointA().getY())) -
						   		((line1.getPointB().getY() - line1.getPointA().getY())*(line1.getPointA().getX() - line2.getPointA().getX()));
	
			var ua:Number = 0;
			var ub:Number = 0;
			
			if( denom == 0.0)
			{
				if ( nume_a == 0.0 && nume_b == 0.0 )
				{
					setValues(nume_a, nume_b, 0, 0, s_values); // (coincident)
					
					return s_values;
				}
				
				setValues(nume_a, nume_b, 0, 0, s_values); // (parallel)
				
				return s_values;
			}
			else if ( isFinite(denom) )
			{
				ua = nume_a / denom;
				ub = nume_b / denom;
			}
			
			setValues(nume_a, nume_b, ua, ub, s_values);
			
			return s_values;
		}
	}
}