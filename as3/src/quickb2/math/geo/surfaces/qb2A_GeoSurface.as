package quickb2.math.geo.surfaces 
{
	import quickb2.lang.errors.*;
	
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2A_GeoEntity;
	
	/**
	 * Abstract base class for all 2d planar surfaces.
	 * 
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_GeoSurface extends qb2A_GeoEntity
	{
		public function qb2A_GeoSurface()
		{
			include "../../../lang/macros/QB2_ABSTRACT_CLASS";
		}
		
		[qb2_abstract] public function calcSurfaceArea():Number {  return NaN;  }
	}
}