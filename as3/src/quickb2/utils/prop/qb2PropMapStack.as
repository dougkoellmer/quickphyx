package quickb2.utils.prop 
{
	import quickb2.lang.types.qb2ClosureConstructor;
	import quickb2.utils.qb2ObjectPool;
	import quickb2.utils.qb2OptVector;
	/**
	 * ...
	 * @author 
	 */
	public class qb2PropMapStack 
	{
		private const m_stack:qb2OptVector = new qb2OptVector();
		
		private const m_pool:qb2ObjectPool = new qb2ObjectPool(new qb2ClosureConstructor(function():qb2MutablePropMap
		{
			return new qb2MutablePropMap();
		}));
		
		public function qb2PropMapStack() 
		{
			
		}
		
		public function get():qb2PropMap
		{
			return m_stack.getLength() > 0 ? m_stack.getLast() : null;
		}
		
		public function push(map_copied:qb2PropMap):void
		{
			var newMap:qb2MutablePropMap = m_pool.checkOut();
			
			if ( m_stack.getLength() == 0 )
			{
				newMap.copy(map_copied);
			}
			else
			{
				var topMost:qb2MutablePropMap = m_stack.getLast();
				topMost.concat(map_copied, newMap, qb2E_PropConcatType.OR);
			}
			
			m_stack.push(newMap);
		}
		
		public function pop():void
		{
			m_pool.checkIn(m_stack.pop());
		}
	}
}