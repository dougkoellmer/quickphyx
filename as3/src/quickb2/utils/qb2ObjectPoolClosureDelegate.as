package quickb2.utils 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2ObjectPoolClosureDelegate implements qb2I_ObjectPoolDelegate
	{
		private var m_closure:Function;
		
		public function qb2ObjectPoolClosureDelegate(closure:Function) 
		{
			m_closure = closure;
		}
		
		public function onCheckOut(object:Object):void 
		{
			m_closure.call(null, object);
		}
		
		public function onCheckIn(object:Object):void 
		{
			m_closure.call(null, object);
		}
		
	}

}