package quickb2.event 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2P_EventPool 
	{		
		private var m_factory:qb2I_EventFactory;
		private var m_logicalSize:int = 0;
		private const m_instances:Vector.<Object> = new Vector.<Object>();
	
		public function qb2P_EventPool(factory:qb2I_EventFactory) 
		{
			m_factory = factory;
		}
		
		public function checkOut():*
		{
			var physicalSize:int = m_instances.length;
			
			while ( m_logicalSize >= physicalSize )
			{
				m_instances.push(null);
				
				physicalSize++;
			}
			
			if (m_instances[m_logicalSize] == null)
			{
				m_instances[m_logicalSize] = m_factory.newInstance();
			}
			
			var instance:Object = m_instances[m_logicalSize];
			
			m_logicalSize++;
			
			return instance;
		}
		
		public function checkIn(instance:Object):void
		{
			if ( m_logicalSize > 0 )
			{
				m_instances[m_logicalSize-1] = instance;
			
				m_logicalSize--;
			}
		}
	}
}