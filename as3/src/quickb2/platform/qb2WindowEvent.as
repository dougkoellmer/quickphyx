
package quickb2.platform 
{
	import flash.events.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventType;
	import quickb2.lang.*
	import quickb2.debugging.*;
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2WindowEvent extends qb2Event
	{
		public static const RESIZED:qb2EventType = new qb2EventType("RESIZED", qb2WindowEvent);
		
		public function qb2WindowEvent(type_nullable:qb2EventType = null)
		{
			super(type_nullable);
		}
		
		protected override function clean():void
		{
			super.clean();
		}
	}
}