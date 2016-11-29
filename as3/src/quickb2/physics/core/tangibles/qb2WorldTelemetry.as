package quickb2.physics.core.tangibles 
{
	import quickb2.debugging.profiling.qb2FpsTracker;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2WorldTelemetry 
	{
		private var m_previousTimeStep:Number = 0;
		private var m_currentTimeStep:Number = 0;
		private var m_totalTime:Number = 0;
		private var m_stepCount:int = 0;
		private var m_isStepping:Boolean = false;
		private var m_isInBackEnd:Boolean = false;
		
		private const m_fpsTracker:qb2FpsTracker = new qb2FpsTracker();
		
		public function qb2WorldTelemetry() 
		{
			
		}
		
		internal function onBackEndStepStart():void
		{
			m_isInBackEnd = true;
		}
		
		internal function onBackEndStepComplete():void
		{
			m_isInBackEnd = false;
		}
		
		internal function onStepStart(timeStep:Number):void
		{
			m_currentTimeStep = timeStep;
			m_isStepping = true;
		}
		
		internal function onStepComplete():void
		{
			m_stepCount++;
			m_totalTime += m_currentTimeStep;
			
			m_fpsTracker.update(m_currentTimeStep);
			
			m_previousTimeStep = m_currentTimeStep;
			m_currentTimeStep = 0;
			
			m_isStepping = false;
		}
		
		public function isStepping():Boolean
		{
			return m_isStepping;
		}
		
		public function isSteppingInBackEnd():Boolean
		{
			return m_isInBackEnd;
		}
		
		public function reset():void
		{
			m_stepCount = 0;
			m_totalTime = 0;
		}
		
		public function getFpsTracker():qb2FpsTracker
		{
			return m_fpsTracker;
		}
		
		public function getCurrentTimeStep():Number
		{
			return m_currentTimeStep;
		}
		
		public function getPreviousTimeStep():Number
		{
			return m_previousTimeStep;
		}
		
		public function getTotalSteps():int
		{
			return m_stepCount;
		}
		
		public function getTotalTime():Number
		{
			return m_totalTime;
		}
		
		public function getStepsPerSecond():Number
		{
			return m_fpsTracker.getFramesPerSecond();
		}
	}
}