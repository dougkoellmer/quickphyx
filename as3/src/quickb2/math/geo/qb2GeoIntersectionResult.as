package quickb2.math.geo{
	import quickb2.lang.*;
	
	import quickb2.lang.operators.*;
	import quickb2.math.geo.qb2A_GeoEntity;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2GeoIntersectionResult
	{
		private var m_instersections:Vector.<qb2A_GeoEntity> = null;
		
		public function qb2GeoIntersectionResult()
		{
		}
		
		public function getIntersectionCount():int
		{
			return m_instersections != null ? m_instersections.length : 0;
		}
		
		public function getIntersectionAt(index:int):qb2A_GeoEntity
		{
			return m_instersections[index];
		}
	}
}