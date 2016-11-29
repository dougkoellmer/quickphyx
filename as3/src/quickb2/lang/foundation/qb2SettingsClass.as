package quickb2.lang.foundation 
{
	import quickb2.lang.errors.*;
	
	/**
	 * This class simply throws an error if it instantiated.  You can extend this class to enforce noninstantiability.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2SettingsClass extends Object
	{
		public function qb2SettingsClass() 
		{
			qb2U_Error.throwCode(qb2E_CompilerErrorCode.SETTINGS_CLASS);
		}
	}

}