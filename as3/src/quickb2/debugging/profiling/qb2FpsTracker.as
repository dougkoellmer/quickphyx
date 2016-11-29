package quickb2.debugging.profiling 
{
	/**
	 * ...
	 * 
	 * @author 
	 */
	public class qb2FpsTracker
	{
		private var m_frameCount:int = 0;
		private var m_time:Number;
		private var m_frameRate:Number;
		
		private var m_updateRate:Number;
		private var m_updateMode:qb2E_FpsUpdateMode;
		
		public function qb2FpsTracker()
		{
			setUpdateMode(qb2E_FpsUpdateMode.EVERY_N_SECONDS, .5);
		}
		
		public function setUpdateMode(mode:qb2E_FpsUpdateMode, n:Number):void
		{
			m_updateMode = mode;
			m_updateRate = n;
		}
		
		public function update(timeStep:Number):void
		{
			m_frameCount++;
			m_time += timeStep;
			
			if ( m_updateMode == qb2E_FpsUpdateMode.EVERY_N_SECONDS )
			{
				if( m_time >= m_updateRate )
				{
					updateFrameRate();
				}
			}
			else
			{
				if( m_frameCount >= m_updateRate )
				{
					updateFrameRate();
				}
			}
		}
		
		private function updateFrameRate():void
		{
			m_frameRate = Math.round((m_frameCount) / m_time);
					
			m_frameCount = 0;
			m_time = 0;
		}
		
		public function getFramesPerSecond():Number
		{
			return m_frameRate;
		}
	}
}