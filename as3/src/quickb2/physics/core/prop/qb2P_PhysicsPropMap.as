package quickb2.physics.core.prop 
{
	import quickb2.display.retained.qb2I_Actor;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2MutablePropMap;
	import quickb2.utils.prop.qb2Prop;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2P_PhysicsPropMap extends qb2MutablePropMap
	{
		public function qb2P_PhysicsPropMap() 
		{
			
		}
		
		private function setProperty_contract(property:qb2Prop):void
		{
			if ( !qb2U_Type.isKindOf(property, qb2PhysicsProp) )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE, "Expected a type of qb2S_PhysicsProps.");
			}
		}
		
		private static function value_contract(property:qb2PhysicsProp, value:*):void
		{
			if ( value == null )  return;
			
			if ( property.getType() == qb2E_PropType.OBJECT )
			{
				if ( property == qb2S_PhysicsProps.ATTACHMENT_A || property == qb2S_PhysicsProps.ATTACHMENT_B )
				{
					if ( !(value is String) && !qb2U_Type.isKindOf(value, property.getExpectedType()) )
					{
						qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE, "Expected a type of "+property.getExpectedType()+" or String.");
					}
				}
				else
				{
					if ( !qb2U_Type.isKindOf(value, property.getExpectedType()) )
					{
						qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE, "Expected a type of "+property.getExpectedType()+".");
					}
				}
			}
		}
		
		private static function enum_contract(property:qb2PhysicsProp, value:*):void
		{
			if ( value == null )  return;
			
			if ( property.expectsLengthUnit() )
			{
				if ( !qb2U_Type.isKindOf(value, qb2E_LengthUnit) )
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE, "Expected a type of "+qb2E_LengthUnit+".");
				}
			}
		}
		
		private function setMassOrDensity_contract(value:*):void
		{
			if ( !qb2U_Type.isNumeric(value) )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected a numeric type.");
			}
			
			var valueAsNumber:Number = value as Number;
			
			if ( valueAsNumber < 0 || isNaN(valueAsNumber) || !isFinite(value) )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected positive, finite numberic type.");
			}
		}
		
		public override function setProperty(property:qb2Prop, value:*):void
		{
			setProperty_contract(property);
			value_contract(property as qb2PhysicsProp, value);
			enum_contract(property as qb2PhysicsProp, value);
			
			if ( value != null )
			{
				if ( property == qb2S_PhysicsProps.MASS )
				{
					setMassOrDensity_contract(value);
					
					super.setProperty(qb2S_PhysicsProps.DENSITY, null);
				}
				else if ( property == qb2S_PhysicsProps.DENSITY )
				{
					setMassOrDensity_contract(value);
					
					super.setProperty(qb2S_PhysicsProps.MASS, null);
				}
			}
			
			super.setProperty(property, value);
		}
		
		public override function getProperty(property:qb2Prop):*
		{
			var value:* = super.getProperty(property);
			
			return qb2PU_PhysicsProp.transformValue(property, value);
		}
		
		public override function getPropertyOrDefault(property:qb2Prop):*
		{
			var value:* = super.getPropertyOrDefault(property);
			
			return qb2PU_PhysicsProp.transformValue(property, value);
		}
	}
}