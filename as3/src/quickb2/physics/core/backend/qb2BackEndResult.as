package quickb2.physics.core.backend 
{
	import quickb2.lang.foundation.qb2Struct;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2BackEndResult
	{
		private var m_result:qb2E_BackEndResult;
		
		public function set(result:qb2E_BackEndResult):void
		{
			m_result = result;
		}
		
		public function isSuccess():Boolean
		{
			return m_result == qb2E_BackEndResult.SUCCESS;
		}
		
		public function getResult():qb2E_BackEndResult
		{
			return m_result;
		}
	}
}