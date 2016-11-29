package quickb2.physics.core.bridge 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	/**
	 * ...
	 * @author ...
	 */
	public class qb2P_DelayedForce
	{
		private const m_force:qb2GeoVector = new qb2GeoVector();
		private const m_point:qb2GeoVector = new qb2GeoPoint();
		
		private var m_forceType:qb2PE_ForceType;
		
		public function qb2P_DelayedForce() 
		{
			
		}
		
		public function initLinear(forceType:qb2PE_ForceType, point_copied:qb2GeoPoint, vector_copied:qb2GeoVector):void
		{
			m_force.copy(vector_copied);
			m_point.copy(point_copied);
			m_forceType = forceType;
		}
		
		public function initAngular(forceType:qb2PE_ForceType, value:Number):void
		{
			m_forceType = forceType;
			m_force.setX(value);
		}
		
		public function getAngularValue():Number
		{
			return m_force.getX();
		}
		
		public function getPoint():qb2GeoPoint
		{
			return m_point;
		}
		
		public function getVector():qb2GeoVector
		{
			return m_force;
		}
		
		public function getForceType():qb2PE_ForceType
		{
			return m_forceType;
		}
	}
}