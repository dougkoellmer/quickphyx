package quickb2.debugging.testing 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2Asserter
	{
		private var m_assertCount:int;
		
		public function assert(condition:Boolean, message_nullable:String = null):void
		{
			m_assertCount++;
			
			if ( !condition )
			{
				throw new qb2AssertError(message_nullable);
			}
		}
		
		public function getAssertCount():int
		{
			return m_assertCount;
		}
	}
}