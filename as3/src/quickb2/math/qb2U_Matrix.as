package quickb2.math 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Matrix extends qb2UtilityClass
	{
		public static function calcInverse(matrix:qb2AffineMatrix, matrix_out:qb2AffineMatrix):Boolean
		{
			var rawIn:Vector.<Number> = matrix.getRawMatrix().getRawValues();
			var rawOut:Vector.<Number> = matrix_out.getRawMatrix().getRawValues();
			
			var a:Number = rawIn[0];
			var b:Number = rawIn[1];
			var c:Number = rawIn[2];
			var d:Number = rawIn[3];
			var e:Number = rawIn[4];
			var f:Number = rawIn[5];
			var g:Number = 0;
			var h:Number = 0;
			var k:Number = 1;
			
			var determinant:Number = a * (e * k - f * h) - b * (k * d - f * g) + c * (d * h - e * g);
			
			if ( determinant == 0 )  return false;
			
			determinant = 1 / determinant;
			
			rawOut[0] = determinant * (e * k - f * h);
			rawOut[1] = determinant * (c * h - b * k);
			rawOut[2] = determinant * (b * f - c * e);
			rawOut[3] = determinant * (f * g - d * k);
			rawOut[4] = determinant * (a * k - c * g);
			rawOut[5] = determinant * (c * d - a * f);
			
			return true;
		}
		
		public static function copy(source:qb2I_Matrix, destination:qb2I_Matrix):void
		{
			for ( var i:int = 0; i < source.getMatrixColumnCount() && i < destination.getMatrixColumnCount(); i++ )
			{
				for ( var j:int = 0; j < source.getMatrixRowCount() && j < destination.getMatrixRowCount(); j++ )
				{
					destination.setMatrixValue(j, i, source.getMatrixValue(j, i));
				}
			}
		}
		
		public static function setToZero(matrix:qb2I_Matrix):void
		{
			for ( var i:int = 0; i < matrix.getMatrixColumnCount(); i++ )
			{
				for ( var j:int = 0; j < matrix.getMatrixRowCount(); j++ )
				{
					matrix.setMatrixValue(j, i, 0);
				}
			}
		}
		
		public static function multiply(matrixA:qb2I_Matrix, matrixB:qb2I_Matrix, matrix_out:qb2I_Matrix):Boolean
		{
			var rowCountA:int = matrixA.getMatrixRowCount();
			var colCountA:int = matrixA.getMatrixColumnCount();
			
			var rowCountB:int = matrixB.getMatrixRowCount();
			var colCountB:int = matrixB.getMatrixColumnCount();
			
			if ( colCountA != rowCountB )
			{
				return false;
			}
			
			for (var k:int = 0; k < colCountB; k++)
			{
				for (var i:int = 0; i < rowCountA; i++)
				{
					var sum:Number = 0;
					
					for (var j:int = 0; j < colCountA; j++)
					{
						sum += matrixA.getMatrixValue(i, j) * matrixB.getMatrixValue(j, k);
					}
					
					matrix_out.setMatrixValue(i, k, sum);
				}
			}
			
			return true;
		}
		
		/*public static NNmatrix multiply(final NNmatrix m1, final NNmatrix m2)
		{
			// weight dimensions
			final int m1Rows = m1.getSize1();
			final int m1Cols = m1.getSize2();
			// input dimensions
			final int m2Rows = m2.getSize1();
			final int m2Cols = m2.getSize2();
			if (m1Cols != m2Rows)
			{
				throw new IllegalArgumentException("Matrices don't match!, m1(" +
						m1Rows + "*" + m1Cols + ") m2(" + m2Rows + "*" + m2Cols +
						")");
			}
			NNmatrix result = new NNmatrix(new double[m1Rows][m2Cols]);
			double sum;
			for (int k = 0; k < m2Cols; k++)
			{
				for (int i = 0; i < m1Rows; i++)
				{
					sum = 0;
					for (int j = 0; j < m1Cols; j++)
					{
						sum += m1.get(i).get(j) * m2.get(j).get(k);
					}
					result.get(i).set(k, sum);
				}
			}
			return result;
		}*/
	}
}