package quickb2.math.geo.surfaces.planar 
{
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2GeoCurveBoundedPlane extends qb2A_GeoCurveBoundedPlane
	{
		public function qb2GeoCurveBoundedPlane(curve_nullable:qb2A_GeoCurve = null) 
		{
			this.setBoundary(curve_nullable);
		}
		
		public function setBoundary(curve_nullable:qb2A_GeoCurve):void
		{
			this.setBoundary_protected(curve_nullable);
		}
	}
}