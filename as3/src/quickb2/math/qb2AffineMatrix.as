package quickb2.math 
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2AffineMatrix extends qb2A_Object implements qb2I_Matrix
	{
		private static const s_tempMatrix:qb2AffineMatrix = new qb2AffineMatrix();
		private static const s_tempPoint:qb2GeoPoint = new qb2GeoPoint();
		
		/**
		 * Although this class represents a 3x3 matrix, the last row will always be the same in practice, so we can save space by omitting it.
		 */
		private const m_matrix:qb2SimpleMatrix = new qb2SimpleMatrix(2, 3);
		
		public function qb2AffineMatrix()
		{
		}
		
		protected override function copy_protected(source:*):void
		{
			if ( qb2U_Type.isKindOf(source, qb2AffineMatrix) )
			{
				qb2U_Matrix.copy((source as qb2AffineMatrix).m_matrix, this.m_matrix);
			}
			else if ( qb2U_Type.isKindOf(source, qb2I_Matrix) )
			{
				qb2U_Matrix.copy(source as qb2I_Matrix, this);
			}
		}
		
		public function invert():void
		{
			qb2U_Matrix.calcInverse(this, this);
		}
		
		public function calcInverse(matrix_out:qb2AffineMatrix):void
		{
			qb2U_Matrix.calcInverse(this, matrix_out);
		}
		
		public function copy(source:*):void
		{
			this.copy_protected(source);
		}
		
		public function concat(matrix:qb2AffineMatrix):void
		{
			qb2U_Matrix.multiply(this, matrix, s_tempMatrix);
			
			this.copy(s_tempMatrix);
		}
		
		public function preConcat(matrix:qb2AffineMatrix):void
		{
			qb2U_Matrix.multiply(matrix, this, s_tempMatrix);
			
			this.copy(s_tempMatrix);
		}
		
		public function setToIdentity():void
		{
			qb2U_Matrix.setToZero(m_matrix);
			
			m_matrix.setMatrixValue(0, 0, 1);
			m_matrix.setMatrixValue(1, 1, 1);
		}
		
		public function setToRotation(radians:Number, axis_nullable:qb2I_GeoHyperAxis = null):void
		{
			var cosValue:Number = 0; 
			var sinValue:Number = 0;
			
			if ( qb2S_Math.FLIPPED_Y )
			{
				radians = -radians;
			}
			
			if ( radians != 0 )
			{
				cosValue = Math.cos(radians);
				sinValue = Math.sin(radians);
				
				m_matrix.setMatrixValue(0, 0, cosValue);
				m_matrix.setMatrixValue(0, 1, sinValue);
				m_matrix.setMatrixValue(1, 0, -sinValue);
				m_matrix.setMatrixValue(1, 1, cosValue);
			}
			else
			{
				cosValue = 1;
				sinValue = 0;
				
				m_matrix.setMatrixValue(0, 0, cosValue);
				m_matrix.setMatrixValue(0, 1, sinValue);
				m_matrix.setMatrixValue(1, 0, sinValue);
				m_matrix.setMatrixValue(1, 1, cosValue);
			}
			
			if ( axis_nullable != null )
			{
				var origin:qb2A_GeoCoordinate = axis_nullable as qb2A_GeoCoordinate;
				m_matrix.setMatrixValue(0, 2, origin.getX());
				m_matrix.setMatrixValue(1, 2, origin.getY());
			}
			else
			{
				m_matrix.setMatrixValue(0, 2, 0);
				m_matrix.setMatrixValue(1, 2, 0);
			}
		}
		
		public function setToTranslation(translation:qb2A_GeoCoordinate, negated:Boolean = false):void
		{
			this.setToIdentity();
			
			var x:Number = negated ? -translation.getX() : translation.getX();
			var y:Number = negated ? -translation.getY() : translation.getY();
			
			m_matrix.setMatrixValue(0, 2, x);
			m_matrix.setMatrixValue(1, 2, y);
		}
		
		public function setToScaling(values:qb2A_GeoCoordinate, origin:qb2GeoPoint):void
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
		}
		
		public function getMatrixColumnCount():int 
		{
			return 3;
		}
		
		public function getMatrixRowCount():int 
		{
			return 3;
		}
		
		public function getMatrixValue(row:int, col:int):Number 
		{
			if ( row == 2 )
			{
				switch(col)
				{
					case 0:
					case 1:
					{
						return 0;
					}
					
					case 2:
					{
						return 1;
					}
				}
			}
			else
			{
				return m_matrix.getMatrixValue(row, col);
			}
			
			return 0;
		}
		
		public function setMatrixValue(row:int, col:int, value:Number):void
		{
			if ( row >= 2 )
			{
				//qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ACCESS, "Cannot edit third row of the affine transform.");
			}
			else
			{
				m_matrix.setMatrixValue(row, col, value);
			}
		}
		
		public function getRawMatrix():qb2SimpleMatrix
		{
			return m_matrix;
		}
		
		public override function convertTo(T:Class):*
		{
			if ( T === String )
			{
				qb2U_ToString.start(this);
				qb2U_ToString.addStringVariable("values", m_matrix.getRawValues().toString(), true);
				qb2U_ToString.end();
			}
			
			return super.convertTo(T);
		}
	}
}