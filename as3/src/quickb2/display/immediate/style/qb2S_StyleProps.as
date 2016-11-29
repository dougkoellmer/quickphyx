package quickb2.display.immediate.style 
{
	import quickb2.lang.foundation.qb2SettingsClass;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2S_StyleProps extends qb2SettingsClass
	{
		public static const FILL_COLOR:qb2StyleProp				= new qb2StyleProp("FILL_COLOR",		0x00000000);
		public static const LINE_COLOR:qb2StyleProp				= new qb2StyleProp("LINE_COLOR",		0xFF000000);
		public static const LINE_THICKNESS:qb2StyleProp			= new qb2StyleProp("LINE_THICKNESS",	1.0);
		
		public static const DISABLE_OUTLINES:qb2StyleProp		= new qb2StyleProp("DISABLE_OUTLINES",	false);
		public static const DISABLE_FILLS:qb2StyleProp			= new qb2StyleProp("DISABLE_FILLS",		false);
		public static const HIDDEN:qb2StyleProp					= new qb2StyleProp("HIDDEN",			false);
	}
}