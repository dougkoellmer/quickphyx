package quickb2.platform.input 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_Mouse extends qb2A_InputDevice implements qb2I_Mouse
	{
		public function qb2A_Mouse()
		{
			include "../../lang/macros/QB2_ABSTRACT_CLASS";
			
			addEventListener(qb2MouseEvent.ALL_EVENT_TYPES, mouseEvent, true);
		}
		
		private function mouseEvent(event:qb2MouseEvent):void
		{
			if ( event.getType() == qb2MouseEvent.MOUSE_DOWN )
			{
				m_isDown = true;
			}
			else if ( event.getType() == qb2MouseEvent.MOUSE_UP )
			{
				m_isDown = false;
			}
			else if ( event.getType() == qb2MouseEvent.MOUSE_ENTERED_SCREEN )
			{
				m_isOnScreen = true;
			}
			else if ( event.getType() == qb2MouseEvent.MOUSE_EXITED_SCREEN )
			{
				m_isOnScreen = false;
			}
		}
		
		[qb2_abstract] public function getCursorX():Number {  return NaN;  };
		[qb2_abstract] public function getCursorY():Number {  return NaN;  };
		
		public function isDown():Boolean
		{
			return m_isDown;
		}
		private var m_isDown:Boolean = false;
		
		public function isOnScreen():Boolean
		{
			return m_isOnScreen;
		}
		private var m_isOnScreen:Boolean = true;
	}
}