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
	public class qb2U_GeoLineToCircle extends qb2UtilityClass
	{
		public static const POINT_COUNT:int = 0;
		public static const PARAM_0:int = 1;
		public static const PARAM_1:int = 2;
		
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		private static const s_utilVector2:qb2GeoVector = new qb2GeoVector();
		
		private static const s_values:Vector.<Number> = new Vector.<Number>();
		
		public static function helper(line:qb2GeoLine, circle:qb2I_GeoCircularEntity, tol:Number):Vector.<Number>
		{
			var lineCircleDelta:qb2GeoVector = s_utilVector1;
			var lineDirection:qb2GeoVector = s_utilVector2;
			var lineMidpoint:qb2GeoPoint = s_utilPoint1;
			
			var circleRadius:Number = circle.getRadius();
			line.calcDirection(lineDirection, true);
			line.calcPointAtParam(.5, lineMidpoint);
			lineMidpoint.calcDelta(circle.getCenter(), lineCircleDelta);
			
			var a0:Number = lineCircleDelta.calcLengthSquared() - circleRadius * circleRadius;
			var a1:Number = lineDirection.calcDotProduct(lineCircleDelta);
			var discriminant:Number = a1 * a1 - a0;
			
			if ( discriminant > tol )
			{
				s_values[POINT_COUNT] = 2;
				discriminant = Math.sqrt(discriminant);
				s_values[PARAM_0] = -a1 - discriminant;
				s_values[PARAM_1] = -a1 + discriminant;
			}
			else if ( discriminant < -tol )
			{
				s_values[POINT_COUNT] = 0;
			}
			else
			{
				s_values[POINT_COUNT] = 1;
				s_values[PARAM_0] = -a1;
			}
			
			return s_values;;
		}
		
		public static function calcIsIntersecting(line:qb2GeoLine, circle:qb2I_GeoCircularEntity, options_nullable:qb2GeoIntersectionOptions = null, result_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			var tolerance:qb2GeoTolerance = qb2GeoIntersectionOptions.getDefaultTolerance(options_nullable);
			var intersectionTolerance:Number = tolerance.equalComponent;
			
			var values:Vector.<Number> = helper(line, circle, intersectionTolerance);
			
			var lineType:qb2E_GeoLineType = line.getLineType();
	
			var numIntPoints:int = values[POINT_COUNT];
			var param0:Number = values[PARAM_0];
			var param1:Number = values[PARAM_1];
			
			if ( numIntPoints > 0 )
			{
				if ( lineType == qb2E_GeoLineType.INFINITE )
				{
					// nothing to do here.
				}
				else if ( lineType == qb2E_GeoLineType.RAY )
				{
					if (numIntPoints == 1)
					{
						if (param0 < 0.0 )
						{
							numIntPoints = 0;
						}
					}
					else
					{
						if (param1 < 0.0 )
						{
							numIntPoints = 0;
						}
						else if (param0 < 0.0 )
						{
							numIntPoints = 1;
							values[PARAM_0] = values[PARAM_1];
						}
					}
				}
				else if ( lineType == qb2E_GeoLineType.SEGMENT )
				{
					var halfLength:Number = line.calcLength() / 2;
					
					if (numIntPoints == 1)
					{
						if (Math.abs(param0) > halfLength )
						{
							numIntPoints = 0;
						}
					}
					else
					{
						if (param1 < -halfLength || param0 > halfLength )
						{
							numIntPoints = 0;
						}
						else
						{
							if (param1 <= halfLength )
							{
								if (param0 < -halfLength )
								{
									numIntPoints = 1;
									values[PARAM_0] = values[PARAM_1];
								}
							}
							else
							{
								numIntPoints = (param0 >= -halfLength ? 1 : 0);
							}
						}
					}
				}
			}
			
			var isIntersecting:Boolean = numIntPoints > 0;
			
			if ( isIntersecting && result_out_nullable != null )
			{
				for (var i:int = 0; i < numIntPoints; i++)
				{
					//var point:qb2GeoPoint = lineOrigin.translatedBy(lineDir.scaledBy(values[(POINT_COUNT+1) + i]));
					//point.setUserData(qb2E_GeoIntersectionFlags.CURVE_TO_CURVE);
					//outputIntersectionPoints.push(point);
				}
			}
			
			return isIntersecting;
		}
	}
}