package quickb2.debugging.gui.components 
{
	import com.bit101.components.RangeSlider;
	import com.bit101.components.Slider;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import quickb2.debugging.gui.qb2S_DebugGui;
	import quickb2.lang.*;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiRangeSlider extends RangeSlider implements qb2I_DebugGuiComponent
	{
		private var m_persistentVariableName:String = null;
		
		public function qb2DebugGuiRangeSlider(persistentKey:String = null, orientation:String = Slider.HORIZONTAL, parent:DisplayObjectContainer = null, xPos:Number = 0, yPos:Number = 0, defaultHandler:Function = null) 
		{
			super(orientation, parent, xPos, yPos, defaultHandler);
			
			m_persistentVariableName = qb2S_DebugGui.createPersistentKey(persistentKey);
		}
		
		public function syncWithPersistentData():void
		{
			/*if ( qb2S_DebugGui.doesPersistentDataExist(m_persistentVariableName) )
			{
				if ( selected != (qb2S_DebugGui.getPersistentData(persistentVariableName) as Boolean) )
				{
					dispatchEvent(cachedClickEvent);
				}
			}*/
		}
		
		private function sliderChanged(evt:Event):void
		{
			
		}
	}
}