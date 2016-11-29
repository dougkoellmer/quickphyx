package quickb2.display.immediate.graphics 
{
	/**
	 * ...
	 * @author
	 */
	public interface qb2I_GraphicsCommands extends qb2I_GraphicsContext
	{
		function clearBuffer():void;
		
		function moveTo(point:qb2I_DrawPoint):void;
		
		function drawLineTo(point:qb2I_DrawPoint):void;
		
		function drawQuadCurveTo(controlPoint:qb2I_DrawPoint, anchorPoint:qb2I_DrawPoint):void;
		
		function drawCubicCurveTo(controlPoint1:qb2I_DrawPoint, controlPoint2:qb2I_DrawPoint, anchorPoint:qb2I_DrawPoint):void;
		
		function drawCircle(point_nullable:qb2I_DrawPoint, radius:Number):void;
		
		function drawLine(point1:qb2I_DrawPoint, point2:qb2I_DrawPoint):void;
	}
}