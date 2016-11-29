package quickb2.utils.bits 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2MutableBitSet extends qb2BitSet
	{
		public function qb2MutableBitSet() 
		{
		}
		
		public function clear():void
		{
			var thisLogicalBlockLength:int = this.calcLogicalBlockLength();
			
			for ( var i:int = 0; i < thisLogicalBlockLength; i++ )
			{
				this.m_blocks[i] = 0x0;
			}
		}
		
		public function copy(source:qb2BitSet):void
		{
			super.copy_protected(source);
		}
		
		public function setBit(position:int, value:Boolean):void
		{
			var bitData:Vector.<int> = getBitData(position);
			
			if ( position >= this.getBitCount() )
			{
				this.setBitCount_protected(position + 1, false)
			}
			
			if ( value )
			{
				m_blocks[bitData[ARRAY_INDEX]] |= bitData[BLOCK_RELATIVE_BIT];
			}
			else
			{
				m_blocks[bitData[ARRAY_INDEX]] &= ~bitData[BLOCK_RELATIVE_BIT];
			}
		}
	}
}