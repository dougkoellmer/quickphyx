package quickb2.debugging.profiling 
{
	import quickb2.lang.foundation.qb2U_Time;
	import quickb2.lang.foundation.qb2Util;
	import quickb2.lang.operators.qb2_print;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2Benchmark extends Object
	{
		private var m_name:String;
		private var m_startTime:int;
		
		public function qb2Benchmark(name:String)
		{
			m_name = name;
		}
		
		public function getElapsedTime():int
		{
			return qb2U_Time.getSystemTimeInMilliseconds() - m_startTime;
		}
		
		public function start():void
		{
			m_startTime = qb2U_Time.getSystemTimeInMilliseconds();
			
			if ( m_name != null )
			{
				qb2_print("Started benchmark [" + m_name + "].");
			}
			else
			{
				qb2_print("Started benchmark.");
			}
		}
		
		public function end():void
		{
			if ( m_name != null )
			{
				qb2_print("Ended benchmark [" + m_name + "], elapsedTime=" + this.getElapsedTime() + " milliseconds.");
			}
			else
			{
				qb2_print("Ended benchmark, elapsedTime=" + this.getElapsedTime() + " milliseconds.");
			}
		}
		
		public function runFunction(benchmarkFunction:Function, callCount:int):void
		{
			start();
			{
				for ( var i:int = 0; i < callCount; i++ )
				{
					benchmarkFunction.call();
				}
			}
			end();
		}
	}
}