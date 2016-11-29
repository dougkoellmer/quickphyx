package quickb2.platform.input 
{
	import quickb2.lang.*
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventMultiType;
	import quickb2.event.qb2EventType;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2KeyboardEvent extends qb2Event
	{
		public static const KEY_DOWN:qb2EventType        	= new qb2EventType("KEY_DOWN",	prototype.constructor);
		public static const KEY_UP:qb2EventType          	= new qb2EventType("KEY_UP",	prototype.constructor);
		
		public static const ALL_EVENT_TYPES:qb2EventType	= new qb2EventMultiType(KEY_DOWN, KEY_UP);
		
		public function qb2KeyboardEvent(type_nullable:qb2EventType = null)
		{
			super(type);
		}
		
		public function getKeyCode():uint
		{
			return m_keyCode;
		}
		qb2_friend var m_keyCode:uint = 0;
		
		public override function clone():qb2Event
		{
			var evt:qb2KeyboardEvent = super.clone() as qb2KeyboardEvent;
			evt.m_keyCode = this.m_keyCode;
			return evt;
		}
		
		protected override function clean():void
		{
			super.clean();
			
			m_keyCode = 0;
		}
	}
}