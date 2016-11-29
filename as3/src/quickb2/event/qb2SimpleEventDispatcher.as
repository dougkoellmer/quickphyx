package quickb2.event 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2SimpleEventDispatcher 
	{
		private var m_listener:Function;
		
		public function addEventListener(listener:Function):void
		{
			if ( m_listener != null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ALREADY_DEFINED, "Only one listener is allowed at a time.");
				
				return;
			}
			
			m_listener = listener;
		}
		
		public function hasEventListener(listener_nullable:Function = null):Boolean
		{
			if ( listener_nullable == null )
			{
				return m_listener != null;
			}
			else
			{
				return m_listener == listener_nullable;
			}
		}
		
		public function dispatchEvent(arg_nullable:*):void
		{
			if ( m_listener == null )  return;
			
			qb2PU_EventDispatch.dispatchSimpleEvent(arg_nullable, m_listener);
		}
		
		public function removeEventListener(listener:Function):void
		{
			if ( m_listener == null || m_listener != listener )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Argument must match stored event listener.");
				
				return;
			}
			
			m_listener = null;
		}
	}

}