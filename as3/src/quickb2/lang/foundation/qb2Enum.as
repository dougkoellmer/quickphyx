package quickb2.lang.foundation 
{
	import flash.utils.Dictionary;
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	
	import quickb2.lang.errors.*;

	/**
	 * Base class for java-style "poor man's" enums, basically just integer wrappers to enforce strict-typing.
	 * 
	 * The base class adds some special sauce to make the declaring of enums very painless, and provides some metadata accessors.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2Enum extends qb2A_Object
	{
		protected static const AUTO_INCREMENT:int = -1;
		
		private static const s_enumDict:Dictionary = new Dictionary();
		
		private var m_ordinal:int;
		
		public function qb2Enum(ordinal:int = AUTO_INCREMENT)
		{
			init(ordinal);
		}
		
		private function init(ordinal:int):void
		{
			include "../macros/QB2_ABSTRACT_CLASS";
			
			var T_extends_qb2Enum:Class = (this as Object).constructor;
			var enumData:qb2InternalEnumData = s_enumDict[T_extends_qb2Enum];
			
			if ( !enumData )
			{
				enumData = s_enumDict[T_extends_qb2Enum] = new qb2InternalEnumData();
			}
			
			if ( enumData.isLocked )
			{
				qb2U_Error.throwCode(qb2E_CompilerErrorCode.ENUM_ALLOCATION);
			}
			
			if ( ordinal == -1 )
			{
				m_ordinal = ++enumData.lastOrdinal;
			}
			else
			{
				enumData.lastOrdinal = ordinal;
				m_ordinal = ordinal;
			}
			
			enumData.enumList[m_ordinal] = this;
			
			enumData.count++;
		}
		
		public function getOrdinal():int
		{
			return m_ordinal;
		}
		
		public function getBit():uint
		{
			return 0x1 << m_ordinal;
		}
		
		protected static function lock(T_extends_qb2Enum:Class):void
		{
			var enumData:qb2InternalEnumData = s_enumDict[T_extends_qb2Enum];
			
			if ( !enumData ) // can be the case if enum doesn't have any entries, yet or ever.
			{
				enumData = s_enumDict[T_extends_qb2Enum] = new qb2InternalEnumData();
			}
			
			enumData.isLocked = true;
		}
		
		public static function getCount(T_extends_qb2Enum:Class):int
		{
			var enumData:qb2InternalEnumData = s_enumDict[T_extends_qb2Enum];
			
			if ( !enumData )
			{
				qb2U_Error.throwCode(qb2E_CompilerErrorCode.TYPE_MISMATCH, "Could not resolve enum type.");
			}
			
			return enumData.count;
		}
		
		public static function getEnumForOrdinal(T_extends_qb2Enum:Class, ordinal:int):*
		{
			var enumData:qb2InternalEnumData = s_enumDict[T_extends_qb2Enum];
			
			if ( !enumData )
			{
				qb2U_Error.throwCode(qb2E_CompilerErrorCode.TYPE_MISMATCH, "Could not resolve enum type.");
			}
			
			return enumData.enumList[ordinal];
		}
	}
}
import flash.utils.Dictionary;

class qb2InternalEnumData
{
	public var count:int = 0;
	public var lastOrdinal:int = -1;
	public var isLocked:Boolean = false;
	public const enumList:Dictionary = new Dictionary();
}