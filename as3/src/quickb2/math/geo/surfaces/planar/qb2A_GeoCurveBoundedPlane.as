package quickb2.math.geo.surfaces.planar 
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.curves.qb2F_GeoCurveType;
	import quickb2.math.geo.qb2PU_Geo;
	import quickb2.math.qb2U_Formula;
	import quickb2.math.qb2U_MassFormula;
	import quickb2.utils.prop.qb2PropMap;
	
	
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	import quickb2.math.geo.qb2I_GeoHyperPlane;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;

	
	/**
	 * ...
	 * @author 
	 */
	[qb2_abstract] public class qb2A_GeoCurveBoundedPlane extends qb2A_GeoPlanarSurface
	{
		private static const ORIGIN:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilLine1:qb2GeoLine = new qb2GeoLine();
		
		private var m_boundary:qb2A_GeoCurve = null;
		
		public function qb2A_GeoCurveBoundedPlane()
		{
			include "../../../../lang/macros/QB2_ABSTRACT_CLASS";
		}
		
		protected final override function isContainer():Boolean
		{
			return true;
		}
		
		[qb2_abstract] protected function calcSimpleMomentOfInertia(mass:Number):Number
		{
			return NaN;
		}
		
		public override function calcMomentOfInertia(mass:Number, axis_nullable:qb2I_GeoHyperAxis = null, centerOfMass_out_nullable:qb2GeoPoint = null):Number
		{
			var centerOfMassInertia:Number = this.calcSimpleMomentOfInertia(mass);
			
			return qb2PU_Geo.calcMomentOfInertia2d(this, centerOfMassInertia, mass, axis_nullable, centerOfMass_out_nullable);
		}
		
		protected function setBoundary_protected(curve:qb2A_GeoCurve):void
		{
			this.removeEventListenerFromSubEntity(m_boundary, false);
			
			m_boundary = curve;
			
			this.addEventListenerToSubEntity(m_boundary, true);
		}
		
		public function getBoundary():qb2A_GeoCurve
		{
			return m_boundary;
		}
		
		protected override function copy_protected(otherObject:*):void
		{
			var otherBoundedPlane:qb2A_GeoCurveBoundedPlane = otherObject as qb2A_GeoCurveBoundedPlane;
			
			if ( otherBoundedPlane != null && otherBoundedPlane.m_boundary != null )
			{
				this.m_boundary.copy(otherBoundedPlane.m_boundary);
			}
		}
		
		public override function calcSurfaceArea():Number
		{
			return Math.abs(m_boundary.calcArea(0, 1));
		}
		
		public function calcPerimeter():Number
		{
			return m_boundary.calcLength();
		}
		
		protected override function nextGeometry(progress:int, returnType:Class, progressOffset_out:qb2Integer):qb2A_GeoEntity
		{
			if (qb2U_Type.isKindOf(returnType, qb2A_GeoCurve) )
			{
				if ( m_boundary != null )
				{
					if ( progress == 0 )
					{
						return m_boundary;
					}
					else if ( progress == 1 )
					{
						if ( !qb2F_GeoCurveType.IS_CLOSED.overlaps(m_boundary.getCurveType()) )
						{
							m_boundary.calcPointAtParam(1, s_utilLine1.getPointA());
							m_boundary.calcPointAtParam(0, s_utilLine1.getPointB());
							
							return s_utilLine1;
						}
					}
				}
				
				return null;
			}
			
			return null;
		}
		
		protected override function nextDecomposition(progress:int):qb2A_GeoEntity
		{
			return progress == 0 ? m_boundary : null;
		}
		
		/*public override function convertTo(T:Class):*
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this, "boundary", m_boundary);
			}
			else if ( m_boundary != null )
			{
				if ( qb2U_Type.isKindOf(T, m_boundary.getClass().getNativeType()) )
				{
					var curve:qb2A_GeoCurve = qb2Class.getInstance(T).newInstance();
					curve.copy(m_boundary);
					
					return curve;
				}
				else
				{
					var curveConverted:* = m_boundary.convertTo(T);
					
					if ( curveConverted != null )
					{
						return curveConverted;
					}
				}
			}
			
			return super.convertTo(T);
		}*/
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			if ( m_boundary != null )
			{
				m_boundary.draw(graphics, propertyMap_nullable);
			}
		}
	}
}