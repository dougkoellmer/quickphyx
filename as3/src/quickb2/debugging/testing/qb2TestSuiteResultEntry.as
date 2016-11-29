package quickb2.debugging.testing 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2TestSuiteResultEntry
	{
		private var m_testName:String;
		private var m_error:Error;
		private var m_id:int;
		
		public function qb2TestSuiteResultEntry(testName:String, id:int, error:Error) 
		{
			m_testName = testName;
			m_error = error;
			m_id = id;
		}
		
		public function convertToString():String
		{
			var asString:String = m_testName + " failed at assert " + m_id + ".";
			
			if ( m_error.message != null )
			{
				asString += " " + m_error.message;
			}
			
			return asString;
		}
	}
}