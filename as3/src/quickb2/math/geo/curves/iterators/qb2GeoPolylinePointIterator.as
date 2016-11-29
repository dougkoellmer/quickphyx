package quickb2.math.geo.curves.iterators 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2GeoPolyline;
	/**
	 * ...
	 * @author 
	 */
	public class qb2GeoPolylinePointIterator implements qb2I_Iterator
	{
		private var m_polyline:qb2GeoPolyline;
		private var m_progress:int;
		
		private const m_startPoint:qb2GeoPoint = new qb2GeoPoint();
		private const m_endPoint:qb2GeoPoint = new qb2GeoPoint();
		
		private var m_hasStartPoint:Boolean;
		private var m_hasEndPoint:Boolean;
		
		public function qb2GeoPolylinePointIterator(polyline_nullable:qb2GeoPolyline = null, startParam:Number = 0, endParam:Number = 1) 
		{
			initialize(polyline_nullable, startParam, endParam);
		}
		
		public function initialize(polyline:qb2GeoPolyline, startParam:Number, endParam:Number):void
		{
			m_polyline = polyline;
			m_progress = 0;
			
			if ( startParam >= endParam )
			{
				m_polyline = null;
				
				return;
			}
			
			if ( startParam <= 0 && endParam >= 1 )
			{
				m_hasStartPoint = false;
				m_hasEndPoint = false;
			}
			else if( startParam > 0 && endParam >= 1 )
			{
				m_hasStartPoint = true;
				m_hasEndPoint = false;
				m_polyline.calcPointAtParam(startParam, m_startPoint);
			}
			else if ( startParam <= 0 && endParam < 1 )
			{
				m_hasStartPoint = false;
				m_hasEndPoint = true;
				m_polyline.calcPointAtParam(endParam, m_endPoint);
			}
			else // if ( startParam > 0 && endParam < 0 )
			{
				m_hasStartPoint = true;
				m_hasEndPoint = true;
				m_polyline.calcPointAtParam(startParam, m_startPoint);
				m_polyline.calcPointAtParam(endParam, m_endPoint);
			}
		}
		
		private function clean():void
		{
			m_polyline = null;
		}
		
		public function next():*
		{
			var point:qb2GeoPoint = null;
			
			if ( m_polyline != null )
			{
				if ( m_progress == 0 )
				{
					if ( m_hasStartPoint )
					{
						point = m_startPoint;
					}
					else
					{
						point = m_polyline.getPointAt(0);
					}
				}
				else
				{
					var modifiedProgress:int = m_hasStartPoint ? m_progress - 1 : m_progress;
					
					if ( modifiedProgress < m_polyline.getPointCount() )
					{
						point = m_polyline.getPointAt(modifiedProgress);
					}
					else
					{
						if ( m_hasEndPoint )
						{
							point = m_endPoint;
						}
					}
				}
			}
			
			m_progress++;
			
			if ( point == null )
			{
				this.clean();
			}
			
			return point;
		}
	}
}