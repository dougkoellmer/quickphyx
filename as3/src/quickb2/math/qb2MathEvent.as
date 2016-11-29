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

package quickb2.math
{
	import quickb2.math.*;
	import flash.events.*;
	import quickb2.lang.*
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventType;
	
	public class qb2MathEvent extends qb2Event 
	{
		public static const ENTITY_UPDATED:qb2EventType = new qb2EventType("ENTITY_UPDATED", qb2MathEvent);
		
		private var m_entity:qb2A_MathEntity = null;
		
		public function qb2MathEvent(type_nullable:qb2EventType = null) 
		{ 
			super(type_nullable);
		}
		
		public function initialize(entity:qb2A_MathEntity):void
		{
			m_entity = entity;
		}
		
		public override function clone():* 
		{ 
			var clonedEvent:qb2MathEvent = super.clone() as qb2MathEvent;
			
			return clonedEvent;
		}
		
		protected override function copy_protected(otherObject:*):void
		{
			super.copy_protected(otherObject);
			
			var otherMathEvent:qb2MathEvent = otherObject as qb2MathEvent;
			
			if ( otherMathEvent )
			{
				this.m_entity = otherMathEvent.m_entity;
			}
		}
		
		protected override function clean():void
		{
			super.clean();
			
			m_entity = null;
		}
		
		public function getEntity():qb2A_MathEntity
		{
			return m_entity;
		}
	}
}