package quickb2.debugging.testing 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2TestSuite
	{
		private const m_tests:Vector.<qb2I_Test> = new Vector.<qb2I_Test>();
		
		public function qb2TestSuite()
		{
			
		}
		
		public function addTest(test:qb2I_Test):void
		{
			m_tests.push(test);
		}
		
		public function run():qb2TestSuiteResult
		{
			var asserter:qb2Asserter = new qb2Asserter();
			var result:qb2TestSuiteResult = new qb2TestSuiteResult();
			
			for (var i:int = 0; i < m_tests.length; i++)
			{
				var test:qb2I_Test = m_tests[i];
				var assertCount:int = asserter.getAssertCount();
				
				test.onBefore();
				
				try
				{
					test.run(asserter);
				}
				catch (e:qb2AssertError)
				{
					result.addError(test.getName(), asserter.getAssertCount() - assertCount - 1, e);
				}
				
				test.onAfter();
			}
			
			return result;
		}
	}
}