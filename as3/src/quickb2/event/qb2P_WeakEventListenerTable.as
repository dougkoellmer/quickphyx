package quickb2.event 
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author 
	 */
	internal class qb2P_WeakEventListenerTable 
	{
		/*private var m_weakTypeMap:Dictionary = null;
		
		internal function dispatchEvent(event:qb2Event):void
		{
			if ( m_weakTypeMap != null )
			{
				var ownerDict:Dictionary = m_weakTypeMap[event.getType().getId()];
				
				if ( ownerDict != null)
				{
					for ( var key:* in ownerDict )
					{
						var weakClosureList:Vector.<rWeakMethodClosure> = ownerDict[key];
				
						for ( var i:int = 0; i < weakClosureList.length; i++) 
						{
							key[weakClosureList[i].listenerName](event);
						}
					}
				}
			}
		}
		
		internal function isEmpty():Boolean
		{
			return m_weakTypeMap == null;
		}
		
		internal function addEventListener(typeId:int, listener:Function, listenerOwner:Object, reserved:Boolean):void
		{
			m_weakTypeMap = m_weakTypeMap ? m_weakTypeMap : new Dictionary(false);
							
			var ownerDict:Dictionary = m_weakTypeMap[typeId];
			
			if ( !ownerDict )
			{
				ownerDict = new Dictionary(true);
				m_weakTypeMap[typeId] = ownerDict;
			}
			
			var weakClosureList:Vector.<rWeakMethodClosure> = ownerDict[listenerOwner];
			
			if ( !weakClosureList )
			{
				weakClosureList = new Vector.<rWeakMethodClosure>();
				ownerDict[listenerOwner] = weakClosureList;
			}
			
			var listenerName:String = rUtils.getFunctionName(listener, listenerOwner);
			
			if ( rUtils.getIndexInWeakClosureList(weakClosureList, listenerName) == -1 )
			{
				var newWeakClosure:rWeakMethodClosure = new rWeakMethodClosure();
				newWeakClosure.listenerName = listenerName;
				newWeakClosure.reserved = reserved;
				weakClosureList.push(newWeakClosure);
			}
		}
		
		internal function hasEventListener(typeId:int):Boolean
		{
			return m_weakTypeMap && m_weakTypeMap[typeId];
		}
		
		internal function clearAllEventListenersForType(typeId:int):void
		{
			if ( m_weakTypeMap != null )
			{
				var ownerDict:Dictionary = m_weakTypeMap[typeId];
				var ownerArray:Array = rUtils.getKeysFromDict(m_weakTypeMap[typeId]);
				for (var i:int = 0; i < ownerArray.length; i++) 
				{
					var weakClosureList:Vector.<rWeakMethodClosure> = ownerDict[ownerArray[i]];
		
					for (var j:int = weakClosureList.length - 1; j >= 0; j-- )
					{
						var listenerName:String = weakClosureList[j].listenerName;
						clearListenerFromWeakTypeMapWithOwner(typeId, listenerName, ownerArray[i], true);
					}
				}
			}
		}
		
		internal function clearAllEventListeners():void
		{
			var typeMapKeys:Array = rUtils.getKeysFromDict(m_weakTypeMap);
			var numKeys:int = typeMapKeys.length;
			for ( var i:int = 0; i < typeMapKeys.length; i++) 
			{
				clearAllWeakEventListenersForType(typeMapKeys[i]);
			}
			
			typeMapKeys = rUtils.getKeysFromDict(m_strongTypeMap);
			for ( i = 0; i < typeMapKeys.length; i++) 
			{
				clearAllStrongEventListenersForType(typeMapKeys[i]);
			}
		}
		
		internal function clearListenerFromWeakTypeMapWithoutOwner(typeId:int, listener:Function, implicitlyRemoving:Boolean):void
		{
			if ( m_weakTypeMap )
			{
				var ownerArray:Array = rUtils.getKeysFromDict(m_weakTypeMap[typeId]);
				for (var i:int = 0; i < ownerArray.length; i++) 
				{
					clearListenerFromWeakTypeMapWithOwner(typeId, listener, ownerArray[i], implicitlyRemoving);
				}
			}
		}
		
		internal function clearListenerFromWeakTypeMapWithOwner(typeId:int, listener_String_or_Function:*, listenerOwner:Object, implicitlyRemoving:Boolean):void
		{
			if ( m_weakTypeMap )
			{
				var ownerDict:Dictionary = m_weakTypeMap[typeId];
				
				if ( ownerDict )
				{
					var closureList:Vector.<rWeakMethodClosure> = ownerDict[listenerOwner] as Vector.<rWeakMethodClosure>;
						
					if ( closureList )
					{
						var listenerName:String = listener_String_or_Function as Function ? rUtils.getFunctionName(listener_String_or_Function as Function, listenerOwner) : listener_String_or_Function as String;
						var index:int = rUtils.getIndexInWeakClosureList(closureList, listenerName);
				
						if ( index >= 0 )
						{
							if ( !(closureList[index].reserved && implicitlyRemoving) )
							{
								closureList.splice(index, 1);
								
								if ( closureList.length == 0 )
								{
									delete ownerDict[listenerOwner];
								}
							}
						}
					}
					
					if ( rUtils.isEmpty(ownerDict) )
					{
						delete m_weakTypeMap[typeId];
					}
				}
				
				if ( rUtils.isEmpty(m_weakTypeMap) )
				{
					m_weakTypeMap = null;
				}
			}
		}*/
		
		/*private static const methodNamesCache:Dictionary = new Dictionary(false);
	
		public static function getFunctionName(listener:Function, listenerOwner:Object):String
		{
			var classDef:Class = (listenerOwner as Object).constructor;
			var methodNames:Vector.<String> = methodNamesCache[classDef];
			
			var listenerName:String = null;
			
			if ( !methodNames )
			{
				methodNames = new Vector.<String>;
				var list:XMLList = describeType(classDef)..method; // <- not a typo...this is xml syntax.
				var listLength:int = list.length();
				for ( var i:int = 0; i < listLength; i++ )
				{
					var name:String = list[i].@name;
					methodNames.push(name);
					
					if ( listenerOwner[name] == listener )
					{
						listenerName = name;
					}
				}
				
				methodNamesCache[classDef] = methodNames;
			}
			
			if ( !listenerName )
			{
				var numNames:int = methodNames.length;
				for ( i = 0; i < numNames; i++ )
				{
					if ( listenerOwner[methodNames[i]] == listener )
					{
						listenerName = methodNames[i];
						break;
					}
				}
			}
			
			if ( !listenerName )
			{
				throw new Error("The given listener is not a member of listenerOwner.");
			}
			
			return listenerName;
		}

		
		
		public static function getIndexInWeakClosureList(list:Vector.<rWeakMethodClosure>, listenerName:String):int
		{
			var listLength:int = list.length;
			for (var i:int = 0; i < listLength; i++) 
			{
				if ( list[i].listenerName == listenerName )
				{
					return i;
				}
			}
			
			return -1;
		}*/
	}
}

/*internal final class rWeakMethodClosure
{
	public var listenerName:String;
	public var reserved:Boolean;
}*/