package quickb2.physics.core.bridge 
{
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventType;
	import quickb2.event.qb2GlobalEventPool;
	import quickb2.event.qb2I_EventDispatcher;
	import quickb2.physics.core.events.qb2ContainerEvent;
	import quickb2.physics.core.events.qb2MassEvent;
	import quickb2.physics.core.events.qb2PropEvent;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.qb2OptVector;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2P_EventQueue 
	{
		private const m_eventQueue:qb2OptVector = new qb2OptVector();
		private const m_dispatcherQueue:qb2OptVector = new qb2OptVector();
		
		private var m_currentEventQueueIndex:int = 0;
		
		//TODO: Maintain a hash map of dispatchers and events to prevent same events from being sent twice?
		
		public function qb2P_EventQueue() 
		{
			
		}
		
		public function process():void
		{
			var eventQueueCount:int = m_eventQueue.getLength();
			var eventQueueData:Vector.<*> = m_eventQueue.getData();
			var dispatcherQueueData:Vector.<*> = m_dispatcherQueue.getData();
			
			for ( ; m_currentEventQueueIndex < eventQueueCount; m_currentEventQueueIndex++ )
			{
				dispatcherQueueData[m_currentEventQueueIndex].dispatchEvent(eventQueueData[m_currentEventQueueIndex]);
				
				eventQueueData[m_currentEventQueueIndex]		= null;
				dispatcherQueueData[m_currentEventQueueIndex]	= null;
			}
			
			m_currentEventQueueIndex = 0;
			m_eventQueue.setLength(0, false);
			m_dispatcherQueue.setLength(0, false);
		}
		
		public function push(dispatcher:qb2I_EventDispatcher, event:qb2Event):void
		{
			m_dispatcherQueue.push(dispatcher);
			m_eventQueue.push(event);
		}
		
		public function pushPropEvent(dispatcher:qb2I_EventDispatcher, changeFlags_copied:qb2PropFlags):void
		{
			if ( dispatcher.hasEventListener(qb2PropEvent.PROP_CHANGED) )
			{
				var event:qb2PropEvent = qb2GlobalEventPool.checkOut(qb2PropEvent.PROP_CHANGED) as qb2PropEvent;
				event.initWithChangedFlags(changeFlags_copied);
				this.push(dispatcher, event);
			}
		}
		
		public function pushContainerEvent(eventType:qb2EventType, dispatcher:qb2I_EventDispatcher, child:qb2A_PhysicsObject, world:qb2World):void
		{
			if ( dispatcher.hasEventListener(eventType) )
			{
				var event:qb2ContainerEvent = qb2GlobalEventPool.checkOut(eventType) as qb2ContainerEvent;
				event.initialize(child, child.getParent(), world);
				this.push(dispatcher, event);
			}
		}
		
		public function pushMassEvent(dispatcher:qb2I_EventDispatcher, responsibleObject:qb2A_TangibleObject):void
		{
			//NOTE: responsibleObject not used now...not sure if it's needed.
			
			if ( dispatcher.hasEventListener(qb2MassEvent.MASS_PROPS_CHANGED) )
			{
				var massEvent:qb2MassEvent = qb2GlobalEventPool.checkOut(qb2MassEvent.MASS_PROPS_CHANGED) as qb2MassEvent;
				massEvent.initialize();
				this.push(dispatcher, massEvent);
			}
		}
	}
}