package quickb2.math.geo.curves.iterators 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_GeoCompositeCurveIteratorMode extends qb2Enum
	{
		include "../../../../lang/macros/QB2_ENUM";
		
		public static const GEOMETRY:qb2E_GeoCompositeCurveIteratorMode				= new qb2E_GeoCompositeCurveIteratorMode();
		public static const DECOMPOSITION:qb2E_GeoCompositeCurveIteratorMode		= new qb2E_GeoCompositeCurveIteratorMode();
		
		public static function getDefault(mode_nullable:qb2E_GeoCompositeCurveIteratorMode):qb2E_GeoCompositeCurveIteratorMode
		{
			return mode_nullable == null ? GEOMETRY : mode_nullable;
		}
	}
}