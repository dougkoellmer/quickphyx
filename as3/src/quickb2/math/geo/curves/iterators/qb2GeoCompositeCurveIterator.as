package quickb2.math.geo.curves.iterators 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2GeoCompositeCurve;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2GeoGeometryIterator;
	import quickb2.utils.qb2OptVector;
	
	/**
	 * Returns all non-composite curves that form the leaves of a tree of composite curves.
	 * 
	 * @author 
	 */
	public class qb2GeoCompositeCurveIterator implements qb2I_Iterator
	{
		private var m_stack:Vector.<qb2I_Iterator> = new Vector.<qb2I_Iterator>();
		private var m_mode:qb2E_GeoCompositeCurveIteratorMode;
		
		public function qb2GeoCompositeCurveIterator(curve_nullable:qb2GeoCompositeCurve = null, mode_nullable:qb2E_GeoCompositeCurveIteratorMode = null) 
		{
			initialize(curve_nullable, mode_nullable);
		}
		
		public function initialize(curve:qb2GeoCompositeCurve, mode:qb2E_GeoCompositeCurveIteratorMode):void
		{
			clear();
			
			m_mode = qb2E_GeoCompositeCurveIteratorMode.getDefault(mode);
			
			push(curve);			
		}
		
		private function push(curve:qb2GeoCompositeCurve):void
		{
			var iterator:qb2I_Iterator;
			
			if ( m_mode == qb2E_GeoCompositeCurveIteratorMode.DECOMPOSITION )
			{
				iterator = new qb2GeoDecompositionIterator(curve);
			}
			else
			{
				iterator = new qb2GeoGeometryIterator(curve, qb2A_GeoCurve);
			}
			
			m_stack.push(iterator);
		}
		
		private function pop():void
		{
			m_stack.pop();
		}
		
		private function advance():qb2A_GeoCurve
		{
			if ( m_stack.length == 0 )  return null;
			
			var iterator:qb2I_Iterator = m_stack[m_stack.length - 1];
		
			var curve:qb2A_GeoCurve = iterator.next();
			
			if ( curve != null )
			{
				if ( qb2U_Type.isKindOf(curve, qb2GeoCompositeCurve) )
				{
					push(curve as qb2GeoCompositeCurve);
				}
			}
			else
			{
				pop();
			}
			
			return curve;
		}
		
		private function clear():void
		{
			m_stack.length = 0;
		}
		
		public function next():*
		{
			var toReturn:qb2A_GeoCurve;
			
			do
			{
				toReturn = advance();
			}
			while (toReturn != null && qb2U_Type.isKindOf(toReturn, qb2GeoCompositeCurve) || toReturn == null && m_stack.length > 0 )
			
			if ( toReturn == null )
			{
				clear();
			}
			
			return toReturn;
		}
	}
}