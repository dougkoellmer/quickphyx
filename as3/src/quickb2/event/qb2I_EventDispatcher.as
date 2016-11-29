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
	public interface qb2I_EventDispatcher
	{
		/**
		 * Registers a listener for an event type.
		 * 
		 * @param	type The event type. This is generally given as a static const member of a subclass of qb2Event, e.g. ExplosionEvent.EXPLOSION_STARTED.
		 * @param	listener The listener function that processes the event. The function must accept an qb2Event as its only parameter and return nothing.
		 * @param	reserved Determines whether this listener can be removed implicitly by a call to qb2EventDispatcher::removeAllEventListeners().  If true,
		 * 			it cannot be removed implicitly, but only explicitly, by a call to qb2EventDispatcher::removeEventListeners() with a reference to the function.
		 */
		function addEventListener(type:qb2EventType, listener:Function, reserved:Boolean = false):void;
		
		/**
		 * Removes event listeners by type, by listener, by both, or by neither. The last case, where both parameters are null, removes all event listeners.
		 * Note that in order to remove a "reserved" listener, you must explicitly provide a reference to the listener. You may provide the type and listener
		 * as parameters in any order, or just either one individually as the first parameter.
		 */
		function removeEventListeners(typeOrListener1_nullable:* = null, typeOrListener2_nullable:* = null):void;
		
		/**
		 * Determines whether this dispatcher has any listeners for the given type and/or listener. If both the type and listener
		 * given are null, the function determines whether there exist any event listeners for any type at all.
		 */
		function hasEventListener(typeOrListener1_nullable:* = null, typeOrListener2_nullable:* = null):Boolean;

		/**
		 * Dispatches the given event. If the event is already in use (i.e. event.isBeingDispatched() returns true), it becomes forwarded.
		 * 
		 * @param	event The event to dispatch (or forward).
		 */
		function dispatchEvent(event:qb2Event):void;
	}
}