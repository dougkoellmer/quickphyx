package quickb2.event 
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author 
	 */
	internal class qb2P_StrongEventListenerTable implements qb2PI_EventListenerTable
	{
		private const m_typeMap:Dictionary = new Dictionary(false);
		
		public function copy(other:qb2PI_EventListenerTable):void
		{
			var singular:qb2P_SingularStrongEventListenerTable = other as qb2P_SingularStrongEventListenerTable;
			
			if ( singular.getClosure().m_listener != null )
			{
				var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[singular.getEventTypeId()];
				
				if ( closureList == null )
				{
					closureList = new Vector.<qb2P_StrongMethodClosure>();
					m_typeMap[singular.getEventTypeId()] = closureList;
				}
				
				closureList.push(singular.getClosure().clone());
				
				m_typeMap[singular.getEventTypeId()] = closureList;
			}
		}
		
		public function isFull():Boolean
		{
			return false;
		}
		
		public function dispatchEvent(event:qb2Event):void
		{
			if ( m_typeMap == null )  return;
			
			var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[event.getType().getId()];
			
			if ( closureList == null )  return;
		
			for (var i:int = 0; i < closureList.length; i++) 
			{
				qb2PU_EventDispatch.dispatchEvent(event, closureList[i].m_listener);
			}
		}
		
		private static function getIndexInClosureList(list:Vector.<qb2P_StrongMethodClosure>, listener:Function):int
		{
			var listLength:int = list.length;
			
			for (var i:int = listLength-1; i >= 0; i--) 
			{
				if ( list[i].m_listener == listener )
				{
					return i;
				}
			}
			
			return -1;
		}
		
		public function addEventListener(typeId:int, listener:Function, reserved:Boolean):void
		{
			//m_typeMap = m_typeMap != null ? m_typeMap : new Dictionary(false);
		
			var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[typeId];
			
			if ( closureList == null )
			{
				closureList = new Vector.<qb2P_StrongMethodClosure>();
				m_typeMap[typeId] = closureList;
			}
			
			var newClosure:qb2P_StrongMethodClosure = new qb2P_StrongMethodClosure(listener, reserved);
			
			closureList.push(newClosure);
		}
		
		public function hasEventListenersForType(typeId:int):Boolean
		{
			return m_typeMap != null && m_typeMap[typeId] != null
		}
		
		public function hasAnyEventListeners():Boolean
		{
			if ( m_typeMap == null )  return false;
			
			for each ( var typeId:int in m_typeMap )
			{
				var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[typeId];
				
				if ( closureList == null )  continue;
				
				if ( closureList.length > 0 )  return true;
			}
			
			return false;
		}
		
		public function removeAllEventListenersForListener(listener:Function):void
		{
			if ( m_typeMap == null )  return;
			
			for each ( var typeId:int in m_typeMap )
			{
				var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[typeId];
				
				if ( closureList == null )  continue;
				
				for ( var i:int = closureList.length-1; i >= 0; i-- )
				{
					if ( closureList[i].m_listener == listener )
					{
						removeSpecificEventListener_private(typeId, closureList[i].m_listener, false, i);
					}
				}
			}
		}
		
		public function removeAllEventListenersForType(typeId:int):void
		{
			if ( m_typeMap == null )  return;
		
			var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[typeId];
			
			if ( closureList == null )  return;
		
			for ( var i:int = closureList.length-1; i >= 0; i-- )
			{
				removeSpecificEventListener_private(typeId, closureList[i].m_listener, true, i);
			}
		}
		
		public function removeAllEventListeners():void
		{
			if ( m_typeMap == null )  return;
			
			for each ( var typeId:int in m_typeMap )
			{
				removeAllEventListenersForType(typeId);
			}
		}
		
		public function removeSpecificEventListener(typeId:int, listener:Function):void
		{
			removeSpecificEventListener_private(typeId, listener, false, -1);
		}
		
		public function hasEventListenersForListener(listener:Function):Boolean 
		{
			if ( m_typeMap == null )  return false;
			
			for each ( var typeId:int in m_typeMap )
			{
				var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[typeId];
				
				if ( closureList == null )  continue;
				
				for ( var i:int = closureList.length-1; i >= 0; i-- )
				{
					if ( closureList[i].m_listener == listener )
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		public function hasSpecificEventListener(typeId:int, listener:Function):Boolean 
		{
			//--- Clear the listener from the strong type map if it exists.
			if ( m_typeMap == null )  return false;
		
			var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[typeId];
			
			if ( closureList == null )  return false;
			
			var index:int = getIndexInClosureList(closureList, listener);
			
			return index >= 0;
		}
		
		private function removeSpecificEventListener_private(typeId:int, listener:Function, implicitlyRemoving:Boolean, hintIndex:int):void
		{
			//--- Clear the listener from the strong type map if it exists.
			if ( m_typeMap == null )  return;
		
			var closureList:Vector.<qb2P_StrongMethodClosure> = m_typeMap[typeId];
			
			if ( closureList == null )  return;
			
			var index:int = hintIndex >= 0 ? hintIndex : getIndexInClosureList(closureList, listener);
			
			if ( index >= 0 )
			{
				if ( !(closureList[index].m_reserved && implicitlyRemoving) )
				{							
					closureList.splice(index, 1);
					
					if ( closureList.length == 0 )
					{
						delete m_typeMap[typeId];
					}
				}
			}
		}
	}
}