package quickb2.math 
{
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.lang.types.qb2U_Type;
	
	/**
	 * @author 
	 */
	public class qb2SimpleMatrix extends qb2A_Object implements qb2I_Matrix
	{
		private var m_values:Vector.<Number>;
		private var m_rowCount:int;
		
		public function qb2SimpleMatrix(rowCount:int, colCount:int) 
		{
			m_values = new Vector.<Number>(rowCount * colCount, true);
			m_rowCount = rowCount;
		}
		
		public function getRawValues():Vector.<Number>
		{
			return m_values;
		}
		
		public override function clone():*
		{
			return new qb2SimpleMatrix(this.getMatrixRowCount(), this.getMatrixColumnCount());
		}
		
		protected override function copy_protected(source:*):void
		{
			if ( qb2U_Type.isKindOf(source, qb2I_Matrix) )
			{
				qb2U_Matrix.copy(source as qb2I_Matrix, this);
			}
		}
		
		public function copy(source:*):void
		{
			this.copy_protected(source);
		}
		
		public function getMatrixColumnCount():int 
		{
			return m_values.length / m_rowCount;
		}
		
		public function getMatrixRowCount():int 
		{
			return m_rowCount;
		}
		
		public function getMatrixValue(row:int, col:int):Number 
		{
			return m_values[this.getMatrixColumnCount() * row + col];
		}
		
		public function setMatrixValue(row:int, col:int, value:Number):void
		{
			m_values[this.getMatrixColumnCount() * row + col] = value;
		}
	}
}