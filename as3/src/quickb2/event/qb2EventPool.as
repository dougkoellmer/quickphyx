package quickb2.event 
{
	import flash.utils.Dictionary;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2I_Constructor;
	import quickb2.utils.qb2ObjectPool;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2EventPool 
	{
		private const m_pools:Dictionary = new Dictionary();
		private const m_defaultFactory:qb2EventFactory = new qb2EventFactory(qb2Event);
		
		public function qb2EventPool() 
		{
			
		}
		
		private function hasSubPool(eventClass:Class):Boolean
		{
			return m_pools[eventClass] != null;
		}
		
		private function registerSubPool(eventClass:Class, factory:qb2I_EventFactory):void
		{
			m_pools[eventClass] = new qb2P_EventPool(factory);
		}
		
		private function getSubPool(eventClass:Class):qb2P_EventPool
		{
			var pool:qb2P_EventPool = m_pools[eventClass];
			
			return pool;
		}
		
		/**
		 * Retrieves a clean, ready to use event instance. You are encouraged to use this factory method in place of
		 * making new events, because the qb2Event class maintains an efficient internal pool that's very light on memory use.
		 * 
		 * The event will automatically be released back to the pool when it's finished being dispatched.
		 * 
		 * @param	type_nullable  The event type to assign to the instance retrieved.
		 * 
		 * @return A fresh event instance.
		 */
		public function checkOut(type_nullable:qb2EventType = null):qb2Event
		{
			var multiType:qb2EventMultiType = type_nullable as qb2EventMultiType;
			var instance:qb2Event = null;
			
			if ( multiType != null )
			{
				instance = checkOut(multiType.m_childrenTypes.length ? multiType.m_childrenTypes[0] : null);
			}
			else
			{
				var eventClass:Class = null;
				var factory:qb2I_EventFactory = null;
				
				if ( type_nullable == null )
				{
					eventClass = qb2Event;
					factory = m_defaultFactory;
				}
				else
				{
					eventClass = type_nullable.getNativeEventClass();
					factory = type_nullable.getEventFactory();
					
					if ( eventClass == null )
					{
						eventClass = qb2Event;
						factory = m_defaultFactory;
					}
				}
				
				if ( !this.hasSubPool(eventClass) )
				{
					this.registerSubPool(eventClass, factory);
				}
				
				var subPool:qb2P_EventPool = this.getSubPool(eventClass);
				
				instance = subPool.checkOut();
				instance.m_pool = subPool;
			}
			
			instance.setType(type_nullable);
			
			return instance;
		}
		
		internal static function checkIn(instance:qb2Event):void
		{
			var subPool:qb2P_EventPool = instance.m_pool;
			
			if ( subPool != null )
			{
				subPool.checkIn(instance);
				instance.clean_internal();
			}
			else
			{
				qb2_assert(false);
			}
		}
	}
}