package quickb2.physics.core.iterators 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_TreeIteratorOrder extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const DEPTH_FIRST_ORDER_LEFT_TO_RIGHT:qb2E_TreeIteratorOrder		= new qb2E_TreeIteratorOrder();
		public static const DEPTH_FIRST_ORDER_RIGHT_TO_LEFT:qb2E_TreeIteratorOrder		= new qb2E_TreeIteratorOrder();
		public static const LEVEL_ORDER_LEFT_TO_RIGHT:qb2E_TreeIteratorOrder			= new qb2E_TreeIteratorOrder();
		public static const LEVEL_ORDER_RIGHT_TO_LEFT:qb2E_TreeIteratorOrder			= new qb2E_TreeIteratorOrder();
		
	}
}