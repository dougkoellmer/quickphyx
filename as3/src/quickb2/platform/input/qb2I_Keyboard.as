package quickb2.platform.input 
{
	[Event(name="KEY_DOWN", type="quickb2.event.qb2KeyboardEvent")]
	[Event(name="KEY_UP",   type="quickb2.event.qb2KeyboardEvent")]
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public interface qb2I_Keyboard extends qb2I_InputDevice
	{
		function getNumberOfKeysDown():uint;
			
		function getKeyDownAt(index:uint):uint;
			
		function getLastKeyDown(... amongTheseOptionalKeys):uint;
		
		function isKeyDown(... oneOrMoreKeys):Boolean;
	}
}