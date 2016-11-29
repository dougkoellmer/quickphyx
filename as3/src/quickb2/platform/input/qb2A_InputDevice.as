package quickb2.platform.input 
{
	import quickb2.event.qb2EventDispatcher;
	import quickb2.event.qb2I_EventDispatcher;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_InputDevice extends qb2EventDispatcher implements qb2I_InputDevice
	{
		public function qb2A_InputDevice()
		{
			include "../../lang/macros/QB2_ABSTRACT_CLASS";
		}
	}
}