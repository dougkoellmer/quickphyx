package quickb2.display.immediate.color 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2E_ColorChannel extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const RED:qb2E_ColorChannel		= new qb2E_ColorChannel(2);
		public static const GREEN:qb2E_ColorChannel		= new qb2E_ColorChannel(1);
		public static const BLUE:qb2E_ColorChannel		= new qb2E_ColorChannel(0);
		public static const ALPHA:qb2E_ColorChannel		= new qb2E_ColorChannel(3);
		
		private var m_mask:int;
		private var m_shift:int;
		
		public function qb2E_ColorChannel(shiftMultiplier:int)
		{
			m_shift = shiftMultiplier * 8;
			m_mask = 0xFF << m_shift;
		}
		
		public function getMask():int
		{
			return m_mask;
		}
		
		public function getShift():int
		{
			return m_shift;
		}
	}
}