package quickb2.math 
{
	import quickb2.lang.types.qb2ClosureConstructor;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	import quickb2.utils.qb2ObjectPool;
	import quickb2.utils.qb2OptVector;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2TransformStack 
	{
		private static const s_utilMatrix:qb2AffineMatrix = new qb2AffineMatrix();
		
		private const m_matrixPool:qb2ObjectPool = new qb2ObjectPool(new qb2ClosureConstructor(function():qb2AffineMatrix
		{
			return new qb2AffineMatrix();
		}));
		
		private const m_stack:qb2OptVector = new qb2OptVector();
		
		private const m_current:qb2AffineMatrix = new qb2AffineMatrix();
		
		public function qb2TransformStack() 
		{
			
		}
		
		public function get():qb2AffineMatrix
		{
			return m_current;
		}
		
		public function pushAndSet(matrix_copied:qb2AffineMatrix):void
		{
			var newMatrix:qb2AffineMatrix = m_matrixPool.checkOut();
			newMatrix.copy(m_current);
			m_stack.push(newMatrix);
			
			m_current.copy(matrix_copied);
		}
		
		public function pushAndConcatTranslation(vector_copied:qb2A_GeoCoordinate):void
		{
			s_utilMatrix.setToTranslation(vector_copied);
			pushAndConcat(s_utilMatrix);
		}
		
		public function pushAndConcatRotation(radians:Number, axis_nullable:qb2I_GeoHyperAxis = null):void
		{
			s_utilMatrix.setToRotation(radians, axis_nullable);
			pushAndConcat(s_utilMatrix);
		}
		
		public function pushAndConcat(matrix_copied:qb2AffineMatrix):void
		{
			var newMatrix:qb2AffineMatrix = m_matrixPool.checkOut();
			newMatrix.copy(m_current);
			m_stack.push(newMatrix);
			
			qb2U_Matrix.multiply(newMatrix, matrix_copied, m_current);
		}
		
		public function pop():void
		{
			var popped:qb2AffineMatrix = m_stack.pop() as qb2AffineMatrix;
			m_current.copy(popped);
			m_matrixPool.checkIn(popped);
		}
	}
}