package quickb2.display.immediate.color 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Color extends qb2UtilityClass
	{
		public static function channelMantissa(channel:qb2E_ColorChannel, color:int):Number
		{
			var shifted:int = channelHex(channel, color);
			
			return (shifted as Number) / (qb2S_Color.CHANNEL_MAX as Number);
		}
		
		public static function channelHex(channel:qb2E_ColorChannel, color:int):int
		{
			color = color & channel.getMask();
			color >>>= channel.getShift();
			
			return color;
		}
	}
}