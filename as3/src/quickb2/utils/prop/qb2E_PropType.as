package quickb2.utils.prop 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2E_PropType extends qb2Enum
	{
		include "../../lang/macros/QB2_ENUM";
		
		public static const BOOLEAN:qb2E_PropType = new qb2E_PropType();
		public static const NUMERIC:qb2E_PropType = new qb2E_PropType();
		public static const OBJECT:qb2E_PropType = new qb2E_PropType();
	}
}