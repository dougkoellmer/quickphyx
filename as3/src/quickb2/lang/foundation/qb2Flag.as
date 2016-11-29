package quickb2.lang.foundation 
{
	import flash.utils.Dictionary;
	import quickb2.lang.errors.*;
	import quickb2.lang.*;
	import quickb2.utils.bits.qb2U_Bits;
	
	
	import quickb2.lang.operators.*;
	
	import quickb2.utils.*;
	
	/**
	 * A qb2Flag is simply a type-safe way to work with bit-based flags.  They behave much the same way as enums,
	 * but represent individual bits (1, 2, 4, 8, 16, etc.) instead of ordinals (1, 2, 3, 4, etc.).
	 * 
	 * Unlike enums, they can be created on the fly, because you can bitwise-OR and AND them together.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2Flag extends qb2A_Object
	{
		private var m_bits:uint = 0;
		
		private static const s_typeDict:Dictionary = new Dictionary();
		
		private static const AND_OP:int	= 0;
		private static const OR_OP:int	= 1;
		
		public static function or(... flags):*
		{
			performOperation.call(null, flags, OR_OP);
		}
		
		public static function and(... flags):*
		{
			performOperation.call(null, flags, AND_OP);
		}
		
		private static function performOperation(flags:Array, operationType:int):*
		{
			var bits:uint = 0;
			var length:int = flags.length;
			var T:Class = null;
			for ( var i:int = 0; i < length; i++ )
			{
				var ithFlag:qb2Flag = flags[i] as qb2Flag;
				
				//--- Do type checking, make sure this is a flag subclass.
				if ( ithFlag == null )
				{
					qb2U_Error.throwCode(qb2E_CompilerErrorCode.TYPE_MISMATCH);
				}
				
				var nextT:Class = (ithFlag as Object).constructor;
				if ( T != null )
				{
					if ( T != nextT )
					{
						qb2U_Error.throwCode(qb2E_CompilerErrorCode.TYPE_MISMATCH);
					}
				}
				else
				{
					T = nextT;
				}
				
				switch(operationType)
				{
					case OR_OP:
					{
						bits |= ithFlag.m_bits;
						
						break;
					};
					
					case AND_OP:
					{
						bits &= ithFlag.m_bits;
						
						break;
					};
				}
			}
			
			return new T(bits);
		}
		
		public function qb2Flag(bits:uint = 0)
		{
			init(bits);
		}
		
		private function init(bits:uint):void
		{
			include "../macros/QB2_ABSTRACT_CLASS";
			
			m_bits = bits;
			
			var T:Class = (this as Object).constructor;
			var flagData:qb2InternalFlagData = s_typeDict[T];
			
			if ( !flagData )
			{
				flagData = s_typeDict[T] = new qb2InternalFlagData();
			}
			
			if ( !flagData.flagsInitialized && bits == 0 )
			{
				m_bits = flagData.currentBit;
				flagData.currentBit <<= 1;
				flagData.forbiddenBits &= ~m_bits;
				flagData.count++;
			}
			else
			{
				if ( (flagData.forbiddenBits & bits) != 0 )
				{
					qb2U_Error.throwCode(qb2E_CompilerErrorCode.ILLEGAL_FLAG_ASSIGNMENT, "Bits for the flag are out of range.");
				}
				
				m_bits = bits;
			}
		}
		
		public function getBits():uint
		{
			return m_bits;
		}
		
		public function or(flag:qb2Flag):*
		{
			return make(m_bits | flag.m_bits, (this as Object).constructor);
		}
		
		public function and(flag:qb2Flag):*
		{
			return make(m_bits & flag.m_bits, (this as Object).constructor);
		}
		
		public function overlaps(flag:qb2Flag):Boolean
		{
			if ( flag == null )  return false;
			
			return (this.m_bits & flag.m_bits) != 0;
		}
		
		public function not():*
		{
			var T_extends_qb2Flag:Class = this.getClass().getNativeType();
			
			var flagData:qb2InternalFlagData = s_typeDict[T_extends_qb2Flag];
			
			return make(~m_bits & ~flagData.forbiddenBits, T_extends_qb2Flag);
		}
		
		public function isPowerOfTwo():Boolean
		{
			return qb2U_Bits.isPowerOfTwo(m_bits);
		}
		
		private static function make(bits:uint, T_extends_qb2Flag:Class):*
		{
			return new T_extends_qb2Flag(bits);
		}
		
		public static function FFFFFFFF(T_extends_qb2Flag:Class):*
		{
			return make(getAllowedBits(T_extends_qb2Flag), T_extends_qb2Flag);
		}
		
		public static function getCount(T_extends_qb2Flag:Class):int
		{
			var flagData:qb2InternalFlagData = s_typeDict[T_extends_qb2Flag];
		
			return flagData.count;
		}
		
		public static function getAllowedBits(T_extends_qb2Flag:Class):uint
		{
			var flagData:qb2InternalFlagData = s_typeDict[T_extends_qb2Flag];
		
			return ~flagData.forbiddenBits;
		}
		
		protected static function initialized(T_extends_qb2Flag:Class):void
		{
			var flagData:qb2InternalFlagData = s_typeDict[T_extends_qb2Flag];
			flagData.flagsInitialized = true;
		}
	}
}

internal class qb2InternalFlagData
{
	public var count:int = 0;
	public var flagsInitialized:Boolean = false;
	public var currentBit:uint = 0x1;
	public var forbiddenBits:uint = 0xFFFFFFFF;
}