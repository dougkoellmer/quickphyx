package quickb2.math.geo 
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.qb2U_Math;
	
	/**
	 * Convenience functions for circular entities to cut down on boiler-plate code.
	 */
	public class qb2PU_Ellipse extends qb2UtilityClass
	{
		public static function copy(source:*, destination:qb2I_GeoEllipticalEntity):void
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			
			/*if ( qb2U_Type.isKindOf(source, qb2GeoPoint) )
			{
				destination.pushDispatchingBlock();
				{
					destination.getCenter().copy(source);
					destination.setRadius(0);
				}
				destination.popDispatchingBlock();
			}
			else if ( qb2U_Type.isKindOf(source, qb2I_GeoEllipticalEntity) )
			{
				var sourceAsCircle:qb2I_GeoEllipticalEntity = otherObject as qb2I_GeoEllipticalEntity;
				
				destination.pushDispatchingBlock();
				{
					destination.getCenter().copy(sourceAsCircle.getCenter());
					destination.setRadius(sourceAsCircle.getRadius());
				}
				destination.popDispatchingBlock();
			}*/
		}
		
		public static function isEqualTo(ellipse:qb2I_GeoEllipticalEntity, otherEntity:*, tolerance:qb2GeoTolerance):Boolean
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			
			/*tolerance = tolerance != null ? tolerance : qb2GeoTolerance.DEFAULT;
			
			if ( qb2U_Type.isKindOf(otherEntity, qb2GeoPoint) )
			{
				return ellipse.getCenter().isEqualTo(otherEntity, tolerance) && qb2U_Math.equals(circle.getRadius(), 0, tolerance.equalComponent);
			}
			else if ( qb2U_Type.isKindOf(otherEntity, qb2I_GeoCircularEntity) )
			{
				var entityAsCircle:qb2I_GeoCircularEntity = otherEntity as qb2I_GeoCircularEntity;
				
				return circle.getCenter().isEqualTo(entityAsCircle.getCenter(), tolerance) && qb2U_Math.equals(circle.getRadius(), entityAsCircle.getRadius(), tolerance.equalComponent);
			}
			else if ( qb2U_Type.isKindOf(otherEntity, qb2I_GeoEllipticalEntity) )
			{
				var entityAsEllipse:qb2I_GeoEllipticalEntity = otherEntity as qb2I_GeoEllipticalEntity;
				
				var centersEqual:Boolean = entityAsEllipse.getCenter().isEqualTo(circle.getCenter(), tolerance);
				var majorEqual:Boolean = qb2U_Math.equals(entityAsEllipse.getMajorAxis().calcLength(), circle.getRadius(), tolerance.equalComponent);
				var minorEqual:Boolean = qb2U_Math.equals(entityAsEllipse.getMinorAxis(), circle.getRadius(), tolerance.equalComponent);
				
				return centersEqual && majorEqual && minorEqual;
			}*/
			
			return false;
		}
		
		
		
		public static function convertTo(ellipse:qb2I_GeoEllipticalEntity, T:Class):*
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(ellipse, "center", ellipse.getCenter(), "majorAxis", ellipse.getMajorAxis(), "minorAxis", ellipse.getMinorAxis());
			}
			else if ( qb2U_Type.isKindOf(T, qb2I_GeoEllipticalEntity) )
			{
				var entity:* = qb2Class.getInstance(T).newInstance();
				
				entity.copy(ellipse);
				
				return entity;
			}
			
			return null;
		}
	}
}