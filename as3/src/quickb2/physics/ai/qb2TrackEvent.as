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

package quickb2.physics.ai 
{
	import quickb2.lang.*
	import quickb2.event.*;
	
	import quickb2.physics.ai.qb2Track;
	
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventType;
	

	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2TrackEvent extends qb2Event
	{
		public static const TRACK_MOVED:qb2EventType  = new qb2EventType("TRACK_MOVED", qb2TrackEvent);
		
		qb2_friend var m_track:qb2Track = null;
		
		public function qb2TrackEvent(type_nullable:qb2EventType = null) 
		{
			super(type);
		}
		
		protected override function copy_protected(otherObject:*):void
		{
			this.m_track = otherObject.m_track;
		}
		
		protected override function clean():void
		{
			super.clean();
			
			m_track = null;
		}
		
		public function getTrack():qb2Track
		{
			return m_track;
		}
	}
}