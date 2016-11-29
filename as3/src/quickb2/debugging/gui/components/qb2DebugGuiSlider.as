package quickb2.debugging.gui.components 
{
	import com.bit101.components.Slider;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import quickb2.debugging.gui.qb2S_DebugGui;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiSlider extends Slider
	{
		private var m_persistentKey:String = null;
		
		public function qb2DebugGuiSlider(persistentKey:String = null, orientation:String = Slider.HORIZONTAL, parent:DisplayObjectContainer = null, xPos:Number = 0, yPos:Number = 0, defaultHandler:Function = null) 
		{
			m_persistentKey = qb2S_DebugGui.createPersistentKey(persistentKey);
			super(orientation, parent, xPos, yPos, defaultHandler);
		}
		
		private function sliderChanged(evt:Event):void
		{
			
		}
	}
}