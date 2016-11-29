package quickb2.event 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2EventFactory implements qb2I_EventFactory
	{
		private var m_objectClass:Class;
		
		public function qb2EventFactory(objectClass:Class)
		{
			m_objectClass = objectClass;
		}
		
		public function newInstance():qb2Event
		{
			return new m_objectClass;
		}
	}
}