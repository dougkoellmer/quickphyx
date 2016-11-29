package quickb2.lang.errors 
{
	import quickb2.lang.*
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	

	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Error extends qb2Throwable
	{
		private var m_errorCode:qb2I_ErrorCode = null;
		
		public function qb2Error(errorCode:qb2I_ErrorCode, overrideMessage:String = null) 
		{
			m_errorCode = errorCode;
			
			overrideMessage = overrideMessage == null ? m_errorCode.getMessage() : overrideMessage;
			
			super(overrideMessage, m_errorCode.getId());
		}
		
		public function getErrorCode():qb2I_ErrorCode
		{
			return m_errorCode;
		}
	}
}