package quickb2.utils.prop 
{
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.bits.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2MutablePropFlags extends qb2PropFlags
	{		
		public function qb2MutablePropFlags() 
		{
		}
		
		internal function getOrCreateMutableBitSet(propertyType:qb2E_PropType):qb2MutableBitSet
		{
			if ( m_bitSets[propertyType.getOrdinal()] == null )
			{
				m_bitSets[propertyType.getOrdinal()] = new qb2MutableBitSet();
			}
			
			return m_bitSets[propertyType.getOrdinal()];
		}
		
		public function getMutableBitSet(propertyType:qb2E_PropType):qb2MutableBitSet
		{
			return m_bitSets[propertyType.getOrdinal()];
		}
		
		public function setBit(property:qb2Prop, value:Boolean):void
		{
			var bitSet:qb2MutableBitSet = m_bitSets[property.getType().getOrdinal()];
			
			if ( bitSet == null )
			{
				bitSet = m_bitSets[property.getType().getOrdinal()] = new qb2MutableBitSet();
			}
			
			bitSet.setBit(property.getTypeSpecificOrdinal(), value);
		}
		
		public function clear(propertyType_nullable:qb2E_PropType = null):void
		{
			if ( propertyType_nullable == null )
			{
				for ( var i:int = 0; i < m_bitSets.length; i++ )
				{
					clear(qb2Enum.getEnumForOrdinal(qb2E_PropType, i));
				}
			}
			else
			{
				var bitSet:qb2MutableBitSet = m_bitSets[propertyType_nullable.getOrdinal()];
				
				if ( bitSet == null )  return;
				
				bitSet.clear();
			}
		}
		
		public function copy(source:qb2PropFlags, propertyType_nullable:qb2E_PropType = null):void
		{
			super.copy_protected(source, propertyType_nullable);
		}
	}
}