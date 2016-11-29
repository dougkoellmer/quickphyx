package quickb2.physics.utils 
{
	import quickb2.lang.*
	import quickb2.lang.foundation.qb2Flag;
	
	import quickb2.lang.foundation.qb2Enum;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2F_SliceOption extends qb2Flag
	{
		include "../../../lang/macros/QB2_FLAG";
		
		public function qb2F_SliceOption(bits:uint = 0)
		{
			super(bits);
		}
		
		public static const REPLACE_OBJECT_WITH_SLICES:qb2F_SliceOption 			= new qb2F_SliceOption();
		public static const TRANSFER_JOINTS_TO_SLICES:qb2F_SliceOption  			= new qb2F_SliceOption();
	}
}