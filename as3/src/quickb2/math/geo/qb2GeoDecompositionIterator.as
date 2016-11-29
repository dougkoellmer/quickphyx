package quickb2.math.geo 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.math.geo.bounds.qb2F_GeoBoundingBoxContainment;
	
	/**
	 * 
	 * @author 
	 */
	public class qb2GeoDecompositionIterator implements qb2I_Iterator
	{		
		private var m_entity:qb2A_GeoEntity = null;
		private var m_progress:int = 0;
		
		public function qb2GeoDecompositionIterator(entity:qb2A_GeoEntity = null)
		{
			initialize(entity);
		}

		public function initialize(entity:qb2A_GeoEntity):void
		{
			m_entity = entity;
			m_progress = 0;
		}
		
		public function next():*
		{
			var nextEntity:qb2A_GeoEntity = m_entity.nextDecomposition_internal(m_progress);
			this.m_progress++;
			
			return nextEntity;
		}
	}
}