package quickb2.utils 
{
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_Clock 
	{
		function getMillisecondsSinceAppStart():int;
		
		function getSecondsSinceAppStart():Number;
	}
}