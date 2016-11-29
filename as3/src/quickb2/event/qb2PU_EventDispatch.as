package quickb2.event 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	/**
	 * ...
	 * @author 
	 */
	public class qb2PU_EventDispatch extends qb2UtilityClass
	{
		public static function dispatchEvent(event:qb2Event, listener:Function):void
		{
			if ( listener.length == 0 )
			{
				listener();
			}
			else
			{
				listener(event);
			}
		}
		
		public static function dispatchSimpleEvent(arg_nullable:*, listener:Function):void
		{
			if ( arg_nullable != null && listener.length == 1 )
			{
				listener(arg_nullable);
			}
			else
			{
				listener();
			}
		}
	}
}