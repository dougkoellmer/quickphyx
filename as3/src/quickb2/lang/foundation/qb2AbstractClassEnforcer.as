package quickb2.lang.foundation 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2AbstractClassEnforcer 
	{
		private static var s_instance:qb2AbstractClassEnforcer = new qb2AbstractClassEnforcer();
		
		private var m_stack:int;
		
		public function qb2AbstractClassEnforcer() 
		{
			init();
		}
		
		internal static function startUp():void
		{
			s_instance = new qb2AbstractClassEnforcer();
		}
		
		internal static function shutDown():void
		{
			s_instance = null;
		}
		
		private function init():void
		{
			m_stack = 0;
		}
		
		public static function getInstance():qb2AbstractClassEnforcer
		{
			return s_instance;
		}
		
		public function pushDisable():void
		{
			m_stack++;
		}
		
		public function popDisable():void
		{
			m_stack--;
		}
		
		public function isDisabled():Boolean
		{
			return m_stack > 0;
		}
	}
}