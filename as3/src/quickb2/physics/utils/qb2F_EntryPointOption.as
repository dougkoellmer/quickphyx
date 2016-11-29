package quickb2.physics.utils 
{
	import quickb2.lang.*
	import quickb2.lang.foundation.qb2Flag;
	
	import quickb2.lang.foundation.qb2Enum;

	
	/**
	 * @author Doug Koellmer
	 */
	public class qb2F_EntryPointOption extends qb2Flag
	{
		include "../../lang/macros/QB2_FLAG";
		
		public function qb2F_EntryPointOption(bits:uint = 0)
		{
			super(bits);
		}
		
		public static const DEBUG_DRAW:qb2F_EntryPointOption 			= new qb2F_EntryPointOption();
		public static const DEBUG_DRAG:qb2F_EntryPointOption			= new qb2F_EntryPointOption();
		public static const WINDOW_WALLS:qb2F_EntryPointOption  		= new qb2F_EntryPointOption();
		public static const AUTO_STEP:qb2F_EntryPointOption				= new qb2F_EntryPointOption();
		
		public static const ALL:qb2F_EntryPointOption					= qb2Flag.FFFFFFFF(qb2F_EntryPointOption);
	}
}