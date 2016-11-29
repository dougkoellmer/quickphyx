package quickb2.lang.types 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2ClosureConstructor implements qb2I_Constructor
	{
		private var m_closure:Function;
		
		public function qb2ClosureConstructor(closure:Function) 
		{
			m_closure = closure;
		}
		
		public function newInstance():*
		{
			return m_closure.call();
		}
	}
}