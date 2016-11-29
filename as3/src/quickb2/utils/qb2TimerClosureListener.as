package quickb2.utils 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2TimerClosureListener implements qb2I_TimerListener
	{
		private var m_closure:Function;
		
		public function qb2TimerClosureListener(closure:Function) 
		{
			m_closure = closure;
		}
		
		public function onTick():void
		{
			m_closure.call();
		}
	}
}