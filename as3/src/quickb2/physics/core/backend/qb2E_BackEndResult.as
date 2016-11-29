package quickb2.physics.core.backend 
{
	import quickb2.lang.foundation.qb2Enum;
	/**
	 * ...
	 * @author ...
	 */
	public class qb2E_BackEndResult extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const SUCCESS:qb2E_BackEndResult			= new qb2E_BackEndResult();
		public static const TRY_AGAIN_SOON:qb2E_BackEndResult	= new qb2E_BackEndResult();
		public static const TRY_AGAIN_LATER:qb2E_BackEndResult	= new qb2E_BackEndResult();
	}
}