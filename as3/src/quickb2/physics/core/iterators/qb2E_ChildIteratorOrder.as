package quickb2.physics.core.iterators 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_ChildIteratorOrder extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const LEFT_TO_RIGHT:qb2E_ChildIteratorOrder = new qb2E_ChildIteratorOrder();
		public static const RIGHT_TO_LEFT:qb2E_ChildIteratorOrder = new qb2E_ChildIteratorOrder();
	}
}