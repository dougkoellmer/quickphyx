package quickb2.math.geo.curves.iterators 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2GeoGeometryIterator;
	import quickb2.math.geo.qb2I_GeoPointContainer;
	import quickb2.utils.iterator.qb2SingleElementIterator;
	
	/**
	 * Returns a set of points representing a tessellated version of a given set of curves, suitable for rendering
	 * with a straight-line-only graphics API (for example). Correctly accounts for curves that are already tessellated,
	 * for combinations of already-tessellated and curved segments, and when using composite curves.
	 * 
	 * @author 
	 */
	public class qb2GeoCurveTessellator implements qb2I_Iterator
	{
		private const m_singleElementIterator:qb2SingleElementIterator = new qb2SingleElementIterator();
		
		private const m_multiCurveTessellator:qb2GeoMultiCurveTessellator = new qb2GeoMultiCurveTessellator();
		
		public function qb2GeoCurveTessellator(curve_nullable:qb2A_GeoCurve = null, config_copied_nullable:qb2GeoTessellatorConfig = null, point_out_nullable:qb2GeoPoint = null ) 
		{
			this.initialize(curve_nullable, config_copied_nullable, point_out_nullable);
		}
		
		public function initialize(curve:qb2A_GeoCurve, config_copied_nullable:qb2GeoTessellatorConfig = null, point_out_nullable:qb2GeoPoint = null):void
		{
			if ( curve != null )
			{
				m_singleElementIterator.initialize(curve);
				
				m_multiCurveTessellator.initialize(m_singleElementIterator, config_copied_nullable, point_out_nullable);
			}
			else
			{
				m_multiCurveTessellator.initialize(null, null, null);
			}
		}
		
		public function next():*
		{
			return m_multiCurveTessellator.next();
		}
	}
}