package quickb2.math.geo 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	
	/**
	 * ...
	 * @author
	 */
	public class qb2GeoPolygonAnalyzer implements qb2I_Iterator
	{
		private static const INV_3:Number = 1.0 / 3.0;
		
		private const m_point1:qb2GeoPoint = new qb2GeoPoint();
		private const m_point2:qb2GeoPoint = new qb2GeoPoint();
		private const m_point3:qb2GeoPoint = new qb2GeoPoint();
		
		private const m_firstPoint:qb2GeoPoint = new qb2GeoPoint();
		private const m_secondPoint:qb2GeoPoint = new qb2GeoPoint();
		
		private const m_utilVector1:qb2GeoVector = new qb2GeoVector();
		private const m_utilVector2:qb2GeoVector = new qb2GeoVector();
		
		private var m_mass:Number;
		private var m_area:Number;
		private var m_isConvex:Boolean;
		private var m_isPositive:Boolean;
		private var m_momentOfInertia:Number;
		private const m_centerOfMass:qb2GeoPoint = new qb2GeoPoint();
		
		private var m_hasSteppedAtLeastOnce:Boolean;
		
		private var m_progress:int;
		
		private var m_tolerance:qb2GeoTolerance;
		
		private var m_pointIterator:qb2I_Iterator;
		
		public function qb2GeoPolygonAnalyzer(pointIterator_nullable:qb2I_Iterator = null, mass:Number = 0, tolerance_nullable:qb2GeoTolerance = null)
		{
			initialize(pointIterator_nullable, mass, tolerance_nullable);
		}
		
		public function run():void
		{
			while ( this.next() != null ){}
		}
		
		public function initialize(pointIterator:qb2I_Iterator, mass:Number = 0, tolerance_nullable:qb2GeoTolerance = null):void
		{
			m_pointIterator = pointIterator;
			
			m_area = 0;
			m_isConvex = true;
			m_isPositive = false;
			m_hasSteppedAtLeastOnce = false;
			m_progress = 0;
			m_momentOfInertia = 0;
			m_centerOfMass.zeroOut();
			m_mass = 0;
			
			m_tolerance = qb2GeoTolerance.getDefault(tolerance_nullable);
		}
		
		private function clean():void
		{
			m_pointIterator = null;
			m_tolerance = null;
		}
		
		public function getPolygonArea():Number
		{
			return Math.abs(m_area);
		}
		
		public function isConvexPolygon():Boolean
		{
			return m_isConvex;
		}
		
		public function isClockwisePolygon():Boolean
		{
			return m_area >= 0;
		}
		
		public function getMomentOfIntertia():Number
		{
			return m_momentOfInertia;
		}
		
		public function getCenterOfMass():qb2GeoPoint
		{
			return m_centerOfMass;
		}
		
		public function getMass():Number
		{
			return m_mass;
		}
		
		public function step(point1:qb2GeoPoint, point2:qb2GeoPoint, point3:qb2GeoPoint):void
		{
			var D:Number = point2.getX() * point3.getY() - point2.getY() * point3.getX();
			var triangleArea:Number = 0.5 * D;
			m_area += triangleArea;
			
			if ( m_mass > 0 )
			{
				m_utilVector1.zeroOut();
				m_utilVector1.copy(point2);
				m_utilVector1.translateBy(point3);
				m_utilVector1.scaleByNumber(triangleArea * INV_3);
				m_centerOfMass.translateBy(m_utilVector1);
				
				var ex1:Number = point2.getX(), ey1:Number = point2.getY();
				var ex2:Number = point3.getX(), ey2:Number = point3.getY();
				var intx2:Number = ex1*ex1 + ex2*ex1 + ex2*ex2;
				var inty2:Number = ey1*ey1 + ey2*ey1 + ey2*ey2;
				m_momentOfInertia += (.25 * INV_3 * D) * (intx2 + inty2);
			}
			
			//--- Determine if polygon remains convex at the i-th corner.
			if ( m_isConvex )
			{
				point2.calcDelta(point1, m_utilVector1);
				point3.calcDelta(point2, m_utilVector2);
				
				var cross:Number = m_utilVector1.getX() * m_utilVector2.getY() - m_utilVector2.getX() * m_utilVector1.getY();
				var subIsPositive:Boolean = cross > 0;
				
				if ( !m_hasSteppedAtLeastOnce )
				{
					m_isPositive = subIsPositive;
				}
				else if (m_isPositive != subIsPositive)
				{
					m_isConvex = false;
				}
			}
			
			m_hasSteppedAtLeastOnce = true;
		}
		
		public function finish():void
		{
			if ( m_area > 0 )
			{
				m_centerOfMass.scaleByNumber( 1.0 / m_area);
				m_momentOfInertia *= m_mass / m_area;
			}
			else
			{
				m_centerOfMass.zeroOut();
				m_momentOfInertia = 0;
			}
		}
		
		public function next():*
		{
			var point:qb2GeoPoint = m_pointIterator.next();
			
			m_progress++;
			
			if ( point != null )
			{
				if ( m_progress == 1 )
				{
					m_point1.copy(point);
					m_firstPoint.copy(point);
				}
				else if( m_progress == 2 )
				{
					m_point2.copy(point);
					
					m_secondPoint.copy(point);
				}
				else
				{
					m_point3.copy(point);
					
					step(m_point1, m_point2, m_point3);
					
					m_point1.copy(m_point2);
					m_point2.copy(m_point3);
				}
			}
			else
			{
				step(m_point1, m_point2, m_firstPoint);
				step(m_point2, m_firstPoint, m_secondPoint);
				
				finish();
			}
			
			return point;
		}
	}
}