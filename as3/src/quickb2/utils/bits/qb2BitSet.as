package quickb2.utils.bits 
{
	import quickb2.lang.operators.qb2_assert;
	
	/**
	 * 
	 * @author ...
	 */
	public class qb2BitSet
	{
		private static const BLOCK_SIZE:int = 32;
		
		protected static const BLOCK_RELATIVE_BIT:int = 0;
		protected static const ARRAY_INDEX:int = 1;
		
		private static const s_bitData:Vector.<int> = new Vector.<int>(2, true);
		
		protected var m_blocks:Vector.<int>;
		protected var m_bitCount:int = 0;
		
		public function qb2BitSet() 
		{
		}
		
		public function clone():qb2BitSet
		{
			var newBitSet:qb2BitSet = new qb2BitSet();
			newBitSet.copy_protected(this);
			
			return newBitSet;
		}
		
		private function ensureRangeIsAsHighAs(source:qb2BitSet):void
		{
			if ( source == this || source == null )  return;
			
			this.setBitCount_protected(source.m_bitCount, false);
			
			if ( this.m_blocks.length < source.m_blocks.length )
			{
				this.m_blocks.length = source.m_blocks.length;
			}
			
			for ( var i:int = source.m_blocks.length; i < this.m_blocks.length; i++ )
			{
				this.m_blocks[i] = 0x0;
			}
		}
		
		protected function calcLogicalBlockLength():int
		{
			return (m_bitCount - (m_bitCount % BLOCK_SIZE)) / BLOCK_SIZE + 1;
		}
		
		public function isOverlapped(bitSet:qb2BitSet):Boolean
		{
			var thisLogicalBlockLength:int = this.calcLogicalBlockLength();
			var otherLogicalBlockLength:int = bitSet.calcLogicalBlockLength();
			
			for ( var i:int = 0; i < thisLogicalBlockLength && i < otherLogicalBlockLength; i++ )
			{
				if ( (this.m_blocks[i] & bitSet.m_blocks[i]) != 0 )
				{
					return true;
				}
			}
			
			return false;
		}
		
		private function truncateLastBlock(logicalLengthHint:int):void
		{
			if ( logicalLengthHint == -1 )
			{
				logicalLengthHint = this.calcLogicalBlockLength();
			}
			
			if ( logicalLengthHint == 0 ) return;
			
			this.m_blocks[logicalLengthHint-1] &= ~qb2U_Bits.bitsAfterBit(m_bitCount % BLOCK_SIZE, false);
		}
		
		protected function copy_protected(source:qb2BitSet):void
		{
			if ( source == null )  return;
			
			ensureRangeIsAsHighAs(source);
			var thisLogicalBlockLength:int = this.calcLogicalBlockLength();
			
			for ( var i:int = 0; i < thisLogicalBlockLength; i++ )
			{
				this.m_blocks[i] = source.m_blocks[i];
			}
			
			truncateLastBlock(thisLogicalBlockLength);
		}
		
		public function isEmpty():Boolean
		{
			if ( m_blocks != null )
			{
				var thisLogicalBlockLength:int = this.calcLogicalBlockLength();
				
				for ( var i:int = 0; i < thisLogicalBlockLength; i++ )
				{
					if ( this.m_blocks[i] != 0 )
					{
						return false;
					}
				}
			}
			
			return true;
		}
		
		protected function setBitCount_protected(bitCount:int, fixed:Boolean):void
		{
			m_bitCount = bitCount;
			
			var mod:int = bitCount % BLOCK_SIZE;
			var arrayLength:int = 0;
			
			if ( mod == 0 )
			{
				arrayLength = bitCount / BLOCK_SIZE;
			}
			else
			{
				arrayLength = (bitCount - mod) / BLOCK_SIZE + 1;
			}
			
			if ( m_blocks == null )
			{
				m_blocks = new Vector.<int>(arrayLength, fixed);
			}
			else
			{
				qb2_assert(fixed == false);
				
				m_blocks.length = arrayLength;
			}
		}
		
		public function getRawBlock(block:int):int
		{
			return m_blocks[block];
		}
		
		public function getBlockCount():int
		{
			return m_blocks.length;
		}
		
		protected function getBitData(position:int):Vector.<int>
		{
			var relativePosition:int = position % BLOCK_SIZE;
			var bit:int = 0x1 << relativePosition;
			var arrayIndex:int = (position - relativePosition) / BLOCK_SIZE;
			
			s_bitData[BLOCK_RELATIVE_BIT] = bit;
			s_bitData[ARRAY_INDEX] = arrayIndex;
			
			return s_bitData;
		}
		
		public function getBitCount():int
		{
			return m_bitCount;
		}
		
		public function isBitSet(position:int):Boolean
		{
			if ( position >= m_bitCount )
			{
				return false;
			}
			
			var bitData:Vector.<int> = getBitData(position);
			
			return (m_blocks[bitData[ARRAY_INDEX]] & bitData[BLOCK_RELATIVE_BIT]) != 0;
		}
		
		private function operation_earlyOut(operand_nullable:qb2BitSet, bitSet_out:qb2MutableBitSet, isAndNotOrXOr:Boolean):Boolean
		{
			if ( this == operand_nullable && operand_nullable == bitSet_out )  return true;
			
			if ( operand_nullable == null )
			{
				if ( bitSet_out != this )
				{
					bitSet_out.copy(this);
				}
				
				return true;
			}
			else if ( operand_nullable == this )
			{
				if ( isAndNotOrXOr )
				{
					bitSet_out.clear();
				}
				else
				{
					bitSet_out.copy(this);
				}
				
				return true;
			}
			
			return false;
		}
		
		private function ensureRangeForAndOperation(operand:qb2BitSet, result_out:qb2MutableBitSet):void
		{
			if ( this.getBitCount() < operand.getBitCount() )
			{
				result_out.ensureRangeIsAsHighAs(this);
			}
			else
			{
				result_out.ensureRangeIsAsHighAs(operand);
			}
		}
		
		public function bitwise(operation:qb2E_BitwiseOp, operand_nullable:qb2BitSet, bitSet_out:qb2MutableBitSet):void
		{
			if ( operation_earlyOut(operand_nullable, bitSet_out, false) )  return;
			
			bitSet_out.ensureRangeIsAsHighAs(this);
			bitSet_out.ensureRangeIsAsHighAs(operand_nullable);
			
			var thisLogicalBlockLength:int = this.calcLogicalBlockLength();
			var otherLogicalBlockLength:int = operand_nullable.calcLogicalBlockLength();
			var i:int = 0;
			
			if ( operation == qb2E_BitwiseOp.AND )
			{
				for ( i = 0; i < thisLogicalBlockLength && i < otherLogicalBlockLength; i++ )
				{
					bitSet_out.m_blocks[i] = this.m_blocks[i] & operand_nullable.m_blocks[i];
				}
			}
			else if ( operation == qb2E_BitwiseOp.AND_NOT )
			{
				for ( i = 0; i < thisLogicalBlockLength && i < otherLogicalBlockLength; i++ )
				{
					bitSet_out.m_blocks[i] = this.m_blocks[i] & ~operand_nullable.m_blocks[i];
				}
			}
			else if ( operation == qb2E_BitwiseOp.OR )
			{
				var maxLength:int = Math.max(thisLogicalBlockLength, otherLogicalBlockLength);
			
				for ( i= 0; i < maxLength; i++ )
				{
					if ( i >= this.m_blocks.length )
					{
						bitSet_out.m_blocks[i] = operand_nullable.m_blocks[i];
					}
					else if ( i >= operand_nullable.m_blocks.length )
					{
						bitSet_out.m_blocks[i] = this.m_blocks[i];
					}
					else
					{
						bitSet_out.m_blocks[i] = this.m_blocks[i] | operand_nullable.m_blocks[i];
					}
				}
				
				bitSet_out.truncateLastBlock(-1);
			}
		}
	}
}