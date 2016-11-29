package quickb2.platform.input 
{
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventMultiType;
	import quickb2.event.qb2EventType;
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2MouseEvent extends qb2Event
	{
		public static const MOUSE_DOWN:qb2EventType				= new qb2EventType("MOUSE_DOWN",			qb2MouseEvent);
		public static const MOUSE_UP:qb2EventType				= new qb2EventType("MOUSE_UP", 				qb2MouseEvent);
		public static const MOUSE_CLICKED:qb2EventType			= new qb2EventType("MOUSE_CLICKED", 		qb2MouseEvent);
		public static const MOUSE_EXITED_SCREEN:qb2EventType	= new qb2EventType("MOUSE_EXITED_SCREEN", 	qb2MouseEvent);
		public static const MOUSE_ENTERED_SCREEN:qb2EventType	= new qb2EventType("MOUSE_ENTERED_SCREEN", 	qb2MouseEvent);
		public static const MOUSE_WHEEL_SCROLLED:qb2EventType	= new qb2EventType("MOUSE_WHEEL_SCROLLED", 	qb2MouseEvent);
		
		internal var m_scrollDelta:int = 0;
		
		public static const ALL_EVENT_TYPES:qb2EventType 		= new qb2EventMultiType
		(
			MOUSE_DOWN, MOUSE_UP, MOUSE_CLICKED, MOUSE_EXITED_SCREEN, MOUSE_ENTERED_SCREEN, MOUSE_WHEEL_SCROLLED
		);
		
		public function qb2MouseEvent(type_nullable:qb2EventType = null)
		{
			super(type_nullable);
		}
		
		public function initialize(scrollDelta:int):void
		{
			m_scrollDelta = scrollDelta;
		}
		
		public function getScrollDelta():int
		{
			return m_scrollDelta;
		}
		
		protected override function copy_protected(source:*):void
		{
			super.copy_protected(source);
			
			var otherEvent:qb2MouseEvent = source;
			
			if ( otherEvent != null )
			{
				this.m_scrollDelta = otherEvent.m_scrollDelta;
			}
		}
	}
}