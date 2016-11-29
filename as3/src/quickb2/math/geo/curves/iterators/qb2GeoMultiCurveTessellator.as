package quickb2.math.geo.curves.iterators 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2F_GeoCurveType;
	import quickb2.math.geo.curves.qb2GeoCompositeCurve;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2GeoGeometryIterator;
	import quickb2.math.geo.qb2GeoIntersectionOptions;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoPointContainer;
	import quickb2.math.qb2U_Math;
	import quickb2.utils.iterator.qb2MetaIterator;
	import quickb2.utils.iterator.qb2SingleElementIterator;
	
	/**
	 * Returns a set of points representing a tessellated version of a given set of curves, suitable for rendering
	 * with a straight-line-only graphics API (for example). Correctly accounts for curves that are already tessellated,
	 * for combinations of already-tessellated and curved segments, and when using composite curves.
	 * 
	 * @author 
	 */
	public class qb2GeoMultiCurveTessellator implements qb2I_Iterator
	{
		private var m_curveIterator:qb2I_Iterator;
		private var m_point_out:qb2GeoPoint;
		
		private const m_endPoint:qb2GeoPoint = new qb2GeoPoint();
		private const m_firstPoint:qb2GeoPoint = new qb2GeoPoint();
		private const m_previousPoint:qb2GeoPoint = new qb2GeoPoint();
		private const m_returnPoint:qb2GeoPoint = new qb2GeoPoint();
		private var m_nextPoint:qb2GeoPoint;
		
		private var m_returnedFirstPoint:Boolean;
		private var m_justSwitchedCurves:Boolean;
		
		private var m_currentPointIterator:qb2I_Iterator;
		
		//--- DRK > This cannot be instantiated at construction time because we get into an infinite recursion of sorts.
		private var m_nestedTessellator:qb2GeoMultiCurveTessellator = null;
		private const m_samplePointIterator:qb2GeoSamplePointIterator = new qb2GeoSamplePointIterator();
		private const m_geometryIterator:qb2GeoGeometryIterator = new qb2GeoGeometryIterator();
		private const m_compositeCurveIterator:qb2GeoCompositeCurveIterator = new qb2GeoCompositeCurveIterator();
		
		private const m_singleElementIterator:qb2SingleElementIterator = new qb2SingleElementIterator();
		private const m_metaIterator:qb2MetaIterator = new qb2MetaIterator();
		
		private const m_samplePointConfig:qb2GeoSamplePointIteratorConfig = new qb2GeoSamplePointIteratorConfig();
		private const m_tessellationConfig:qb2GeoTessellatorConfig = new qb2GeoTessellatorConfig();
		private const m_intersectionOptions:qb2GeoIntersectionOptions = new qb2GeoIntersectionOptions();
		
		public function qb2GeoMultiCurveTessellator(curveIterator_nullable:qb2I_Iterator = null, config_copied_nullable:qb2GeoTessellatorConfig = null, point_out_nullable:qb2GeoPoint = null ) 
		{
			this.initialize(curveIterator_nullable, config_copied_nullable, point_out_nullable);
		}
		
		public function initialize(curveIterator:qb2I_Iterator, config_copied_nullable:qb2GeoTessellatorConfig = null, point_out_nullable:qb2GeoPoint = null):void
		{
			if (config_copied_nullable != null )
			{
				m_tessellationConfig.copy(config_copied_nullable);
			}
			else
			{
				m_tessellationConfig.setToDefaults();
			}
			
			m_intersectionOptions.tolerance.equalPoint = m_tessellationConfig.pointOverlapTolerance;
			
			m_curveIterator = curveIterator;
			m_point_out = point_out_nullable;
			
			m_returnedFirstPoint = false;
			m_justSwitchedCurves = false;
			
			m_nextPoint = this.advance();
			m_firstPoint.copy(m_nextPoint);
		}
		
		public function next():*
		{
			if ( m_nextPoint != null )
			{
				if ( m_justSwitchedCurves )
				{
					m_justSwitchedCurves = false;
					
					if ( m_returnedFirstPoint )
					{
						if ( m_previousPoint.calcIsIntersecting(m_nextPoint, m_intersectionOptions) )
						{
							m_nextPoint = advance();
						}
					}
					else
					{
						m_returnedFirstPoint = true;
					}
				}
				
				m_previousPoint.copy(m_nextPoint);
			}
			
			var toReturn:qb2GeoPoint = null;
			if ( m_nextPoint != null )
			{
				toReturn = m_returnPoint
				toReturn.copy(m_nextPoint);
			}
			
			m_nextPoint = this.advance();
			
			if ( toReturn != null && m_nextPoint == null )
			{
				if ( !m_tessellationConfig.repeatEndpointForClosedCurves )
				{
					if ( m_firstPoint.calcIsIntersecting(toReturn, m_intersectionOptions) )
					{
						toReturn = null;
					}
				}
			}
			
			return toReturn;
		}
		
		private function advance():qb2GeoPoint
		{
			var nextPoint:qb2GeoPoint = null;
			
			do
			{
				if ( m_currentPointIterator != null )
				{
					nextPoint = m_currentPointIterator.next();
					
					if ( nextPoint == null )
					{
						m_currentPointIterator = null;
					}
					else
					{
						break;
					}
				}
				
				if ( m_currentPointIterator == null && m_curveIterator != null )
				{
					var curve:qb2A_GeoCurve = m_curveIterator.next();
					m_justSwitchedCurves = true;
					
					if ( curve != null )
					{
						var curveType:qb2F_GeoCurveType = curve.getCurveType();
						var isClosed:Boolean = qb2F_GeoCurveType.IS_CLOSED.overlaps(curve.getCurveType());
						
						var endPoint:qb2GeoPoint = null;
						
						if ( qb2F_GeoCurveType.IS_TESSELLATED.overlaps(curveType) )
						{
							if ( isClosed && m_tessellationConfig.repeatEndpointForClosedCurves )
							{
								m_geometryIterator.initialize(curve, qb2GeoPoint, m_endPoint);
								endPoint = m_geometryIterator.next();
								
								m_geometryIterator.initialize(curve, qb2GeoPoint, m_point_out);
								m_singleElementIterator.initialize(endPoint);
								m_metaIterator.initialize(m_geometryIterator, m_singleElementIterator);
								
								m_currentPointIterator = m_metaIterator;
							}
							else
							{
								m_geometryIterator.initialize(curve, qb2GeoPoint, m_point_out);
								
								m_currentPointIterator = m_geometryIterator;
							}
						}
						else if ( qb2U_Type.isKindOf(curve, qb2GeoCompositeCurve) )
						{
							m_compositeCurveIterator.initialize(curve as qb2GeoCompositeCurve, qb2E_GeoCompositeCurveIteratorMode.DECOMPOSITION);
							m_nestedTessellator = m_nestedTessellator != null ? m_nestedTessellator : new qb2GeoMultiCurveTessellator();
							m_nestedTessellator.initialize(m_compositeCurveIterator, m_tessellationConfig, m_point_out);
							
							if ( isClosed && m_tessellationConfig.repeatEndpointForClosedCurves )
							{
								endPoint = m_endPoint;
								curve.calcPointAtParam(0, endPoint);
								
								m_singleElementIterator.initialize(endPoint);
								m_metaIterator.initialize(m_nestedTessellator, m_singleElementIterator);
								
								m_currentPointIterator = m_metaIterator;
							}
							else
							{
								m_currentPointIterator = m_nestedTessellator;
							}
						}
						else
						{
							m_samplePointConfig.startParam = 0;
							
							if ( m_tessellationConfig.mode == qb2E_GeoTessellatorMode.BY_SEGMENT_LENGTH )
							{
								m_samplePointConfig.pointCount = Math.floor(curve.calcLength() / m_tessellationConfig.targetSegmentLength);
								
							}
							else
							{
								m_samplePointConfig.pointCount = m_tessellationConfig.targetPointCount;
							}
							
							m_samplePointConfig.pointCount = qb2U_Math.clamp(m_samplePointConfig.pointCount, m_tessellationConfig.minPointsPerCurvedSegment, m_tessellationConfig.maxPointsPerCurvedSegment);
								
							if ( isClosed )
							{
								if ( m_tessellationConfig.repeatEndpointForClosedCurves )
								{
									m_samplePointConfig.endParam = 1;
									m_samplePointConfig.pointCount++;
								}
								else
								{
									m_samplePointConfig.endParam = 1 - (1 / ((m_samplePointConfig.pointCount) as Number));
								}
							}
							else
							{
								if ( m_tessellationConfig.mode == qb2E_GeoTessellatorMode.BY_SEGMENT_LENGTH )
								{
									if ( m_samplePointConfig.pointCount < m_tessellationConfig.maxPointsPerCurvedSegment )
									{
										m_samplePointConfig.pointCount++;
									}
								}
								
								m_samplePointConfig.endParam = 1;
							}
							
							m_samplePointIterator.initialize(curve, m_samplePointConfig, m_point_out);
							
							m_currentPointIterator = m_samplePointIterator;
						}
					}
					else
					{
						m_curveIterator = null;
					}
				}
			}
			while ( m_currentPointIterator != null && m_curveIterator != null )
			
			return nextPoint;
		}
	}
}