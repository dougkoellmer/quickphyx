package quickb2.math.geo.curves.iterators 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	
	import quickb2.math.geo.bounds.qb2F_GeoBoundingBoxContainment;
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	/**
	 * 
	 * @author 
	 */
	public class qb2GeoSamplePointIterator implements qb2I_Iterator
	{
		private var m_curve:qb2A_GeoCurve = null;
		private var m_progress:int = 0;
		private const m_config:qb2GeoSamplePointIteratorConfig = new qb2GeoSamplePointIteratorConfig();
		private var m_point_out:qb2GeoPoint = null;
		
		public function qb2GeoSamplePointIterator(curve_nullable:qb2A_GeoCurve = null, config_copied_nullable:qb2GeoSamplePointIteratorConfig = null, point_out_nullable:qb2GeoPoint = null)
		{
			initialize(curve_nullable, config_copied_nullable, point_out_nullable);
		}
		
		protected function getProgress():int
		{
			return m_progress;
		}

		public function initialize(curve:qb2A_GeoCurve, config_copied:qb2GeoSamplePointIteratorConfig, point_out_nullable:qb2GeoPoint = null):void
		{
			m_curve = curve;
			
			if ( config_copied != null )
			{
				m_config.copy(config_copied);
			}
			else
			{
				m_config.setToDefaults();
			}
			
			m_progress = 0;
			m_point_out = point_out_nullable;
		}
		
		private function clean():void
		{
			m_curve = null;
			m_point_out = null;
		}
		
		public function next():*
		{
			var point:qb2GeoPoint = null;

			if ( m_curve != null )
			{
				if ( m_progress < m_config.pointCount )
				{
					var progressRatio:Number = (m_progress as Number) / ((m_config.pointCount-1) as Number);
					var param:Number = m_config.startParam + (m_config.endParam - m_config.startParam) * progressRatio;
					point = m_point_out == null ? new qb2GeoPoint() : m_point_out;
					m_curve.calcPointAtParam(param, point);
				}
			}
			
			this.m_progress++;
			
			if ( point == null )
			{
				clean();
			}
			
			return point;
		}
	}
}