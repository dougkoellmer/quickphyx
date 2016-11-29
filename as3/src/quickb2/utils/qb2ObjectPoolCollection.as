package quickb2.utils 
{
	import flash.utils.Dictionary;
	import quickb2.lang.types.*;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2ObjectPoolCollection
	{
		private const m_pools:Dictionary = new Dictionary();
		
		public function qb2ObjectPoolCollection() 
		{
			
		}
		
		public function hasPool(clazz:qb2Class):Boolean
		{
			return m_pools[clazz] != null;
		}
		
		public function registerPool(clazz:qb2Class, constructor:qb2I_Constructor, delegate:qb2I_ObjectPoolDelegate = null):void
		{
			m_pools[clazz] = new qb2ObjectPool(constructor, delegate);
		}
		
		public function getPool(clazz:qb2Class):qb2ObjectPool
		{
			var pool:qb2ObjectPool = m_pools[clazz];
			
			return pool;
		}
	}

}