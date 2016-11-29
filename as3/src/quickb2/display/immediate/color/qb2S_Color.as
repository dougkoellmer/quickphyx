package quickb2.display.immediate.color 
{
	import quickb2.lang.foundation.qb2SettingsClass;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2S_Color extends qb2SettingsClass
	{
		public static const CHANNEL_MAX:int = 255;
		public static const CHANNEL_BIT_COUNT:int = 8;
		
		public static const CHANNEL_MASK:int = 0xFF;
		
		public static const COLOR_MASK:int = 0x00FFFFFF;
		public static const ALPHA_MASK:int = 0xFF000000;
		
		public static const BLACK:qb2Color			= new qb2Color(0, 0, 0, CHANNEL_MAX);
		public static const RED:qb2Color			= new qb2Color(CHANNEL_MAX, 0, 0, CHANNEL_MAX);
		public static const GREEN:qb2Color			= new qb2Color(0, CHANNEL_MAX, 0, CHANNEL_MAX);
		public static const BLUE:qb2Color			= new qb2Color(0, 0, CHANNEL_MAX, CHANNEL_MAX);
		public static const WHITE:qb2Color			= new qb2Color(CHANNEL_MAX, CHANNEL_MAX, CHANNEL_MAX, CHANNEL_MAX);
		public static const TRANSPARENT:qb2Color	= new qb2Color(0, 0, 0, 0);
	}
}