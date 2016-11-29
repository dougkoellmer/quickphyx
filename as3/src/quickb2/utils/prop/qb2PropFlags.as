package quickb2.utils.prop 
{
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.utils.bits.*;
	import quickb2.utils.bits.qb2E_BitwiseOp;
	import quickb2.utils.bits.qb2MutableBitSet;
	import quickb2.utils.prop.qb2E_PropType;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2PropFlags
	{
		protected const m_bitSets:Vector.<qb2MutableBitSet> = new Vector.<qb2MutableBitSet>(qb2Enum.getCount(qb2E_PropType), true);
		
		public function qb2PropFlags() 
		{
		}
		
		public function getBitSet(propertyType:qb2E_PropType):qb2BitSet
		{
			return m_bitSets[propertyType.getOrdinal()];
		}
		
		public function isOverlapped(propertyFlags:qb2PropFlags, propertyType_nullable:qb2E_PropType = null):Boolean
		{
			if ( propertyType_nullable == null )
			{
				for ( var i:int = 0; i < m_bitSets.length; i++ )
				{
					if ( isOverlapped(propertyFlags, qb2Enum.getEnumForOrdinal(qb2E_PropType, i)) )
					{
						return true;
					}
				}
				
				return false;
			}
			else
			{
				var thisBitSet:qb2MutableBitSet = this.m_bitSets[propertyType_nullable.getOrdinal()];
				var otherBitSet:qb2MutableBitSet = propertyFlags.m_bitSets[propertyType_nullable.getOrdinal()];
				
				if ( thisBitSet == null || otherBitSet == null )  return false;
				
				return thisBitSet.isOverlapped(otherBitSet);
			}
		}
		
		
		public function isEmpty(propertyType_nullable:qb2E_PropType = null):Boolean
		{
			if ( propertyType_nullable == null )
			{
				for ( var i:int = 0; i < m_bitSets.length; i++ )
				{
					if ( !isEmpty(qb2Enum.getEnumForOrdinal(qb2E_PropType, i)) )
					{
						return false;
					}
				}
				
				return true;
			}
			else
			{
				var bitSet:qb2MutableBitSet = m_bitSets[propertyType_nullable.getOrdinal()];
				
				if ( bitSet == null )  return true;
				
				return bitSet.isEmpty();
			}
		}
		
		public function isBitSet(property:qb2Prop):Boolean
		{
			var bitSet:qb2MutableBitSet = m_bitSets[property.getType().getOrdinal()];
			
			if ( bitSet == null )  return false;
			
			return bitSet.isBitSet(property.getTypeSpecificOrdinal());
		}
		
		/*public function getBitSet(propertyType:qb2E_PropType):qb2MutableBitSet
		{
			return m_bitSets[propertyType.getOrdinal()];
		}*/
		
		protected function copy_protected(source:qb2PropFlags, propertyType_nullable:qb2E_PropType = null):void
		{
			if ( propertyType_nullable == null )
			{
				for ( var i:int = 0; i < m_bitSets.length; i++ )
				{
					copy_protected(source, qb2Enum.getEnumForOrdinal(qb2E_PropType, i));
				}
			}
			else
			{
				var index:int = propertyType_nullable.getOrdinal();
				
				if ( this.m_bitSets[index] == null && source.m_bitSets[index] == null )  return;
				
				if ( this.m_bitSets[index] == null )
				{
					m_bitSets[index] = new qb2MutableBitSet();
					
					m_bitSets[index].copy(source.m_bitSets[index]);
				}
				else if ( source.m_bitSets[index] == null )
				{
					m_bitSets[index].clear();
				}
				else
				{
					m_bitSets[index].copy(source.m_bitSets[index]);
				}
			}
		}
		
		public function bitwise(operation:qb2E_BitwiseOp, operand_nullable:qb2PropFlags, value_out:qb2MutablePropFlags, propertyType_nullable:qb2E_PropType = null):void
		{
			if ( propertyType_nullable == null )
			{
				for ( var i:int = 0; i < m_bitSets.length; i++ )
				{
					bitwise(operation, operand_nullable, value_out, qb2Enum.getEnumForOrdinal(qb2E_PropType, i));
				}
			}
			else
			{
				var index:int = propertyType_nullable.getOrdinal();
				var thisBitSet:qb2MutableBitSet = this.m_bitSets[index];
				var operandBitSet:qb2MutableBitSet = operand_nullable != null ? operand_nullable.m_bitSets[index] : null;
				var bitSet_out:qb2MutableBitSet = value_out.m_bitSets[index];
				
				if ( thisBitSet == null && operandBitSet == null )
				{
					value_out.clear();
					
					return;
				}
				
				if ( bitSet_out == null )
				{
					bitSet_out = value_out.m_bitSets[index] = new qb2MutableBitSet();
				}
				
				if ( thisBitSet == null )
				{
					bitSet_out.copy(operandBitSet);
					
					return;
				}
				
				thisBitSet.bitwise(operation, operandBitSet, bitSet_out);
			}
		}
	}
}