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
	
	import quickb2.math.geo.*;
	import flash.events.*;
	import quickb2.lang.*
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventMultiType;
	import quickb2.event.qb2EventType;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2SubContactEvent extends qb2A_ContactEvent
	{
		public static const SUB_CONTACT_STARTED:qb2EventType 	= new qb2EventType("SUB_CONTACT_STARTED",	qb2SubContactEvent);
		public static const SUB_CONTACT_ENDED:qb2EventType  	= new qb2EventType("SUB_CONTACT_ENDED",		qb2SubContactEvent);
		public static const SUB_PRE_SOLVE:qb2EventType       	= new qb2EventType("SUB_PRE_SOLVE", 		qb2SubContactEvent);
		public static const SUB_POST_SOLVE:qb2EventType      	= new qb2EventType("SUB_POST_SOLVE",		qb2SubContactEvent);
		
		public static const ALL_EVENT_TYPES:qb2EventType 		= new qb2EventMultiType
		(
			SUB_CONTACT_STARTED,
			SUB_CONTACT_ENDED,
			SUB_PRE_SOLVE,
			SUB_POST_SOLVE
		);
		
		public function qb2SubContactEvent(type_nullable:qb2EventType = null)
		{
			super(type_nullable);
		}
		
		
		protected override function clean():void
		{
			super.clean();
			
		}
	}
}