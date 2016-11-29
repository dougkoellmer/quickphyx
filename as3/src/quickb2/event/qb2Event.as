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
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.foundation.*;
	import quickb2.lang.types.*;
	import quickb2.utils.qb2ObjectPoolCollection;
	
	/**
	 * Base class for events that are dispatched by a qb2I_EventDispatcher. You generally override this if you want custom
	 * data or functionality packaged with the event. Sometimes the available userData hook can provide enough flexibility
	 * that subclassing isn't necessary.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2Event
	{
		internal var m_type:qb2EventType;
		internal var m_pool:qb2P_EventPool = null;
		internal var m_forwarderCount:uint = 0;
		internal var m_forwarders:Vector.<qb2I_EventDispatcher> = null;
		private var m_userData:* = null;
		internal var m_dispatcher:qb2I_EventDispatcher;
		
		/**
		 * Returns the user-data provided by setUserData(), or null if user-data was never given.
		 * 
		 * @return Any type of object, including null.
		 */
		public function getUserData():*
		{
			return m_userData;
		}
		
		/**
		 * Put any kind of user-data you want here. This can sometimes serve enough purpose that subclassing isn't necessary.
		 */
		public function setUserData(userData:*):void
		{
			m_userData = userData;
		}
		
		/**
		 * Creates a new event with the given type.  You are encouraged to always use getInstance() instead of instantiating a qb2Event directly.
		 * 
		 * @param	type The event type to use (optional).
		 * @see #getInstance()
		 */
		public function qb2Event(type_nullable:qb2EventType = null)
		{
			this.m_type = type_nullable;
		}
		
		/**
		 * Sets the event's type.
		 */
		public function setType(type:qb2EventType):void
		{
			m_type = type;
		}
		
		/**
		 * Gets the event's type.
		 * 
		 * @return The event's type.
		 */
		public function getType():qb2EventType
		{
			return m_type;
		}
		
		/**
		 * Gets the event's dispatcher, or null if isBeingDispatched() returns false.
		 * 
		 * @return The event's dispatcher, or null.
		 * @see #isBeingDispatched()
		 */
		public function getDispatcher():qb2I_EventDispatcher
		{
			return m_dispatcher;
		}
		
		
		/**
		 * Gets whether this event is currently being dispatched.
		 * 
		 * @return true if event is being dispatched, false if not.
		 */
		public function isBeingDispatched():Boolean
		{
			return m_dispatcher != null;
		}
		
		/**
		 * Gets the number of times this event has been forwarded.  An event is defined as forwarded if it is re-dispatched inside an event handler.
		 * 
		 * @return The number of times the event has been forwarded.
		 */
		public function getForwardCount():int
		{
			return m_forwarderCount;
		}
		
		/**
		 * Gets a specific forwarder of this event.
		 * 
		 * @param	index The index at which to retrieve the forwarder.  0 returns the earliest forwarder, getForwarderCount()-1 returns the latest forwarder.
		 * @return An qb2I_EventDispatcher instance.
		 */
		public function getForwarder(index:uint):qb2I_EventDispatcher
		{
			return m_forwarders[index];
		}
		
		/**
		 * Subclasses should implement this if they want to take advantage of qb2Event's pooling system.
		 * getInstance() calls clean(), giving the event a chance to release old data before being reused.
		 * 
		 * @see #getInstance()
		 */
		[qb2_virtual] protected function clean():void
		{
		}
		
		internal function clean_internal():void
		{
			this.m_forwarderCount = 0;
			this.m_dispatcher = null;
			this.m_type = null;
			this.m_userData = null;
			this.m_pool = null;
			
			this.clean();
		}
	
		protected function copy_protected(otherObject:*):void
		{
			if ( otherObject as qb2Event )
			{
				this.m_dispatcher	= otherObject.m_dispatcher;
				this.m_type			= otherObject.m_type;
				this.m_userData		= otherObject.m_userData;
			}
		}
	}
}