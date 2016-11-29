package quickb2.event 
{
	public interface qb2PI_EventListenerTable 
	{
		function dispatchEvent(event:qb2Event):void;
		
		
		function addEventListener(typeId:int, listener:Function, reserved:Boolean):void;
		
		
		function hasEventListenersForListener(listener:Function):Boolean;
		
		function hasEventListenersForType(typeId:int):Boolean;
		
		function hasSpecificEventListener(typeId:int, listener:Function):Boolean;
		
		function hasAnyEventListeners():Boolean;
		
		
		function removeAllEventListenersForListener(listener:Function):void;
		
		function removeAllEventListenersForType(typeId:int):void;
		
		function removeAllEventListeners():void;
		
		function removeSpecificEventListener(typeId:int, listener:Function):void;
		
		
		function isFull():Boolean;
		
		function copy(other:qb2PI_EventListenerTable):void;
	}
}