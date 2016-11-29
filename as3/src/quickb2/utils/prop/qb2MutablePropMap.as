package quickb2.utils.prop 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.utils.bits.qb2MutableBitSet;
	import quickb2.utils.qb2HashMap;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2MutablePropMap extends qb2PropMap
	{
		protected var m_listener:qb2I_PropBlockListener = null;
		
		public function qb2MutablePropMap(listener_nullable:qb2I_PropBlockListener = null) 
		{
			m_listener = listener_nullable;
		}
		
		public function copy(source:qb2PropMap):void
		{
			this.copy_internal(source);
			
			onChanged();
		}
		
		public function clear():void
		{
			m_ownership.clear();
			
			onChanged();
		}
		
		public override function clone():qb2PropMap
		{
			var clonedMap:qb2MutablePropMap = new qb2MutablePropMap();
			
			clonedMap.copy(this);
			
			return clonedMap;
		}
		
		public function setProperty(property:qb2Prop, value:*):void
		{
			if ( getProperty(property) == value )  return;
			
			mutateContract(property, value);
			
			var ordinal:int = property.getTypeSpecificOrdinal();
			
			if ( value == null )
			{
				m_ownership.setBit(property, false);
			}
			else
			{
				m_ownership.setBit(property, true);
				
				if ( property.getType() == qb2E_PropType.BOOLEAN )
				{
					if ( m_booleans == null )
					{
						m_booleans = new qb2MutableBitSet();
					}
					
					m_booleans.setBit(ordinal, value as Boolean);
				}
				else if ( property.getType() == qb2E_PropType.NUMERIC )
				{
					var number:Number;
					
					if ( qb2U_Type.isKindOf(value, qb2Enum) )
					{
						number = (value as qb2Enum).getOrdinal();
					}
					else
					{
						number = value as Number;
					}
					
					m_numbers = m_numbers != null ? m_numbers : new qb2HashMap();
			
					m_numbers.set(ordinal, number);
				}
				else if ( property.getType() == qb2E_PropType.OBJECT )
				{
					m_objects = m_objects != null ? m_objects : new qb2HashMap();
			
					m_objects.set(ordinal, value);
				}
			}
			
			onChanged();
		}
		
		private static function checkIsPropertyBoolean(value:*):void
		{
			if ( !qb2U_Type.isBoolean(value) )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected boolean value.");
			}
		}
		
		private static function checkIsPropertyNumerical(value:*):void
		{
			if ( !(value is Number) && !(value is uint) && !(value is int) && !qb2U_Type.isKindOf(value, qb2Enum) )
			{
				if ( !qb2U_Type.isKindOf(value, qb2E_SpecialPropValue) )
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected numerical or enum value.");
				}
			}
		}
		
		private static function checkIsPropertyCorrectObject(property:qb2Prop, value:*):void
		{
		}
		
		private static function mutateContract(property:qb2Prop, value:*):void
		{
			if ( property.getType() == qb2E_PropType.BOOLEAN )
			{
				checkIsPropertyBoolean(value);
			}
			else if ( property.getType() == qb2E_PropType.NUMERIC )
			{
				checkIsPropertyNumerical(value);
			}
			else if ( property.getType() == qb2E_PropType.OBJECT )
			{
				checkIsPropertyCorrectObject(property, value);
			}
		}
	}
}