package quickb2.math.geo 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2PrivateUtilityClass;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.qb2U_MassFormula;
	/**
	 * ...
	 * @author 
	 */
	public class qb2PU_Geo extends qb2PrivateUtilityClass
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		
		public static function calcMomentOfIntertia2d_contract(axis_nullable:qb2I_GeoHyperAxis):void
		{
			if ( axis_nullable != null )
			{
				if ( !qb2U_Type.isKindOf(axis_nullable, qb2GeoPoint) )
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE, "Expected null or " + qb2GeoPoint + ".");
				}
			}
		}
		
		public static function calcMomentOfInertia2d(entity:qb2A_GeoEntity, centerOfMassInertia:Number, mass:Number, axis_nullable:qb2I_GeoHyperAxis, centerOfMass_out_nullable:qb2GeoPoint):Number
		{
			calcMomentOfIntertia2d_contract(axis_nullable);
			
			if ( axis_nullable == null )
			{
				if ( centerOfMass_out_nullable != null )
				{
					entity.calcCenterOfMass(centerOfMass_out_nullable);
				}
				
				return centerOfMassInertia;
			}
			else if ( qb2U_Type.isKindOf(axis_nullable, qb2GeoPoint) )
			{
				var axisAsPoint:qb2GeoPoint = axis_nullable as qb2GeoPoint;
				centerOfMass_out_nullable = centerOfMass_out_nullable == null ? s_utilPoint1 : centerOfMass_out_nullable;
				entity.calcCenterOfMass(centerOfMass_out_nullable);
				
				return qb2U_MassFormula.parallelAxisTheorem(centerOfMassInertia, mass, axisAsPoint.calcDistanceSquaredTo(centerOfMass_out_nullable));
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
				
				return NaN;
			}
		}
	}
}