package quickb2.debugging.testing 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2TestSuiteResult 
	{
		private const m_errors:Vector.<qb2TestSuiteResultEntry> = new Vector.<qb2TestSuiteResultEntry>();
		
		public function qb2TestSuiteResult() 
		{
			
		}
		
		public function addError(testName:String, id:int, error:Error):void
		{
			m_errors.push(new qb2TestSuiteResultEntry(testName, id, error));
		}
		
		public function convertToString():String
		{
			var asString:String = "";
			
			if ( m_errors.length > 0 )
			{
				for ( var i:int = 0; i < m_errors.length; i++ )
				{
					var error:qb2TestSuiteResultEntry = m_errors[i];
					
					asString += error.convertToString() + "\n";
				}
			}
			else
			{
				asString = "All tests succeeded.";
			}
			
			return asString;
		}
		
		public function getErrorCount():int
		{
			return m_errors.length;
		}
		
		public function getError(index:int):qb2TestSuiteResultEntry
		{
			return m_errors[index];
		}
	}
}