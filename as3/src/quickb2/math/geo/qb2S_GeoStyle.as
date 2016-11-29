package quickb2.math.geo 
{
	import quickb2.display.immediate.style.qb2S_StyleProps;
	import quickb2.display.immediate.style.qb2StyleProp;
	import quickb2.lang.foundation.qb2SettingsClass;
	import quickb2.utils.prop.qb2PropPseudoType;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2S_GeoStyle extends qb2S_StyleProps
	{
		public static const POINT_RADIUS:qb2StyleProp		= new qb2StyleProp("POINT_RADIUS",		2.0);
		
		public static const INFINITE:qb2StyleProp			= new qb2StyleProp("INFINITE",			10000.0);
		
		public static const VECTOR_ARROWSIZE:qb2StyleProp	= new qb2StyleProp("VECTOR_ARROWSIZE",	10.0);
		public static const VECTOR_ARROWANGLE:qb2StyleProp	= new qb2StyleProp("VECTOR_ARROWANGLE", Math.PI/2.0);
		
		public static const VECTOR_SHIFT:qb2StyleProp		= new qb2StyleProp("VECTOR_SHIFT",		false);
	}
}