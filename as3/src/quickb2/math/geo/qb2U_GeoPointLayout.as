package quickb2.math.geo 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_GeoPointLayout 
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		
		private static function setUtilPoint(point_nullable:qb2GeoPoint, point_out:qb2GeoPoint):void
		{
			if ( point_nullable == null )
			{
				point_out.zeroOut();
			}
			else
			{
				point_out.copy(point_nullable);
			}
		}
		
		public static function createRegularPolygon(center_nullable:qb2GeoPoint, radius:Number, sideCount:int, container_out:qb2I_GeoPointContainer):void
		{
			setUtilPoint(center_nullable, s_utilPoint1);
			setUtilPoint(center_nullable, s_utilPoint2);
			
			s_utilPoint2.incY( -radius);
			var inc:Number = (Math.PI * 2) / (sideCount as Number);
			
			for ( var i:int = 0; i < sideCount; i++ )
			{
				s_utilPoint2.rotateBy(inc*i, s_utilPoint1);
				
				container_out.addPoint(s_utilPoint2.clone() as qb2GeoPoint);
			}
		}
		
		public static function createIsoscelesTriangle(bottomCenter_nullable:qb2GeoPoint, baseWidth:Number, height:Number, container_out:qb2I_GeoPointContainer):void
		{
			setUtilPoint(bottomCenter_nullable, s_utilPoint1);
			
			container_out.addPoint(new qb2GeoPoint(s_utilPoint1.getX() - baseWidth / 2, s_utilPoint1.getY()));
			container_out.addPoint(new qb2GeoPoint(s_utilPoint1.getX(), s_utilPoint1.getY() - height));
			container_out.addPoint(new qb2GeoPoint(s_utilPoint1.getX() + baseWidth / 2, s_utilPoint1.getY()));
		}
		
		public static function createRectangle(center_nullable:qb2GeoPoint, width:Number, height:Number, container_out:qb2I_GeoPointContainer):void
		{
			setUtilPoint(center_nullable, s_utilPoint1);
			
			s_utilPoint1.incX( -width / 2);
			s_utilPoint1.incY( -height / 2);
			container_out.addPoint(s_utilPoint1.clone());
			s_utilPoint1.incX(width);
			container_out.addPoint(s_utilPoint1.clone());
			s_utilPoint1.incY(height);
			container_out.addPoint(s_utilPoint1.clone());
			s_utilPoint1.incX( -width);
			container_out.addPoint(s_utilPoint1.clone());
		}
	}
}