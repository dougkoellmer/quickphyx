package quickb2.utils.iterator 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	/**
	 * ...
	 * @author 
	 */
	public class qb2SingleElementIterator implements qb2I_Iterator
	{
		private var m_element:*;
		
		public function qb2SingleElementIterator(element_nullable:* = null) 
		{
			initialize(element_nullable);
		}
		
		public function initialize(element:*):void
		{
			m_element = element;
		}
		
		public function next():*
		{
			var toReturn:* = m_element;
			
			m_element = null;
			
			return toReturn;
		}
		
	}

}