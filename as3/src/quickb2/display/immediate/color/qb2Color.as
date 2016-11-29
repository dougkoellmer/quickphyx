package quickb2.display.immediate.color 
{
	import quickb2.math.qb2U_Math;
	
	/**
	 * A convenience wrapper for dealing with 32-bit hexadecimal colors.
	 * The value for each color channel is clamped to 0<=channel<=255.
	 * 
	 * @author 
	 */
	public class qb2Color
	{		
		private var m_rawValue:int;
		
		public function qb2Color(red:int = 0, green:int = 0, blue:int = 0, alpha:int = 0)
		{
			this.set(red, green, blue, alpha);
		}
		
		public function setRawValue(value:int):void
		{
			m_rawValue = value;
		}
		
		public function getRawValue():int
		{
			return m_rawValue;
		}
		
		public function set(red:int, green:int, blue:int, alpha:int):void
		{
			setChannel(qb2E_ColorChannel.RED, red);
			setChannel(qb2E_ColorChannel.GREEN, green);
			setChannel(qb2E_ColorChannel.BLUE, blue);
			setChannel(qb2E_ColorChannel.ALPHA, alpha);
		}
		
		public function setChannel(channel:qb2E_ColorChannel, value:int):void
		{
			value = qb2U_Math.clamp(value, 0, 0xFF);
			
			m_rawValue |= (value << channel.getShift());
		}
		
		public function getChannel(channel:qb2E_ColorChannel):int
		{
			var value:int = m_rawValue & channel.getMask();
			
			value >>>= channel.getShift();
			
			return value;
		}
	}
}