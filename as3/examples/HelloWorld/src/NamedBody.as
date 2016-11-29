package  
{
	import quickb2.physics.core.tangibles.qb2Body;
	/**
	 * ...
	 * @author 
	 */
	public class NamedBody extends qb2Body
	{
		private var m_name:String;
		
		public function NamedBody(name:String) 
		{
			m_name = name;
		}
		
		public override function convertTo(T:Class):*
		{
			if ( T === String )
			{
				return m_name;
			}
		}
	}
}