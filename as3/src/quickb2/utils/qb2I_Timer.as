package quickb2.utils 
{
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_Timer 
	{
		function start(delegate:qb2I_TimerListener):void;
		
		function stop():void;
		
		function getTickRate():Number;
	}
}