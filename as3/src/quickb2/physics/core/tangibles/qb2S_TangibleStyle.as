package quickb2.physics.core.tangibles 
{
	import quickb2.display.immediate.style.qb2S_StyleProps;
	import quickb2.display.immediate.style.qb2StyleProp;
	import quickb2.lang.foundation.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.qb2S_GeoStyle;
	import quickb2.utils.prop.qb2PropPseudoType;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2S_TangibleStyle extends qb2S_StyleProps
	{
		private static const DEFUALT_POINT_RADIUS:Number = 2.0;
		
		public static const PSEUDOTYPE_BACKENDREP:qb2PropPseudoType = new qb2PropPseudoType();
		
		public static const PSEUDOTYPE_VERTEX:qb2PropPseudoType = new qb2PropPseudoType();
		public static const VERTEX_RADIUS:qb2StyleProp = new qb2StyleProp("VERTEX_RADIUS", DEFUALT_POINT_RADIUS);
		
		public static const PSEUDOTYPE_CENTROID:qb2PropPseudoType = new qb2PropPseudoType();
		public static const CENTROID_RADIUS:qb2StyleProp = new qb2StyleProp("CENTROID_RADIUS", DEFUALT_POINT_RADIUS);
		
		public static const PSEUDOTYPE_POSITION:qb2PropPseudoType = new qb2PropPseudoType();
		public static const POSITION_RADIUS:qb2StyleProp = new qb2StyleProp("POSITION_RADIUS", DEFUALT_POINT_RADIUS);
		
		public static const SHOW_CIRCLE_SPOKE:qb2StyleProp = new qb2StyleProp("SHOW_CIRCLE_SPOKE", true);
		
		public static const PSEUDOTYPE_STATIC:qb2PropPseudoType = new qb2PropPseudoType();
	}
}