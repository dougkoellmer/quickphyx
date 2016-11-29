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
	import flash.events.*;
	import quickb2.lang.*
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventType;	
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2Prop;
	import quickb2.utils.prop.qb2PropFlags;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2PropEvent extends qb2Event
	{
		public static const PROP_CHANGED:qb2EventType = new qb2EventType("PROP_CHANGED", qb2PropEvent);
		
		private const m_changeFlags:qb2MutablePropFlags = new qb2MutablePropFlags();
		
		public function qb2PropEvent(type_nullable:qb2EventType = null) 
		{
			super(type_nullable);
		}
		
		public function initWithChangedFlags(changeFlags_copied:qb2PropFlags):void
		{
			m_changeFlags.copy(changeFlags_copied);
		}
		
		public function initWithChangedProp(prop:qb2Prop):void
		{
			m_changeFlags.clear();
			m_changeFlags.setBit(prop, true);
		}
		
		public function getChangeFlags():qb2PropFlags
		{
			return m_changeFlags;
		}
		
		protected override function copy_protected(source:*):void
		{
			if ( qb2U_Type.isKindOf(source, qb2PropEvent) )
			{
				var event:qb2PropEvent = source as qb2PropEvent;
			}
		}
		
		protected override function clean():void
		{
			super.clean();
		}
	}
}