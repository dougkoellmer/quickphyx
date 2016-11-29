package quickb2.lang.errors 
{
	import quickb2.lang.foundation.*;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Error extends qb2UtilityClass
	{
		public static function throwError(error:Error):void
		{
			var msg:String = error.message;
		
			if ( error as qb2Error )
			{
				msg = "QB2_ERROR: " + msg;
			}
			else
			{
				msg = "ERROR: " + msg;
			}
			
			throw error;
		}
		
		public static function throwCode(errorCode:qb2I_ErrorCode, message:String = null):void
		{
			throwError(new qb2Error(errorCode, message));
		}
	}
}