package quickb2.utils 
{
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_ObjectPoolDelegate 
	{
		function onCheckOut(object:Object):void;
		
		function onCheckIn(object:Object):void;
	}
}