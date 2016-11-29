package  
{
	import quickb2.debugging.testing.qb2A_DefaultTest;
	import quickb2.debugging.testing.qb2Asserter;
	import quickb2.math.geo.curves.iterators.qb2E_GeoCompositeCurveIteratorMode;
	import quickb2.math.geo.curves.iterators.qb2GeoCompositeCurveIterator;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2GeoCompositeCurve;
	import quickb2.math.geo.curves.qb2GeoLine;
	/**
	 * ...
	 * @author 
	 */
	public class CompositeCurveIterationTest extends A_MathTest
	{
		private const m_rootComposite:qb2GeoCompositeCurve = new qb2GeoCompositeCurve();
		private const m_lines:Vector.<qb2GeoLine> = new Vector.<qb2GeoLine>(5);
		
		private function createChildCurves():void
		{
			for ( var i:int = 0; i < m_lines.length; i++ )
			{
				m_lines[i] = new qb2GeoLine();
				
				m_rootComposite.addCurve(m_lines[i]);
			}
		}
		
		private function run_sub(__ASSERTER__:qb2Asserter, mode:qb2E_GeoCompositeCurveIteratorMode):void
		{
			var count:int = 0;
			var iterator:qb2GeoCompositeCurveIterator = new qb2GeoCompositeCurveIterator(m_rootComposite, mode);
			for ( var curve:qb2A_GeoCurve = null; (curve = iterator.next()) != null; )
			{
				__ASSERTER__.assert(curve == m_lines[count]);
				
				count++;
			}
		}
		
		public override function run(__ASSERTER__:qb2Asserter):void
		{
			createChildCurves();
			
			run_sub(__ASSERTER__, qb2E_GeoCompositeCurveIteratorMode.DECOMPOSITION);
			run_sub(__ASSERTER__, qb2E_GeoCompositeCurveIteratorMode.GEOMETRY);
			
			var indexToReplace:int = 2;
			var nestedCompositeA:qb2GeoCompositeCurve = new qb2GeoCompositeCurve(m_lines[indexToReplace]);
			m_rootComposite.setCurveAt(indexToReplace, nestedCompositeA);
			
			run_sub(__ASSERTER__, qb2E_GeoCompositeCurveIteratorMode.DECOMPOSITION);
			run_sub(__ASSERTER__, qb2E_GeoCompositeCurveIteratorMode.GEOMETRY);
			
			var nestedCompositeB:qb2GeoCompositeCurve = new qb2GeoCompositeCurve(m_lines[indexToReplace]);
			nestedCompositeA.set(nestedCompositeB);
			
			run_sub(__ASSERTER__, qb2E_GeoCompositeCurveIteratorMode.DECOMPOSITION);
			run_sub(__ASSERTER__, qb2E_GeoCompositeCurveIteratorMode.GEOMETRY);
		}
	}
}