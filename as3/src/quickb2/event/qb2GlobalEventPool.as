package quickb2.event 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2GlobalEventPool 
	{
		private static var m_pool:qb2EventPool = null;
		
		public static function checkOut(type_nullable:qb2EventType):*
		{
			m_pool = m_pool != null ? m_pool : new qb2EventPool();
			
			return m_pool.checkOut(type_nullable);
		}
	}
}