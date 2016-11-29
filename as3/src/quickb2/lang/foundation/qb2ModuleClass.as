package quickb2.lang.foundation 
{
	import quickb2.lang.errors.qb2E_CompilerErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	/**
	 * ...
	 * @author 
	 */
	public class qb2ModuleClass 
	{
		public function qb2ModuleClass() 
		{
			qb2U_Error.throwCode(qb2E_CompilerErrorCode.MODULE_CLASS);
		}
	}
}