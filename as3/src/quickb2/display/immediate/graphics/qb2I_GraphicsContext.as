package quickb2.display.immediate.graphics
{
	import quickb2.math.qb2TransformStack;
	
	/**
	 * Provides a basic interface for configuring a graphics context.
	 * This does not include any methods for actually drawing to the context.
	 * 
	 * @author
	 */
	public interface qb2I_GraphicsContext
	{		
		function getTransformStack():qb2TransformStack;
		
		function pushParam(eDrawParam:qb2E_DrawParam, value_copied:*):void;
		
		function popParam(eDrawParam:qb2E_DrawParam):void;
		
		function getParam(eDrawParam:qb2E_DrawParam):*;
	}
}