/**
 * Copyright (c) 2011 Doug Koellmer
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package quickb2.event
{
	import flash.utils.Dictionary;
	import quickb2.debugging.logging.*;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.*;
	import quickb2.lang.types.qb2U_Type;

	/**
	 * Base class for any classes that use quickb2's event dispatching system.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2EventDispatcher extends Object implements qb2I_EventDispatcher
	{
		private var m_listenerTable:qb2PI_EventListenerTable = null;
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:qb2EventType, listener:Function, reserved:Boolean = false ):void
		{
			var asMultiType:qb2EventMultiType = type as qb2EventMultiType;
			
			if ( asMultiType != null )
			{
				var numOfMultiTypeChildren:int = asMultiType.m_childrenTypes.length;
				
				for (var i:int = 0; i < numOfMultiTypeChildren; i++) 
				{
					addEventListener(asMultiType.m_childrenTypes[i], listener, reserved);
				}
				
				//--- DRK > Here we're assuming we'll need multiple event listeners, so we're skipping the singular table step.
				if ( m_listenerTable == null )
				{
					m_listenerTable = new qb2P_StrongEventListenerTable();
				}
			}
			else
			{
				if ( m_listenerTable == null )
				{
					m_listenerTable = new qb2P_SingularStrongEventListenerTable();
				}
				else
				{
					if ( m_listenerTable.isFull() )
					{
						var newTable:qb2P_StrongEventListenerTable = new qb2P_StrongEventListenerTable();
						newTable.copy(m_listenerTable);
						m_listenerTable = newTable;
					}
				}
				
				m_listenerTable.addEventListener(type.getId(), listener, reserved);
			}
		}
		
		private function contract1(typeOrListener1:*, typeOrListener2:*):void
		{
			if (	qb2U_Type.isKindOf(typeOrListener1, qb2EventType) && qb2U_Type.isKindOf(typeOrListener2, qb2EventType) ||
					qb2U_Type.isKindOf(typeOrListener1, Function) && qb2U_Type.isKindOf(typeOrListener2, Function) )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT);
			}
		}
		
		private function getType(typeOrListener1:*, typeOrListener2:*):qb2EventType
		{
			if ( qb2U_Type.isKindOf(typeOrListener1, qb2EventType) )
			{
				return typeOrListener1 as qb2EventType;
			}
			else
			{
				return typeOrListener2 as qb2EventType;
			}
		}
		
		private function getListener(typeOrListener1:*, typeOrListener2:*):Function
		{
			if ( qb2U_Type.isKindOf(typeOrListener1, Function) )
			{
				return typeOrListener1 as Function;
			}
			else
			{
				return typeOrListener2 as Function;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListeners(typeOrListener1_nullable:* = null, typeOrListener2_nullable:* = null):void
		{
			contract1(typeOrListener1_nullable, typeOrListener2_nullable);
			
			if ( m_listenerTable == null )  return;
			
			var type:qb2EventType = getType(typeOrListener1_nullable, typeOrListener2_nullable);
			var listener:Function = getListener(typeOrListener1_nullable, typeOrListener2_nullable);
			
			if ( type == null )
			{
				if ( listener == null )
				{
					m_listenerTable.removeAllEventListeners();
				}
				else
				{
					m_listenerTable.removeAllEventListenersForListener(listener);
				}
			}
			else
			{
				var asMultiType:qb2EventMultiType = type as qb2EventMultiType;
				
				if ( asMultiType != null )
				{
					var childCount:int = asMultiType.m_childrenTypes.length;
					
					if ( childCount > 0 )
					{
						for (var i:int = 0; i < childCount; i++) 
						{
							removeEventListeners(asMultiType.m_childrenTypes[i], listener);
						}
					}
					else
					{
						if ( listener == null )
						{
							m_listenerTable.removeAllEventListeners();
						}
						else
						{
							m_listenerTable.removeAllEventListenersForListener(listener);
						}
					}
				}
				else
				{
					if ( listener == null )
					{
						m_listenerTable.removeAllEventListenersForType(type.getId());
					}
					else
					{
						m_listenerTable.removeSpecificEventListener(type.getId(), listener);
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasEventListener(typeOrListener1_nullable:* = null, typeOrListener2_nullable:* = null):Boolean
		{
			contract1(typeOrListener1_nullable, typeOrListener2_nullable);
			
			if ( m_listenerTable == null )  return false;
			
			var type:qb2EventType = getType(typeOrListener1_nullable, typeOrListener2_nullable);
			var listener:Function = getListener(typeOrListener1_nullable, typeOrListener2_nullable);
			
			if ( type != null )
			{
				var asMultiType:qb2EventMultiType = type as qb2EventMultiType;
				
				if ( asMultiType != null )
				{
					var numChildren:int = asMultiType.m_childrenTypes.length;
					
					if ( numChildren > 0 )
					{
						for (var i:int = 0; i < numChildren; i++) 
						{
							if ( this.hasEventListener(asMultiType.m_childrenTypes[i]) )
							{
								return true;
							}
						}
					}
					else
					{
						if ( listener == null )
						{
							return m_listenerTable.hasAnyEventListeners();
						}
						else
						{
							return m_listenerTable.hasEventListenersForListener(listener);
						}
					}
				}
				else
				{
					if ( listener == null )
					{
						return m_listenerTable.hasEventListenersForType(type.getId());
					}
					else
					{
						return m_listenerTable.hasSpecificEventListener(type.getId(), listener);
					}
				}
			}
			else
			{
				if ( listener == null )
				{
					return m_listenerTable.hasAnyEventListeners();
				}
				else
				{
					return m_listenerTable.hasEventListenersForListener(listener);
				}
			}
			
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event:qb2Event):void
		{
			if ( m_listenerTable == null )  return;
			
			if ( event.getType() == null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Event must have a type.");
			}
			
			var beingDispatched:Boolean = event.isBeingDispatched();
			
			if ( !beingDispatched )
			{
				event.m_dispatcher = this;
			}
			else
			{
				event.m_forwarders = event.m_forwarders ? event.m_forwarders : new Vector.<qb2I_EventDispatcher>();
				event.m_forwarderCount++;
				
				if ( event.m_forwarders.length < event.m_forwarderCount )
				{
					event.m_forwarders.push(this);
				}
				else
				{
					event.m_forwarders[event.m_forwarderCount - 1] = this;
				}
			}
			
			m_listenerTable.dispatchEvent(event);
			
			if ( this != event.m_dispatcher )
			{
				event.m_forwarders[event.m_forwarderCount - 1] = null;
				event.m_forwarderCount--;
			}
			else
			{
				if ( event.m_pool != null )
				{
					qb2EventPool.checkIn(event);
				}
			}
		}
	}
}