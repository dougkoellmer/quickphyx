package quickb2.debugging.logging 
{
	import quickb2.lang.foundation.qb2Flag;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2F_LogLevel extends qb2Flag
	{
		include "../../lang/macros/QB2_FLAG";
		
		public function qb2F_LogLevel(bits:uint = 0)
		{
			super(bits);
		}
		
		public static const DEBUG:qb2F_LogLevel			= new qb2F_LogLevel();
		public static const INFO:qb2F_LogLevel			= new qb2F_LogLevel();
		public static const WARNING:qb2F_LogLevel		= new qb2F_LogLevel();
		public static const ERROR:qb2F_LogLevel			= new qb2F_LogLevel();
		
		public static const ALL:qb2F_LogLevel			= qb2Flag.FFFFFFFF(qb2F_LogLevel);
	}
}