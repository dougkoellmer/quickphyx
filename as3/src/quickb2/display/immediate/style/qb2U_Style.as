package quickb2.display.immediate.style 
{
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.graphics.qb2I_GraphicsContext;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.utils.prop.qb2PropMap;
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Style extends qb2UtilityClass
	{
		public static function populateGraphics(graphics:qb2I_GraphicsContext, propertyMap_nullable:qb2PropMap):void
		{
			if ( propertyMap_nullable == null )  return;
			
			var disableFills:Boolean = propertyMap_nullable.getPropertyOrDefault(qb2S_StyleProps.DISABLE_FILLS);
			
			if ( disableFills )
			{
				graphics.pushParam(qb2E_DrawParam.FILL_COLOR, 0);
			}
			else if( propertyMap_nullable.hasProperty(qb2S_StyleProps.FILL_COLOR) )
			{
				graphics.pushParam(qb2E_DrawParam.FILL_COLOR, propertyMap_nullable.getProperty(qb2S_StyleProps.FILL_COLOR));
			}
			else
			{
				graphics.pushParam(qb2E_DrawParam.FILL_COLOR, graphics.getParam(qb2E_DrawParam.FILL_COLOR));
			}
			
			var disableOutlines:Boolean = propertyMap_nullable.getPropertyOrDefault(qb2S_StyleProps.DISABLE_OUTLINES);
			
			if ( disableOutlines )
			{
				graphics.pushParam(qb2E_DrawParam.LINE_THICKNESS, 0);
			}
			else
			{
				if ( propertyMap_nullable.hasProperty(qb2S_StyleProps.LINE_COLOR) )
				{
					graphics.pushParam(qb2E_DrawParam.LINE_COLOR, propertyMap_nullable.getProperty(qb2S_StyleProps.LINE_COLOR));
				}
				else
				{
					graphics.pushParam(qb2E_DrawParam.LINE_COLOR, graphics.getParam(qb2E_DrawParam.LINE_COLOR));
				}
				
				if ( propertyMap_nullable.hasProperty(qb2S_StyleProps.LINE_THICKNESS) )
				{
					graphics.pushParam(qb2E_DrawParam.LINE_THICKNESS, propertyMap_nullable.getProperty(qb2S_StyleProps.LINE_THICKNESS));
				}
				else
				{
					graphics.pushParam(qb2E_DrawParam.LINE_THICKNESS, graphics.getParam(qb2E_DrawParam.LINE_THICKNESS));
				}
			}
		}
		
		public static function depopulateGraphics(graphics:qb2I_GraphicsContext, propertyMap_nullable:qb2PropMap):void
		{
			if ( propertyMap_nullable == null )  return;
			
			graphics.popParam(qb2E_DrawParam.LINE_COLOR);
			graphics.popParam(qb2E_DrawParam.FILL_COLOR);
			graphics.popParam(qb2E_DrawParam.LINE_THICKNESS);
		}
	}
}