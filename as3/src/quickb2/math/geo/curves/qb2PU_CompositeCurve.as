package quickb2.math.geo.curves 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.qb2GeoTolerance;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2PU_CompositeCurve extends qb2UtilityClass
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilLine1:qb2GeoLine = new qb2GeoLine();
		private static const s_utilLine2:qb2GeoLine = new qb2GeoLine();
		
		public static function calcLength(curveIterator:qb2I_Iterator):Number
		{
			var length:Number = 0;
			
			for (var curve:qb2A_GeoCurve; (curve=curveIterator.next()) != null; )
			{
				length += curve.calcLength();
			}
			
			return length;
		}
		
		public static function calcIsLinear(curveIterator:qb2I_Iterator, line_out_nullable:qb2GeoLine = null, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			var isLinear:Boolean = true;
			
			var baseLine:qb2GeoLine = null;
			
			var lastCurve:qb2A_GeoCurve = null;
			
			for ( var curve:qb2A_GeoCurve; (curve = curveIterator.next()) != null; )
			{
				lastCurve = curve;
				
				if ( baseLine == null )
				{
					if ( curve.calcIsLinear(s_utilLine1, tolerance_nullable) == false )
					{
						isLinear = false;
						break;
					}
					else
					{
						baseLine = s_utilLine1;
						curve.calcPointAtParam(0, s_utilPoint1);
					}
				}
				else
				{
					if ( !curve.calcIsLinear(s_utilLine2, tolerance_nullable) || !s_utilLine2.isColinearTo(baseLine, tolerance_nullable, true) )
					{
						isLinear = false;
						break;
					}
				}
			}
			
			if ( lastCurve != null && isLinear && line_out_nullable != null)
			{
				line_out_nullable.getPointA().copy(s_utilPoint1);
				lastCurve.calcPointAtParam(1, line_out_nullable.getPointB());
			}
			
			return isLinear;
			
		}
		
		public static function calcPointAtDistance(curveIterator:qb2I_Iterator, distance:Number, point_out:qb2GeoPoint):void
		{
			var distLeft:Number = distance;
		
			var curve:qb2A_GeoCurve = null;
			var length:Number;
			for (; (curve = curveIterator.next()) != null; )
			{
				length = curve.calcLength();
				
				if (distLeft <= length)
				{
					curve.calcPointAtDistance(distLeft, point_out);
					
					return;
				}
				
				distLeft -= length;
			}
			
			if ( curve != null )
			{
				curve.calcPointAtDistance(length + distLeft, point_out);
			}
			else
			{
				point_out.zeroOut();
			}
		}
	}
}