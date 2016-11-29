package quickb2.thirdparty.flash 
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import quickb2.event.qb2GlobalEventPool;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventDispatcher;
	import quickb2.platform.qb2I_Window;
	import quickb2.platform.qb2WindowEvent;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2FlashWindow extends qb2EventDispatcher implements qb2I_Window
	{
		private var m_stage:Stage;
		
		public function qb2FlashWindow(stage:Stage) 
		{
			m_stage = stage;
			m_stage.align     = StageAlign.TOP_LEFT;
			m_stage.scaleMode = StageScaleMode.NO_SCALE;
			m_stage.addEventListener(Event.RESIZE, onStageResized, false, 0, true);
		}
		
		private function onStageResized(event:Event):void
		{
			dispatchEvent(qb2GlobalEventPool.checkOut(qb2WindowEvent.RESIZED));
		}
		
		public function getWindowWidth():Number
		{
			return m_stage.stageWidth;
		}
		
		public function getWindowHeight():Number
		{
			return m_stage.stageHeight;
		}
		
		public function getWindowTop():Number
		{
			return 0;
		}
		
		public function getWindowLeft():Number
		{
			return 0;
		}
	}
}