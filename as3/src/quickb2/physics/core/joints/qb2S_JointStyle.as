package quickb2.physics.core.joints 
{
	import quickb2.lang.foundation.qb2SettingsClass;
	import quickb2.math.geo.qb2S_GeoStyle;
	import quickb2.utils.prop.qb2PropPseudoType;
	
	import quickb2.display.immediate.style.*;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2S_JointStyle extends qb2S_StyleProps
	{
		public static const PSEUDOTYPE_ANCHOR:qb2PropPseudoType				= new qb2PropPseudoType();
		public static const ANCHOR_RADIUS:qb2StyleProp						= new qb2StyleProp("ANCHOR_RADIUS", 2.0);
		
		public static const PSEUDOTYPE_ARROW:qb2PropPseudoType				= new qb2PropPseudoType();
		public static const ARROW_SIZE:qb2StyleProp							= new qb2StyleProp("ARROW_SIZE", 10.0);
		public static const ARROW_ANGLE:qb2StyleProp						= new qb2StyleProp("ARROW_ANGLE", Math.PI / 2.0);
		
		public static const PSEUDOTYPE_SPRINGBASE:qb2PropPseudoType			= new qb2PropPseudoType();
		public static const SPRINGBASE_WIDTH:qb2StyleProp					= new qb2StyleProp("SPRINGBASE_WIDTH", 10.0);
		public static const SPRINGBASE_LENGTHRATIO:qb2StyleProp				= new qb2StyleProp("SPRINGBASE_LENGTHRATIO", 0.5);
		
		public static const PSEUDOTYPE_SPRING:qb2PropPseudoType				= new qb2PropPseudoType();
		public static const SPRING_WIDTH:qb2StyleProp						= new qb2StyleProp("SPRING_WIDTH", 10.0);
		public static const SPRING_COILCOUNT:qb2StyleProp					= new qb2StyleProp("SPRING_COILCOUNT", 5);
		
		public static const DASH_LENGTH:qb2StyleProp						= new qb2StyleProp("DASH_LENGTH", 5.0);
	}
}