package quickb2.math.geo 
{
	import adobe.utils.CustomActions;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2E_PerpVectorDirection;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2GeoCircle;
	import quickb2.math.qb2S_Math;
	import quickb2.math.qb2U_Math;
	import quickb2.utils.primitives.qb2Float;
	
	/**
	 * Convenience functions for circular entities to cut down on boiler-plate code.
	 */
	public class qb2PU_Circle extends qb2UtilityClass
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector:qb2GeoVector = new qb2GeoVector();
		
		private static const s_utilFloat:qb2Float = new qb2Float();
		
		public static function calcCircleStartPoint(center:qb2GeoPoint, radius:Number, point_out:qb2GeoPoint):void
		{
			if ( qb2S_Math.FLIPPED_Y )
			{
				point_out.set(center.getX(), center.getY()-radius, 0);
			}
			else
			{
				point_out.set(center.getX(), center.getY() + radius, 0);
			}
		}
		
		public static function copy(source:*, destination:qb2I_GeoCircularEntity):void
		{
			var destinationAsEntity:qb2A_GeoEntity = destination as qb2A_GeoEntity;
			
			if ( qb2U_Type.isKindOf(source, qb2GeoPoint) )
			{
				destinationAsEntity.pushEventDispatchBlock();
				{
					destination.getCenter().copy(source);
					destination.setRadius(0);
				}
				destinationAsEntity.popEventDispatchBlock();
			}
			else if ( qb2U_Type.isKindOf(source, qb2I_GeoCircularEntity) )
			{
				var sourceAsCircle:qb2I_GeoCircularEntity = source as qb2I_GeoCircularEntity;
				
				destinationAsEntity.pushEventDispatchBlock();
				{
					destination.getCenter().copy(sourceAsCircle.getCenter());
					destination.setRadius(sourceAsCircle.getRadius());
				}
				destinationAsEntity.popEventDispatchBlock();
			}
		}
		
		public static function isEqualTo(circle:qb2I_GeoCircularEntity, otherEntity:*, tolerance_nullable:qb2GeoTolerance):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			if ( qb2U_Type.isKindOf(otherEntity, qb2GeoPoint) )
			{
				return circle.getCenter().isEqualTo(otherEntity, tolerance_nullable) && qb2U_Math.equals(circle.getRadius(), 0, tolerance_nullable.equalComponent);
			}
			else if ( qb2U_Type.isKindOf(otherEntity, qb2I_GeoCircularEntity) )
			{
				var entityAsCircle:qb2I_GeoCircularEntity = otherEntity as qb2I_GeoCircularEntity;
				
				return circle.getCenter().isEqualTo(entityAsCircle.getCenter(), tolerance_nullable) && qb2U_Math.equals(circle.getRadius(), entityAsCircle.getRadius(), tolerance_nullable.equalComponent);
			}
			else if ( qb2U_Type.isKindOf(otherEntity, qb2I_GeoEllipticalEntity) )
			{
				var entityAsEllipse:qb2I_GeoEllipticalEntity = otherEntity as qb2I_GeoEllipticalEntity;
				
				var centersEqual:Boolean = entityAsEllipse.getCenter().isEqualTo(circle.getCenter(), tolerance_nullable);
				var majorEqual:Boolean = qb2U_Math.equals(entityAsEllipse.getMajorAxis().calcLength(), circle.getRadius(), tolerance_nullable.equalComponent);
				var minorEqual:Boolean = qb2U_Math.equals(entityAsEllipse.getMinorAxis(), circle.getRadius(), tolerance_nullable.equalComponent);
				
				return centersEqual && majorEqual && minorEqual;
			}
			
			return false;
		}
		
		public static function calcNormalAtParam(circle:qb2A_GeoCurve, circleCenter:qb2GeoPoint, param:Number, vector_out:qb2GeoVector, flipped:Boolean, normalizeVector:Boolean):void
		{
			circle.calcPointAtParam(param, s_utilPoint1);
			s_utilPoint1.calcDelta(circleCenter, vector_out);
			
			if ( flipped )
			{
				vector_out.setToPerpVector(qb2E_PerpVectorDirection.LEFT);
			}
			else
			{
				vector_out.setToPerpVector(qb2E_PerpVectorDirection.RIGHT);
			}
			
			if ( normalizeVector )
			{
				vector_out.normalize();
			}
		}
		
		public static function calcIsIntersecting(circle:qb2A_GeoEntity, otherEntity:qb2A_GeoEntity, options_nullable:qb2GeoIntersectionOptions = null, output_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			var tolerance:qb2GeoTolerance = qb2GeoIntersectionOptions.getDefaultTolerance(options_nullable);
			
			var radius:Number = 0;
			if ( getCircleInfo(circle, s_utilPoint1, s_utilFloat) )
			{
				radius = s_utilFloat.value;
			}
			else
			{
				return false;
			}
			
			if ( getCircleInfo(otherEntity, s_utilPoint2, s_utilFloat) )
			{
				var otherRadius:Number = s_utilFloat.value;
				
				s_utilPoint1.calcDelta(s_utilPoint2, s_utilVector);
				
				var distance:Number = s_utilVector.calcLength();
				
				if ( distance <= (radius + otherRadius + tolerance.equalPoint) )
				{
					return true;
				}
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			}
			
			return false;
		}
		
		private static function getCircleInfo(circle:qb2A_GeoEntity, center_out:qb2GeoPoint, radius_out:qb2Float):Boolean
		{
			if ( qb2U_Type.isKindOf(circle, qb2GeoPoint) )
			{
				center_out.copy(circle);
				radius_out.value = 0;
				
				return true;
			}
			else if( qb2U_Type.isKindOf(circle, qb2I_GeoCircularEntity) )
			{
				radius_out.value = (circle as qb2I_GeoCircularEntity).getRadius();	
				center_out.copy((circle as qb2I_GeoCircularEntity).getCenter());
				
				return true;
			}
			
			return false;
		}
		
		public static function convertTo(circle:qb2I_GeoCircularEntity, T:Class):*
		{
			if ( T === String )
			{
				qb2U_ToString.auto(circle, "center", circle.getCenter(), "radius", circle.getRadius());
			}
			else if ( qb2U_Type.isKindOf(T, qb2I_GeoEllipticalEntity) || qb2U_Type.isKindOf(T, qb2I_GeoCircularEntity) )
			{
				var entity:* = qb2Class.getInstance(T).newInstance();
				
				entity.copy(circle);
				
				return entity;
			}
			
			return null;
		}
	}
}