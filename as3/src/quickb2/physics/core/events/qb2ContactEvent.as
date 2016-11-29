/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
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

package quickb2.physics.core.events 
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.*;
	import flash.events.*;
	import quickb2.lang.*;
	
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventMultiType;
	import quickb2.event.qb2EventType;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2ContactEvent extends qb2A_ContactEvent
	{
		public static const CONTACT_STARTED:qb2EventType	= new qb2EventType("CONTACT_STARTED",	qb2ContactEvent);
		public static const CONTACT_ENDED:qb2EventType  	= new qb2EventType("CONTACT_ENDED",		qb2ContactEvent);
		public static const PRE_SOLVE:qb2EventType			= new qb2EventType("PRE_SOLVE",			qb2ContactEvent);
		public static const POST_SOLVE:qb2EventType			= new qb2EventType("POST_SOLVE",		qb2ContactEvent);
		public static const ALL_EVENT_TYPES:qb2EventType	= new qb2EventMultiType
		(
			CONTACT_STARTED, CONTACT_ENDED, PRE_SOLVE, POST_SOLVE
		);
	
		public function qb2ContactEvent(type_nullable:qb2EventType = null)
		{
			super(type_nullable);
		}

		protected override function copy_protected(otherObject:*):void
		{
			super.copy_protected(otherObject);
		}
		
		
		protected override function clean():void
		{
			super.clean();
			
		}
	}
}