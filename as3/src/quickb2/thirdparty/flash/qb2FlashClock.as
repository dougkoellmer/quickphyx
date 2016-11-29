package quickb2.thirdparty.flash 
{
	import quickb2.utils.qb2I_Clock;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2FlashClock implements qb2I_Clock
	{
		public function getMillisecondsSinceAppStart():int 
		{
			return getTimer();
		}
		
		public function getSecondsSinceAppStart():Number 
		{
			return getTimer() / 1000.0;
		}
	}
}