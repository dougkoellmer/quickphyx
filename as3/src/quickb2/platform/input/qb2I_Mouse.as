package quickb2.platform.input 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.event.*;
	
	[Event(name="MOUSE_DOWN",           type="quickb2.event.qb2MouseEvent")]
	[Event(name="MOUSE_UP",             type="quickb2.event.qb2MouseEvent")]
	[Event(name="MOUSE_CLICKED",        type="quickb2.event.qb2MouseEvent")]
	[Event(name="MOUSE_EXITED_SCREEN",  type="quickb2.event.qb2MouseEvent")]
	[Event(name="MOUSE_ENTERED_SCREEN", type="quickb2.event.qb2MouseEvent")]
	[Event(name="MOUSE_WHEEL_SCROLLED", type="quickb2.event.qb2MouseEvent")]
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public interface qb2I_Mouse extends qb2I_InputDevice
	{
		function getCursorX():Number;
		function getCursorY():Number;
		
		function isDown():Boolean;
		
		function isOnScreen():Boolean;
	}
}