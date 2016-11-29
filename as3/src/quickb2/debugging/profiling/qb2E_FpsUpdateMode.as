package quickb2.debugging.profiling 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2E_FpsUpdateMode extends qb2Enum
	{
		include "../../lang/macros/QB2_ENUM";
		
		public static const EVERY_N_FRAMES:qb2E_FpsUpdateMode = new qb2E_FpsUpdateMode();
		public static const EVERY_N_SECONDS:qb2E_FpsUpdateMode = new qb2E_FpsUpdateMode();
	}
}