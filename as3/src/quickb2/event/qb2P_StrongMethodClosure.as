package quickb2.event 
{
	internal final class qb2P_StrongMethodClosure
	{
		public function qb2P_StrongMethodClosure(listener:Function, reserved:Boolean):void
		{
			m_listener = listener;
			m_reserved = reserved;
		}
		
		public function clone():qb2P_StrongMethodClosure
		{
			return new qb2P_StrongMethodClosure(m_listener, m_reserved);
		}
		
		public var m_listener:Function;
		public var m_reserved:Boolean;
	}
}