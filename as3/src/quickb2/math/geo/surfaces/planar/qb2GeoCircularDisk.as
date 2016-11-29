package quickb2.math.geo.surfaces.planar 
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2GeoCircle;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoIntersectionOptions;
	import quickb2.math.geo.qb2GeoIntersectionResult;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoCircularEntity;
	import quickb2.math.geo.qb2PU_Circle;
	import quickb2.math.qb2U_Formula;
	import quickb2.math.qb2U_MomentOfInertia;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2GeoCircularDisk extends qb2A_GeoCurveBoundedPlane implements qb2I_GeoCircularEntity
	{
		public function qb2GeoCircularDisk(center_nullable:qb2GeoPoint = null, radius:Number = 0) 
		{
			var circle:qb2GeoCircle = new qb2GeoCircle(center_nullable, radius);
			
			super.setBoundary_protected(circle);
		}
		
		private function getCircle():qb2GeoCircle
		{
			return this.getBoundary() as qb2GeoCircle;
		}
		
		public function set(sourceCenter:qb2GeoPoint, radius:Number):void
		{
			getCircle().set(sourceCenter, radius);
		}
		
		public function getCenter():qb2GeoPoint
		{
			return getCircle().getCenter();
		}
		
		public function getRadius():Number
		{
			return getCircle().getRadius();
		}
		
		public function setRadius(radius:Number):void
		{
			getCircle().setRadius(radius);
		}
		
		public override function isEqualTo(entity:qb2A_GeoEntity, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			return qb2PU_Circle.isEqualTo(this.getCircle(), entity, tolerance_nullable);
		}
		
		public override function calcIsIntersecting(entity:qb2A_GeoEntity, options_nullable:qb2GeoIntersectionOptions = null, output:qb2GeoIntersectionResult = null):Boolean
		{
			return qb2PU_Circle.calcIsIntersecting(this, entity, options_nullable, output);
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			point_out.copy(getCenter());
		}
		
		protected override function calcSimpleMomentOfInertia(mass:Number):Number
		{
			return qb2U_MomentOfInertia.circularDisk(mass, this.getRadius());
		}
		
		protected override function copy_protected(source:*):void
		{
			qb2PU_Circle.copy(source, this.getCircle());
		}

		/*public override function convertTo(T:Class):*
		{
			var entity:* = qb2PU_Circle.convertTo(this, T);
				
			if ( entity != null )
			{
				return entity;
			}
			
			return super.convertTo(T);
		}*/
	}
}