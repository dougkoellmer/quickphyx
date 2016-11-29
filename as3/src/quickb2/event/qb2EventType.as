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
	import quickb2.lang.foundation.qb2A_Object;	
	
	/**
	 * Event types distinguish events.  You might have an ExplosionEvent class that extends qb2Event, but it would be annoying to have further subclasses of
	 * ExplosionEvent called ExplosionStartedEvent and ExplosionEndedEvent.  Rather, you usually want a simple way of distinguishing between instances
	 * of ExplosionEvent itself.  You do this with the qb2EventType class. A qb2EventType takes the place of strings used in the DOM standard to define an event's type.
	 * 
	 * Note that a qb2EventType, by convention, should be allocated as static final/const members of the event class to which they are related.
	 * If you are using the qb2Event class directly, without subclassing, allocate qb2EventTypes as static const members of whatever class makes the most sense.
	 * Instance names should be in all caps, with separate words delimited by underscores, e.g. ExplosionEvent.EXPLOSION_STARTED.
	 * 
	 * Note that a qb2EventType is only tied to a particular event by convention...there's no compile or runtime validation. Setting the event type for an
	 * instance of MySmileyEvent to ExplosionEvent.EXPLOSION_STARTED is perfectly valid.
	 * 
	 * Note also that qb2EventType cannot be subclassed.  Attempting to do so will throw an error.
	 * 
	 * A qb2EventType has several important advantages over using strings, as in the DOM standard.
	 * 1.) A unique, internal, integer-based id is used to do all internal hashing and comparison between types, not strings. Strings are relatively costly to hash and compare.
	 * 2.) A special subclass of qb2EventType, called qb2EventMultiType, allows multiple listeners to be added or removed to a qb2I_EventDispatcher with one call.
	 * 3.) Every time you create a new qb2EventType, you have the opportunity to provide an associated event instance that helps qb2Event::getInstance() efficiently allocate subclasses of qb2Event that are associated with the qb2EventType.
	 * 4.) Strings can conflict between different libraries, while the qb2EventType standard ensures a unique id for every event type.
	 * 
	 */
	public class qb2EventType extends qb2A_Object
	{
		internal static const INVALID_EVENT_TYPE:int = 0;
		
		private static var s_currentId:int = INVALID_EVENT_TYPE;
		private static var s_idForNullType:int = -1; // should always end up being 0, but static initialization order isn't absolutely certain.
		
		private var m_id:int = INVALID_EVENT_TYPE;
		
		private var m_debugName:String = null;
		
		private var m_eventClass:Class = null;
		private var m_eventFactory:qb2I_EventFactory;
		
		/**
		 * Creates a new qb2EventType.
		 * 
		 * @param	debugName A name for the qb2EventType.  This is useful for debugging purposes only, i.e. when using trace(), etc.
		 * @param	T_extends_qb2Event Provide this if you wish qb2Event::getInstance() to return a specific qb2Event subclass.
		 */
		public function qb2EventType(debugName_nullable:String = null, eventClass_nullable:Class = null)
		{
			m_debugName = debugName_nullable;
			
			if ( (this as Object).constructor == qb2EventType )
			{
				qb2EventType.registerType(this, eventClass_nullable);
			}
			else
			{
				if ( (this as Object).constructor != qb2EventMultiType )
				{
					throw new Error("You cannot extend qb2EventType or qb2EventMultiType.");
				}
			}
		}
		
		/**
		 * Returns this type's name for debugging purposes, if it was provided in the constructor.
		 * 
		 * @return A string for the debug name.
		 */
		public function getDebugName():String
		{
			return m_debugName;
		}
		
		/**
		 * Returns the qb2Event subclass that this event type is associated with.
		 * Returns the qb2Event class itself if the event type has no explicit association.
		 * 
		 * @return
		 */
		public function getNativeEventClass():Class
		{
			return m_eventClass;
		}
		
		internal function getEventFactory():qb2I_EventFactory
		{
			return m_eventFactory;
		}
		
		/**
		 * Returns a unique id for this event type, which can be used for compares or whatever.
		 * This id is not guaranteed to be identical for a given type across separate application runs.
		 * 
		 * @return A unique id.s
		 * @private
		 */
		public function getId():int
		{
			return m_id;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function convertTo(T:Class):*
		{
			if ( T === String )
			{
				return m_debugName != null ? m_debugName : super.convertTo(T);
			}
			
			return super.convertTo(T);
		}
		
		private static function registerType(type_nullable:qb2EventType, eventClass_nullable:Class = null):void
		{
			s_currentId++; // ids start at 1;
			
			if ( type_nullable == null )
			{
				s_idForNullType = s_currentId;
			}
			else
			{
				type_nullable.m_id = s_currentId;
			}
			
			type_nullable.m_eventClass = eventClass_nullable ? eventClass_nullable : qb2Event;
			type_nullable.m_eventFactory = new qb2EventFactory(type_nullable.m_eventClass);
		}
	}
}