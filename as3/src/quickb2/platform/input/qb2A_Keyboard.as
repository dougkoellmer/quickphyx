package quickb2.platform.input 
{
	import flash.utils.Dictionary;
	import quickb2.lang.foundation.qb2E_ErrorCode;
	
	import quickb2.lang.qb2_throw;
	import quickb2.lang.foundation.qb2Error;
	import quickb2.event.qb2KeyboardEvent;
	import quickb2.lang.include "../../../lang/macros/QB2_ABSTRACT";;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_Keyboard extends qb2A_InputDevice implements qb2I_Keyboard
	{
		private const m_keyMap:Dictionary     = new Dictionary();
		private const m_history:Vector.<uint> = new Vector.<uint>();
		
		public function qb2A_Keyboard()
		{
			include "../../../lang/macros/QB2_ABSTRACT";
			
			addEventListener(qb2KeyboardEvent.ALL_EVENT_TYPES, keyEvent, null, true);
		}
		
		private function keyEvent(event:qb2KeyboardEvent):void
		{
			var keyCode:uint = event.getKeyCode();
			var down:Boolean = event.getType() == qb2KeyboardEvent.KEY_DOWN;
			
			if ( m_keyMap[keyCode] && !down )
			{
				delete m_keyMap[keyCode];
				var index:int = m_history.indexOf(keyCode);
				if ( index >= 0 )
				{
					m_history.splice(index, 1);
				}
			}
			else if( !m_keyMap[keyCode] && down )
			{
				m_keyMap[keyCode] = true;
				m_history.push(keyCode);
				
				fireQuickCallback();
			}
		}
		
		public function getNumberOfKeysDown():uint
			{  return m_history.length;  }
			
		public function getKeyDownAt(index:uint):uint
			{  return m_history[index];  }
			
		public function getLastKeyDown(... amongTheseOptionalKeys):uint
		{
			var highestKey:uint = 0;
			if ( amongTheseOptionalKeys.length )
			{
				var queries:Vector.<uint> = parseToOneVector(amongTheseOptionalKeys);
				for (var i:int = 0; i < m_history.length; i++) 
				{
					var historyKey:uint = m_history[i];
					
					for (var j:int = 0; j < queries.length; j++) 
					{
						var queryKey:uint = queries[j];
						
						if ( historyKey == queryKey )
						{
							highestKey = queryKey;
							break;
						}
					}
				}
			}
			else
			{
				highestKey = m_history.length ? m_history[m_history.length - 1] : 0;
			}
			
			return highestKey;
		}
		
		public function isKeyDown(... oneOrMoreKeys):Boolean
		{
			var queries:Vector.<uint> = parseToOneVector(oneOrMoreKeys);
			for (var i:int = 0; i < queries.length; i++) 
			{
				var keyCode:uint = queries[i];
				
				if ( m_keyMap[keyCode] )
				{
					return true;
				}
			}
			
			return false;
		}
		
		private function parseToOneVector(array:Array):Vector.<uint>
		{
			var vector:Vector.<uint> = new Vector.<uint>();
			for ( var i:int = 0; i < array.length; i++ )
			{
				var item:Object = array[i];
				
				if ( item is uint )
				{
					vector.push(item as uint);
				}
				else if ( item is Array )
				{
					var subarray:Array = item as Array;
					for (var j:int = 0; j < subarray.length; j++) 
					{
						var subitem:Object = subarray[j];
						if ( subitem is uint )
						{
							vector.push(subitem);
						}
					}
				}
				else if ( item is Vector.<uint> )
				{
					var subvector:Vector.<uint> = item as Vector.<uint>;
					for ( j = 0; j < subvector.length; j++) 
					{
						subitem = subvector[j];
						if ( subitem is uint )
						{
							vector.push(subitem);
						}
					}
				}
			}
			
			return vector;
		}
	}
}