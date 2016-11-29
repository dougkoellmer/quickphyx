package quickb2.debugging.logging 
{
	import flash.utils.Dictionary;
	import quickb2.lang.foundation.qb2A_Object;
	
	import quickb2.lang.errors.*;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2Logger extends qb2A_Object
	{
		private static const s_loggerMap:Dictionary = new Dictionary();
		
		private static const s_rootLogger:qb2Logger = new qb2Logger();
		
		private static var s_allowInstantiation:Boolean = true;
		
		{
			s_allowInstantiation = false;
			
			//s_rootLogger.addLogWriter(new qb2FlashLogWriter());
		}
		
		private var m_T:Class = null;
		private var m_name:String = null;

		
		public static function getInstanceByClass(T:Class):qb2Logger
		{
			s_allowInstantiation = true;
			
			if ( !s_loggerMap[T] )
			{
				var logger:qb2Logger = new qb2Logger();
				
				logger.m_T = T;
				logger.m_name = T + "";
				
				s_loggerMap[T] = logger;
			}
			
			s_allowInstantiation = false;
			
			return s_loggerMap[T];
		}
		
		public static function getInstanceByName(name:String):qb2Logger
		{
			s_allowInstantiation = true;
			
			if ( !s_loggerMap[name] )
			{
				var logger:qb2Logger = new qb2Logger();
				
				logger.m_name = name
				
				s_loggerMap[name] = logger;
			}
			
			s_allowInstantiation = false;
			
			return s_loggerMap[name];
		}
		
		public static function getRootInstance():qb2Logger
		{			
			return s_rootLogger;
		}
		
		public function qb2Logger() 
		{
			if ( !s_allowInstantiation )
			{
				qb2U_Error.throwCode(qb2E_CompilerErrorCode.PRIVATE_CONSTRUCTOR);
			}
		}
		
		public function logDebug(message:String):void
		{
			trace(message);
		}
		
		public function logInfo(message:String):void
		{
			trace(message);
		}
		
		public function logWarning(message:String):void
		{
			trace(message);
		}
		
		public function logError(message:String):void
		{
			trace(message);
		}
		
		public function addLogWriter(writer:qb2I_LogWriter):void
		{
			
		}
		
		public function removeLogWriter(writer:qb2I_LogWriter):void
		{
			
		}
	}
}