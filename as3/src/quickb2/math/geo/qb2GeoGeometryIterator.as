package quickb2.math.geo 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.math.geo.bounds.qb2F_GeoBoundingBoxContainment;
	
	/**
	 * 
	 * @author 
	 */
	public class qb2GeoGeometryIterator implements qb2I_Iterator
	{
		private var m_entity:qb2A_GeoEntity = null;
		private var m_progress:int = 0;
		private var m_returnType:Class = null;
		private var m_entity_out:qb2A_GeoEntity = null;
		
		private const m_progressOffset:qb2Integer = new qb2Integer();
		
		public function qb2GeoGeometryIterator(entity_nullable:qb2A_GeoEntity = null, T_extends_qb2A_GeoEntity:Class = null, entity_out_nullable:qb2A_GeoEntity = null)
		{
			initialize(entity_nullable, T_extends_qb2A_GeoEntity, entity_out_nullable);
		}

		public function initialize(entity:qb2A_GeoEntity, T_extends_qb2A_GeoEntity:Class = null, entity_out_nullable:qb2A_GeoEntity = null):void
		{
			m_entity = entity;
			m_progress = 0;
			m_returnType = T_extends_qb2A_GeoEntity ? T_extends_qb2A_GeoEntity : qb2A_GeoEntity;
			m_entity_out = entity_out_nullable;
		}
		
		public function next():*
		{
			m_progressOffset.value = 0;
			
			var next:qb2A_GeoEntity = m_entity.nextGeometry_internal(this.m_progress, this.m_returnType, m_progressOffset);
			
			this.m_progress += m_progressOffset.value;
			
			if ( next != null )
			{
				if ( m_entity_out != null )
				{
					m_entity_out.copy(next);
					
					next = m_entity_out;
				}
			}
			
			this.m_progress++;
			
			return next;
		}
	}
}