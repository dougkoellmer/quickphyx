package quickb2.utils.bits 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2E_BitwiseOp extends qb2Enum
	{
		include "../../lang/macros/QB2_ENUM";
		
		public static const OR:qb2E_BitwiseOp = new qb2E_BitwiseOp();
		public static const AND:qb2E_BitwiseOp = new qb2E_BitwiseOp();
		public static const AND_NOT:qb2E_BitwiseOp = new qb2E_BitwiseOp();
	}
}