package quickb2.utils.iterator 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2ArrayIterator implements qb2I_Iterator
	{
		private var m_array:Vector.<*>;
		private var m_index:int;
		
		public function qb2ArrayIterator(array_nullable:Vector.<*> = null) 
		{
			initialize(array_nullable);
		}
		
		public function initialize(array:Vector.<*>):void
		{
			m_array = array;
			m_index = 0;
		}
		
		private function clean():void
		{
			m_array = null;
		}
		
		public function next():*
		{
			if ( m_array == null )  return null;
			
			while ( m_array[m_index] == null && m_index < m_array.length )
			{
				m_index++;
			}
			
			var toReturn:* = m_array[m_index];
			
			m_index++;
			
			return toReturn;
		}
	}
}