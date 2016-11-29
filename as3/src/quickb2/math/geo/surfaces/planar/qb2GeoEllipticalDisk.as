package quickb2.math.geo.surfaces.planar 
{
	import quickb2.lang.*;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.operators.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoIntersectionOptions;
	import quickb2.math.geo.qb2GeoIntersectionResult;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2PU_Ellipse;
	import quickb2.math.geo.qb2U_Transform;
	
	import quickb2.math.*;
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2GeoCircle;
	import quickb2.math.geo.curves.qb2GeoEllipse;
	import quickb2.math.geo.qb2I_GeoEllipticalEntity;
	import quickb2.math.geo.surfaces.qb2A_GeoSurface;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	
	import quickb2.event.qb2Event;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2GeoEllipticalDisk extends qb2A_GeoCurveBoundedPlane implements qb2I_GeoEllipticalEntity
	{
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		
		public function qb2GeoEllipticalDisk(center_copied_nullable:qb2GeoPoint = null, majorAxis_copied_nullable:qb2GeoVector = null, minorAxis:Number = 0)
		{
			var ellipse:qb2GeoEllipse = new qb2GeoEllipse(center_copied_nullable, majorAxis_copied_nullable, minorAxis);
			
			super.setBoundary_protected(ellipse);
		}
		
		private function getEllipse():qb2GeoEllipse
		{
			return getBoundary() as qb2GeoEllipse;
		}
		
		public function set(center_nullable:qb2GeoPoint, majorAxis:qb2GeoVector, minorAxis:Number):void
		{
			getEllipse().set(center_nullable, majorAxis, minorAxis);
		}
		
		public function getMinorAxis():Number
		{
			return getEllipse().getMinorAxis();
		}
		
		public function setMinorAxis(minorAxis:Number):void
		{
			getEllipse().setMinorAxis(minorAxis);
		}
			
		public function getMajorAxis():qb2GeoVector
		{
			return getEllipse().getMajorAxis();
		}
		
		public function setMajorAxis(x:Number, y:Number, z:Number = 0):void
		{
			getEllipse().setMajorAxis(x, y, z);
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			point_out.copy(getCenter());
		}
		
		protected override function calcSimpleMomentOfInertia(mass:Number):Number
		{
			return qb2U_MomentOfInertia.ellipticalDisk(mass, this.getMajorAxis().calcLengthSquared(), this.getMinorAxis() * this.getMinorAxis());
		}
		
		public function getCenter():qb2GeoPoint
		{
			return getEllipse().getCenter();
		}
		
		public function setCenter(x:Number, y:Number, z:Number = 0):void
		{
			this.getCenter().set(x, y, z);
		}
		
		public override function calcIsIntersecting(otherEntity:qb2A_GeoEntity, options_nullable:qb2GeoIntersectionOptions = null, result_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			var tolerance:qb2GeoTolerance = qb2GeoIntersectionOptions.getDefaultTolerance(options_nullable);
			
			if ( qb2U_Type.isKindOf(otherEntity, qb2GeoPoint) )
			{
				qb2U_Transform.toWorldAligned(otherEntity, getCenter(), getMajorAxis(), s_utilPoint);
				var result:Number = qb2U_Formula.ellipse(getMajorAxis().calcLength(), getMinorAxis(), s_utilPoint.getX(), s_utilPoint.getY());
				
				return result <= 1;
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			}
			
			return false;
		}
		
		public override function isEqualTo(otherEntity:qb2A_GeoEntity, tolerance:qb2GeoTolerance = null):Boolean
		{
			return qb2PU_Ellipse.isEqualTo(this.getEllipse(), otherEntity, tolerance);
		}
		
		protected override function copy_protected(source:*):void
		{
			qb2PU_Ellipse.copy(source, this.getEllipse());
		}

		/*public override function convertTo(T:Class):*
		{
			var entity:* = qb2PU_Ellipse.convertTo(this, T);
			
			if ( entity != null )
			{
				return entity;
			}
			
			return super.convertTo(T);
		}*/
	}
}