package quickb2.math.geo 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.qb2S_Math;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Transform extends qb2UtilityClass
	{
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		
		public static function toWorldAligned(entity:qb2A_GeoEntity, entityOrigin:qb2GeoPoint, entityXAxis:qb2GeoVector, entity_out:qb2A_GeoEntity, worldOrigin_nullable:qb2GeoPoint = null, worldXAxis_nullable:qb2GeoVector = null):void
		{
			worldOrigin_nullable = worldOrigin_nullable != null ? worldOrigin_nullable : qb2S_Math.ORIGIN;
			worldXAxis_nullable = worldXAxis_nullable != null ? worldXAxis_nullable : qb2S_Math.X_AXIS;
			
			entity_out.copy(entity);
			
			var rotation:Number = entityXAxis.calcSignedAngleTo(worldXAxis_nullable);
			worldOrigin_nullable.calcDelta(entityOrigin, s_utilVector1);
			
			entity_out.translateBy(s_utilVector1, false);
			entity_out.rotateBy(rotation, worldOrigin_nullable);
		}
		
		public static function toEntityAligned(entity:qb2A_GeoEntity, entityOrigin:qb2GeoPoint, entityXAxis:qb2GeoVector, entity_out:qb2A_GeoEntity, worldOrigin_nullable:qb2GeoPoint = null, worldXAxis_nullable:qb2GeoVector = null):void
		{
			worldOrigin_nullable = worldOrigin_nullable != null ? worldOrigin_nullable : qb2S_Math.ORIGIN;
			worldXAxis_nullable = worldXAxis_nullable != null ? worldXAxis_nullable : qb2S_Math.X_AXIS;
			
			entity_out.copy(entity);
			
			var rotation:Number = worldXAxis_nullable.calcSignedAngleTo(entityXAxis);
			entityOrigin.calcDelta(worldOrigin_nullable, s_utilVector1);
			
			entity_out.rotateBy(rotation, worldOrigin_nullable);
			entity_out.translateBy(s_utilVector1, false);
		}
	}
}