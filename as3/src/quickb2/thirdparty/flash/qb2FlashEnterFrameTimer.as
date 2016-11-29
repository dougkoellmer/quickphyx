package quickb2.thirdparty.flash 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import quickb2.utils.qb2I_Timer;
	import quickb2.utils.qb2I_TimerListener;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2FlashEnterFrameTimer implements qb2I_Timer
	{
		private const m_sprite:Sprite = new Sprite();
		
		private var m_delegate:qb2I_TimerListener;
		
		private var m_stage:Stage;
		
		public function qb2FlashEnterFrameTimer(stage:Stage) 
		{
			m_delegate = null;
			m_stage = stage;
		}
		
		public function getTickRate():Number
		{
			return 1 / ((Number)(m_stage.frameRate));
		}
		
		public function start(delegate:qb2I_TimerListener):void
		{
			m_delegate = delegate;
			
			m_sprite.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			m_delegate.onTick();
		}
		
		public function stop():void
		{
			m_delegate = null;
			
			m_sprite.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}