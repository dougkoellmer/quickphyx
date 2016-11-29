package quickb2.thirdparty.box2d 
{
	import Box2DAS.Collision.Shapes.b2CircleShape;
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Collision.Shapes.b2Shape;
	import Box2DAS.Common.b2Vec2;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Fixture;
	import quickb2.debugging.logging.qb2I_LogWriter;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.utils.qb2U_Geom;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Box2dDraw extends qb2UtilityClass
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		
		public static function drawShapes(fixtures:Vector.<b2Fixture>, graphics:qb2I_Graphics2d, space:qb2A_PhysicsObject, pixelsPerMeter:Number):void
		{
			for ( var i:int = 0; i < fixtures.length; i++ )
			{
				var fixture:b2Fixture = fixtures[i];
				var shape:b2Shape = fixture.GetShape();
				
				switch(shape.GetType())
				{
					case b2Shape.e_polygon:
					{
						qb2U_Box2dDraw.drawPolygonShape(shape as b2PolygonShape, graphics, space, pixelsPerMeter);
						
						break;
					}
					
					case b2Shape.e_circle:
					{
						qb2U_Box2dDraw.drawCircleShape(shape as b2CircleShape, graphics, space, pixelsPerMeter);
						
						break;
					}
					
					default:
					{
						break;
					}
				}
			}
		}
		
		public static function drawCircleShape(circle:b2CircleShape, graphics:qb2I_Graphics2d, space:qb2A_PhysicsObject, pixelsPerMeter:Number):void
		{
			graphics.getTransformStack().pushAndSet(qb2S_Math.IDENTITY_MATRIX);
			
			var center:b2Vec2 = circle.m_p;
			s_utilPoint1.set(center.x, center.y);
			s_utilPoint1.scaleByNumber(pixelsPerMeter);			
			qb2U_Geom.calcGlobalPoint(space, s_utilPoint1, s_utilPoint1, null);
			
			graphics.drawCircle(s_utilPoint1, circle.m_radius * pixelsPerMeter);
			
			graphics.getTransformStack().pop();
		}
		
		public static function drawPolygonShape(polygon:b2PolygonShape, graphics:qb2I_Graphics2d, space:qb2A_PhysicsObject, pixelsPerMeter:Number):void
		{			
			graphics.getTransformStack().pushAndSet(qb2S_Math.IDENTITY_MATRIX);
			
			for ( var i:int = 0; i < polygon.GetVertexCount(); i++ )
			{
				var vertex:V2 = polygon.GetVertex(i);
				s_utilPoint1.set(vertex.x, vertex.y);
				s_utilPoint1.scaleByNumber(pixelsPerMeter);
				
				qb2U_Geom.calcGlobalPoint(space, s_utilPoint1, s_utilPoint1, null);
				
				if ( i == 0 )
				{
					graphics.moveTo(s_utilPoint1);
				}
				else
				{
					graphics.drawLineTo(s_utilPoint1);
				}
			}
			
			graphics.getTransformStack().pop();
		}
	}

}