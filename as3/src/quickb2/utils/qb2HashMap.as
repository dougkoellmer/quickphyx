package quickb2.utils 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author ...
	 */
	public class qb2HashMap 
	{
		private var m_native:Dictionary = null;
		private var m_weakKeys:Boolean = false;
		
		public function qb2HashMap(weakKeys:Boolean = false) 
		{
			m_weakKeys = weakKeys;
			m_native = new Dictionary(m_weakKeys);
		}
		
		public function set(key:*, value:*):void
		{
			m_native[key] = value;
		}
		
		public function get(key:*):*
		{
			return m_native[key];
		}
		
		public function has(key:*):Boolean
		{
			return m_native[key] != null;
		}
		
		public function clear():void
		{
			m_native = new Dictionary(m_weakKeys);
		}
	}
}