package quickb2.lang.foundation
{
	import quickb2.debugging.logging.*;
	import quickb2.lang.*;
	import quickb2.lang.errors.*;
	
	
	/**
	 * Base class for all utility classes, which are collections of static functions.
	 * qb2Util itself stores references to all utility subclasses for easy access.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2UtilityClass extends Object
	{
		private static var s_creatingInstance:Boolean = false;
		
		public function qb2UtilityClass()
		{
			if (!s_creatingInstance)
			{
				qb2U_Error.throwCode(qb2E_CompilerErrorCode.UTILITY_CLASS);
			}
		}
		
		protected static function allowSingletonCreation():void
		{
			s_creatingInstance = true;
		}
		
		protected static function denySingletonCreation():void
		{
			s_creatingInstance = false;
		}
	}
}