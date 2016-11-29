package quickb2.utils.prop 
{
	import flash.utils.Dictionary;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.utils.bits.qb2BitSet;
	import quickb2.utils.bits.qb2E_BitwiseOp;
	import quickb2.utils.bits.qb2MutableBitSet;
	import quickb2.utils.qb2HashMap;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2PropMap
	{		
		protected static const s_utilBitSet1:qb2MutableBitSet = new qb2MutableBitSet();
		
		protected var m_booleans:qb2MutableBitSet = new qb2MutableBitSet();
		
		protected var m_numbers:qb2HashMap;
		protected var m_objects:qb2HashMap;
		
		protected const m_ownership:qb2MutablePropFlags = new qb2MutablePropFlags();
		
		public function qb2PropMap() 
		{
		}
		
		[qb2_abstract] internal function onChanged():void
		{
			
		}
		
		internal function copy_internal(source:qb2PropMap):void
		{
			source.concat_internal(null, this, qb2E_PropConcatType.OR);
		}
		
		public function getOwnership():qb2PropFlags
		{
			return m_ownership;
		}
		
		public function clone():qb2PropMap
		{
			var clonedMap:qb2PropMap = new qb2PropMap();
			
			clonedMap.copy_internal(this);
			
			return clonedMap;
		}
		
		private function concat_contract(map_nullable:qb2PropMap, map_out:qb2PropMap):void
		{
			if ( map_nullable != null && map_nullable == map_out )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "The two map arguments cannot reference the same object.");
			}
		}
		
		internal function concat_internal(map_nullable:qb2PropMap, map_out:qb2PropMap, operation:qb2E_PropConcatType):void
		{
			concat_contract(map_nullable, map_out);
			
			concatForPropertyType(map_nullable, map_out, qb2E_PropType.BOOLEAN, operation);
			concatForPropertyType(map_nullable, map_out, qb2E_PropType.NUMERIC, operation);
			concatForPropertyType(map_nullable, map_out, qb2E_PropType.OBJECT, operation);
		}
		
		public function concat(map_nullable:qb2PropMap, map_out:qb2MutablePropMap, operation:qb2E_PropConcatType, type_nullable:qb2E_PropType = null):void
		{
			concat_contract(map_nullable, map_out);
			
			if ( type_nullable == null )
			{
				this.concat_internal(map_nullable, map_out, operation);
			}
			else if ( type_nullable == qb2E_PropType.BOOLEAN )
			{
				this.concatForPropertyType(map_nullable, map_out, qb2E_PropType.BOOLEAN, operation);
			}
			else if ( type_nullable == qb2E_PropType.NUMERIC )
			{
				this.concatForPropertyType(map_nullable, map_out, qb2E_PropType.NUMERIC, operation);
			}
			else if ( type_nullable == qb2E_PropType.OBJECT )
			{
				this.concatForPropertyType(map_nullable, map_out, qb2E_PropType.OBJECT, operation);
			}
			
			map_out.onChanged();
		}
		
		private function concatOwnership(other_nullable:qb2PropMap, map_out:qb2PropMap, propertyType:qb2E_PropType):void
		{			
			var thisOwnershipSet:qb2BitSet = this.m_ownership.getBitSet(propertyType);
			var otherOwnershipSet:qb2BitSet = other_nullable == null ? null : other_nullable.m_ownership.getBitSet(propertyType);
			var outOwnershipSet:qb2MutableBitSet = map_out.m_ownership.getOrCreateMutableBitSet(propertyType);
			
			if ( thisOwnershipSet != null )
			{
				thisOwnershipSet.bitwise(qb2E_BitwiseOp.OR, otherOwnershipSet, outOwnershipSet);
			}
			else if ( otherOwnershipSet != null )
			{
				outOwnershipSet.copy(otherOwnershipSet);
			}
		}
		
		private static function concat_earlyOut(map1:qb2PropMap, map2:qb2PropMap, map_out:qb2PropMap, propertyType:qb2E_PropType):Boolean
		{
			if ( map1 == map2 && map2 == map_out )
			{
				qb2_assert(false);
				
				return true;
			}
			
			if( map1 == null || map1.m_ownership.isEmpty(propertyType) )
			{
				if ( map2 == map_out || map2 == null || map2.m_ownership.isEmpty(propertyType) )
				{
					return true;
				}
				else
				{
					map_out.ensureValueMapExists(propertyType);
					
					map_out.m_ownership.copy(map2.m_ownership, propertyType);
					
					if ( propertyType == qb2E_PropType.BOOLEAN )
					{
						map_out.m_booleans.copy(map2.m_booleans);
					}
					else if ( propertyType == qb2E_PropType.NUMERIC )
					{
						copyHashMap(map2.m_numbers, map_out.m_numbers, map2.m_ownership, propertyType);
					}
					else if ( propertyType == qb2E_PropType.OBJECT )
					{
						copyHashMap(map2.m_objects, map_out.m_objects, map2.m_ownership, propertyType);
					}
				}
				
				return true;
			}
			
			map_out.ensureValueMapExists(propertyType);
			
			return false;
		}
		
		private function ensureValueMapExists(propertyType:qb2E_PropType):void
		{			
			if ( propertyType == qb2E_PropType.BOOLEAN && this.m_booleans == null )
			{
				this.m_booleans = new qb2MutableBitSet();
			}
			else if ( propertyType == qb2E_PropType.NUMERIC && this.m_numbers == null)
			{
				this.m_numbers = new qb2HashMap();
			}
			else if ( propertyType == qb2E_PropType.OBJECT &&  this.m_objects == null)
			{
				this.m_objects = new qb2HashMap();
			}
		}
		
		private function concatForPropertyType(map_nullable:qb2PropMap, map_out:qb2PropMap, propertyType:qb2E_PropType, operation:qb2E_PropConcatType):void
		{
			if ( map_nullable == null && this == map_out )  return;
			
			if ( concat_earlyOut(this, map_nullable, map_out, propertyType) || concat_earlyOut(map_nullable, this, map_out, propertyType) )  return;
			
			var ownershipSetIndex:int = propertyType.getOrdinal();
			var thisOwnershipSet:qb2BitSet = this.m_ownership.getBitSet(propertyType);
			var otherOwnershipSet:qb2BitSet = map_nullable.m_ownership.getBitSet(propertyType);
			//var outOwnershipSet:qb2MutableBitSet = map_out.m_ownership.getMutableBitSet(propertyType);
			
			var ownershipSetToCopyFromOther:qb2BitSet = null;
			
			if ( operation == qb2E_PropConcatType.OR )
			{
				ownershipSetToCopyFromOther = otherOwnershipSet;
			}
			else if( operation == qb2E_PropConcatType.X_OR )
			{
				otherOwnershipSet.bitwise(qb2E_BitwiseOp.AND_NOT, thisOwnershipSet, s_utilBitSet1);
				ownershipSetToCopyFromOther = s_utilBitSet1;					
			}
			
			if ( propertyType == qb2E_PropType.BOOLEAN )
			{
				this.m_booleans.bitwise(qb2E_BitwiseOp.AND_NOT, ownershipSetToCopyFromOther, map_out.m_booleans); // clear booleans to be overwritten, i.e. those owned by other map (or the subset thereof not owned by 'this').
				map_nullable.m_booleans.bitwise(qb2E_BitwiseOp.AND, ownershipSetToCopyFromOther, s_utilBitSet1);		// collect the bits that are owned *and* set in the other map.
				this.m_booleans.bitwise(qb2E_BitwiseOp.OR, s_utilBitSet1, map_out.m_booleans); // append said bits and dump result to the out map.
			}
			else
			{
				copyHashMapForPropertyType(map_nullable, map_out, propertyType, map_nullable.m_ownership);
				
				if ( map_out != this )
				{
					var ownershipSetToCopyFromThis:qb2BitSet = null;
					
					if ( operation == qb2E_PropConcatType.OR )
					{
						thisOwnershipSet.bitwise(qb2E_BitwiseOp.AND_NOT, ownershipSetToCopyFromOther, s_utilBitSet1);
						ownershipSetToCopyFromThis = s_utilBitSet1;
					}
					else if( operation == qb2E_PropConcatType.X_OR )
					{
						ownershipSetToCopyFromThis = thisOwnershipSet;	
					}
					
					copyHashMapForPropertyType(this, map_out, propertyType, this.m_ownership);
				}
			}
			
			this.concatOwnership(map_nullable, map_out, propertyType);
		}
		
		private static function copyHashMapForPropertyType(sourceMap:qb2PropMap, destinationMap:qb2PropMap, propertyType:qb2E_PropType, propertyFlags:qb2MutablePropFlags):void
		{
			if ( propertyType == qb2E_PropType.NUMERIC )
			{
				copyHashMap(sourceMap.m_numbers, destinationMap.m_numbers, propertyFlags, propertyType);
			}
			else
			{
				copyHashMap(sourceMap.m_objects, destinationMap.m_objects, propertyFlags, propertyType);
			}
		}
		
		private static function copyHashMap(source:qb2HashMap, destination:qb2HashMap, propertyFlags:qb2MutablePropFlags, propertyType:qb2E_PropType):void
		{
			var ownershipSet:qb2BitSet = propertyFlags.getBitSet(propertyType);
			
			if ( ownershipSet == null )  return;
			
			for ( var i:int = 0; i < ownershipSet.getBitCount(); i++ )
			{
				//var iMod32:int = i % 32;
				//var iMod16:int = i % 16;
				
				//TODO: Can perhaps optimize this for most cases by checking one or two bytes at a time or something.
				if ( i % 32 == 0 )
				{
					if ( ownershipSet.getRawBlock(i / 32) == 0x0 )
					{
						i += 32;
						
						continue;
					}
				}
				
				if ( ownershipSet.isBitSet(i) )
				{
					destination.set(i, source.get(i));
				}
			}
		}
		
		public function getPropertyOrDefault(property:qb2Prop):*
		{
			var value:* = this.getProperty(property);
			
			if ( value == null )
			{
				value = property.getDefaultValue();
			}
			
			return value;
		}
		
		public function hasProperty(property:qb2Prop):Boolean
		{
			return m_ownership.isBitSet(property);
		}
		
		public function getProperty(property:qb2Prop):*
		{
			if ( !m_ownership.isBitSet(property) )  return null;
			
			var ordinal:int = property.getTypeSpecificOrdinal();
			
			if ( property.getType() == qb2E_PropType.BOOLEAN )
			{
				return m_booleans.isBitSet(ordinal);
			}
			else if ( property.getType() == qb2E_PropType.NUMERIC )
			{
				return m_numbers.get(ordinal);
			}
			else if ( property.getType() == qb2E_PropType.OBJECT )
			{
				return m_objects.get(ordinal);
			}
		}
	}
}