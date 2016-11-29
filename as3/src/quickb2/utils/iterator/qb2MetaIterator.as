package quickb2.utils.iterator 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2MetaIterator implements qb2I_Iterator
	{
		private const m_iterators:Vector.<qb2I_Iterator> = new Vector.<qb2I_Iterator>();
		
		private var m_progress:int = 0;
		
		public function qb2MetaIterator(... iterators) 
		{
			this.initialize.apply(this, iterators);
		}
		
		public function initialize(... iterators):void
		{
			m_iterators.length = 0;
			m_progress = 0;
			
			for ( var i:int = 0; i < iterators.length; i++ )
			{
				m_iterators.push(iterators[i]);
			}
		}
		
		private function clean():void
		{
			m_iterators.length = 0;
		}
		
		public function next():*
		{
			if ( m_progress >= m_iterators.length )
			{
				clean();
				
				return null;
			}
			
			var iterator:qb2I_Iterator = m_iterators[m_progress];
			
			var next:* = iterator.next();
			
			if ( next == null )
			{
				m_progress++;
				
				return this.next();
			}
			
			return next;
		}
	}
}