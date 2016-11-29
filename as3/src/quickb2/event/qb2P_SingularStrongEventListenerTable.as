package quickb2.event 
{
	import quickb2.lang.operators.qb2_assert;
	/**
	 * ...
	 * @author 
	 */
	internal class qb2P_SingularStrongEventListenerTable implements qb2PI_EventListenerTable
	{
		private const m_closure:qb2P_StrongMethodClosure = new qb2P_StrongMethodClosure(null, false);
		
		private var m_eventTypeId:int = qb2EventType.INVALID_EVENT_TYPE;
		
		public function getClosure():qb2P_StrongMethodClosure
		{
			return m_closure;
		}
		
		public function getEventTypeId():int
		{
			return m_eventTypeId;
		}
		
		public function isFull():Boolean
		{
			return m_closure.m_listener != null;
		}
		
		public function copy(other:qb2PI_EventListenerTable):void
		{
			//no-op
			qb2_assert(false);
		}
		
		public function dispatchEvent(event:qb2Event):void 
		{
			if ( m_closure.m_listener == null )  return;
			
			if ( m_eventTypeId == event.getType().getId() )
			{
				qb2PU_EventDispatch.dispatchEvent(event, m_closure.m_listener);
			}
		}
		
		public function addEventListener(typeId:int, listener:Function, reserved:Boolean):void 
		{
			m_eventTypeId = typeId;
			m_closure.m_listener = listener;
			m_closure.m_reserved = reserved;
		}
		
		public function hasSpecificEventListener(typeId:int, listener:Function):Boolean
		{
			return m_closure.m_listener == listener && typeId == m_eventTypeId;
		}
		
		public function hasEventListenersForListener(listener:Function):Boolean
		{
			return m_closure.m_listener == listener;
		}
		
		public function hasEventListenersForType(typeId:int):Boolean 
		{
			return m_eventTypeId == typeId;
		}
		
		public function hasAnyEventListeners():Boolean 
		{
			return m_closure.m_listener != null;
		}
		
		public function removeAllEventListenersForListener(listener:Function):void 
		{
			if ( m_closure.m_listener == listener )
			{
				m_closure.m_listener = null;
			}
		}
		
		public function removeAllEventListenersForType(typeId:int):void 
		{
			if ( m_eventTypeId == typeId && m_closure.m_reserved == false )
			{
				m_closure.m_listener = null;
			}
		}
		
		public function removeAllEventListeners():void 
		{
			if ( m_closure.m_reserved == false )
			{
				m_closure.m_listener = null;
			}
		}
		
		public function removeSpecificEventListener(typeId:int, listener:Function):void 
		{
			if ( m_closure.m_listener == listener && m_eventTypeId == typeId )
			{
				m_closure.m_listener = null;
			}
		}
	}
}