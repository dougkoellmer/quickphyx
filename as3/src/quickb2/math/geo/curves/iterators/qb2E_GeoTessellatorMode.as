package quickb2.math.geo.curves.iterators 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_GeoTessellatorMode extends qb2Enum
	{
		include "../../../../lang/macros/QB2_ENUM";
		
		public static const BY_SEGMENT_LENGTH:qb2E_GeoTessellatorMode	= new qb2E_GeoTessellatorMode();
		public static const BY_POINT_COUNT:qb2E_GeoTessellatorMode		= new qb2E_GeoTessellatorMode();
		
		public static function getDefault(mode_nullable:qb2E_GeoTessellatorMode = null):qb2E_GeoTessellatorMode
		{
			return mode_nullable == null ? BY_SEGMENT_LENGTH : mode_nullable;
		}
	}
}