package quickb2.physics.core.prop 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.foundation.qb2PrivateUtilityClass;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.utils.prop.qb2E_SpecialPropValue;
	import quickb2.utils.prop.qb2Prop;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.prop.qb2PropValueSet;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2PU_PhysicsProp extends qb2PrivateUtilityClass
	{
		public static function isCoordProp(prop:qb2Prop, coordProp:qb2CoordProp):Boolean
		{
			return	prop == coordProp	||
					prop == coordProp.X	||
					prop == coordProp.Y	||
					prop == coordProp.Z	 ;
		}
		
		public static function copyCoordToValue(coord:qb2A_GeoCoordinate, value_out_nullable:*):Boolean
		{
			if ( value_out_nullable == null )  return false;
			
			if ( qb2U_Type.isKindOf(value_out_nullable, qb2A_GeoCoordinate) )
			{
				var valueAsCoord:qb2A_GeoCoordinate = value_out_nullable as qb2A_GeoCoordinate;
				valueAsCoord.copy(coord);
				
				return true;
			}
			else if ( qb2U_Type.isKindOf(value_out_nullable, qb2PropValueSet) )
			{
				qb2PU_PhysicsProp.copyCoordToValueSet(coord, value_out_nullable as qb2PropValueSet);
			}
			
			return false;
		}
		
		public static function transformValue(property:qb2Prop, value:*):*
		{
			var asPhysicsProperty:qb2PhysicsProp = property as qb2PhysicsProp;
			
			if ( asPhysicsProperty == null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected " + qb2PhysicsProp + ".");
			}
			
			if ( value == null )  return null;
			
			var ordinal:int;
			
			if ( asPhysicsProperty.expectsLengthUnit() )
			{
				//if ( !qb2U_Type.isKindOf(value, qb2E_LengthUnit) )
				{
					ordinal = value;
					var lengthEnumValue:qb2E_LengthUnit = qb2Enum.getEnumForOrdinal(qb2E_LengthUnit, ordinal);
					
					return lengthEnumValue;
				}
			}
			else if ( asPhysicsProperty == qb2S_PhysicsProps.JOINT_TYPE )
			{
				ordinal = value;
				
				if ( ordinal == -1 )
				{
					var jointType:qb2E_JointType = qb2Enum.getEnumForOrdinal(qb2E_JointType, ordinal);
					
					return jointType;
				}
				else
				{
					return null;
				}
			}
			
			return value;
		}
		
		public static function copyValueSetToCoordinate(valueSet:qb2PropValueSet, coord_out:qb2A_GeoCoordinate):void
		{
			for ( var i:int = 0; i < 3; i++ )
			{
				var component:* = valueSet.getValue(i);
				
				if ( component == null )
				{
					coord_out.setComponent(i, 0);
				}
				else
				{
					coord_out.setComponent(i, component as Number);
				}
			}
		}
		
		public static function copyCoordToValueSet(coord:qb2A_GeoCoordinate, valueSet_out:qb2PropValueSet):void
		{
			for ( var i:int = 0; i < 3; i++ )
			{
				valueSet_out.setValue(i, coord.getComponent(i));
			}
		}
		
		public static function isCoordinatePropertySet(flags:qb2PropFlags, coordinateProperty:qb2CoordProp, includeZ:Boolean):Boolean
		{
			if ( flags.isBitSet(coordinateProperty) )  return true;
			
			var xProperty:qb2PhysicsProp = coordinateProperty.X;
			var limit:int = includeZ ? 3 : 2;
			for ( var i:int = 0; i < limit; i++ )
			{
				var componentProperty:qb2PhysicsProp = coordinateProperty.getComponentProp(i);
				
				if ( flags.isBitSet(componentProperty) )  return true;
			}
			
			return false;
		}
		
		private static function copyCoordPropertyValuetoValueSetAtIndex(coordPropertyValue:*, valueSet_out:qb2PropValueSet, index:int):void
		{
			if ( qb2U_Type.isKindOf(coordPropertyValue, qb2A_GeoCoordinate) )
			{
				valueSet_out.setValue(index, (coordPropertyValue as qb2A_GeoCoordinate).getComponent(index));
			}
			else if ( qb2U_Type.isKindOf(coordPropertyValue, qb2E_SpecialPropValue) )
			{
				valueSet_out.setValue(index, coordPropertyValue);
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE);
			}
		}
		
		public static function getCoordinate(propertyMap:qb2PropMap, flags_nullable:qb2PropFlags, coordinateProperty:qb2CoordProp, valueSet_out:qb2PropValueSet):void
		{
			if ( valueSet_out.getLength() < 3 )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE);
			}
			
			var xProperty:qb2PhysicsProp = coordinateProperty.X;
			var tryUsingCoordProperty:Boolean = flags_nullable == null ? true : flags_nullable.isBitSet(coordinateProperty);
			
			valueSet_out.clear();
			
			var coordPropertyValue:* = propertyMap.getProperty(coordinateProperty);
			var alreadyUsedCoordProperty:Boolean = false;
			if ( tryUsingCoordProperty && coordPropertyValue != null )
			{
				if ( qb2U_Type.isKindOf(coordPropertyValue, qb2A_GeoCoordinate) )
				{
					copyCoordToValueSet(coordPropertyValue as qb2A_GeoCoordinate, valueSet_out);
					
				}
				else if ( qb2U_Type.isKindOf(coordPropertyValue, qb2E_SpecialPropValue) )
				{
					valueSet_out.setAllValues(coordPropertyValue);
				}
				else
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE);
				}
				
				alreadyUsedCoordProperty = true;
			}
			
			for ( var i:int = 0; i < 3; i++ )
			{
				var componentProperty:qb2PhysicsProp = coordinateProperty.getComponentProp(i);
				var tryUsingComponentProperty:Boolean = flags_nullable == null ? true : flags_nullable.isBitSet(componentProperty);
				
				if ( tryUsingComponentProperty )
				{
					var componentPropertyValue:* = propertyMap.getProperty(componentProperty);
					
					if ( componentPropertyValue == null )
					{
						if ( coordPropertyValue != null && !alreadyUsedCoordProperty )
						{
							copyCoordPropertyValuetoValueSetAtIndex(coordPropertyValue, valueSet_out, i);
						}
						else
						{
							valueSet_out.setValue(i, componentProperty.getDefaultValue());
						}
					}
					else
					{
						valueSet_out.setValue(i, componentPropertyValue);
					}
				}
				else
				{
					if ( coordPropertyValue != null && !alreadyUsedCoordProperty)
					{
						copyCoordPropertyValuetoValueSetAtIndex(coordPropertyValue, valueSet_out, i);
					}
					else
					{
						valueSet_out.setValue(i, propertyMap.getPropertyOrDefault(componentProperty));
					}
				}
			}
		}
	}
}