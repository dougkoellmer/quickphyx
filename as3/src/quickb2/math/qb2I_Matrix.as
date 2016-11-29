package quickb2.math 
{	
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_Matrix
	{
		function getMatrixColumnCount():int;
		function getMatrixRowCount():int;
		function getMatrixValue(row:int, col:int):Number;
		function setMatrixValue(row:int, col:int, value:Number):void;
	}
}