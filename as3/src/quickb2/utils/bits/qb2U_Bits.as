package quickb2.utils.bits 
{
	import quickb2.lang.foundation.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2U_Bits extends qb2UtilityClass
	{
		public static function isPowerOfTwo(bits:uint):Boolean
		{
			return ((bits & (bits - 1)) == 0);
		}
		
		public static function bitsBeforeBit(bitPosition:int, inclusive:Boolean):int
		{
			var bit:int = 0x1 << bitPosition;
			
			var bits:int = (bit << 1) - 1;
			
			if ( !inclusive )
			{
				bits &= ~bit;
			}
			
			return bits;
		}
		
		public static function bitsAfterBit(bitPosition:int, inclusive:Boolean):int
		{
			return ~bitsBeforeBit(bitPosition, inclusive);
		}
		
		public static function upperPowerOfTwo(value:uint):uint
		{
			value--;
			value |= value >> 1;
			value |= value >> 2;
			value |= value >> 4;
			value |= value >> 8;
			value |= value >> 16;
			value++;
			
			return value;
		}
		
		public static function lowerPowerOfTwo(value:uint):uint
		{
			value = value | (value >> 1); 
			value = value | (value >> 2); 
			value = value | (value >> 4); 
			value = value | (value >> 8); 
			value = value | (value >> 16);
			
			return value - (value >> 1); 
		}
	}
}