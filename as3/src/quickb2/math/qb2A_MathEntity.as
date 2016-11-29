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
	import quickb2.event.*;
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.lang.operators.*;

	
	/**
	 * Abstract base class for all mathematical entities.
	 */
	[qb2_abstract] public class qb2A_MathEntity extends Object
	{
		private var m_dispatchBlockCount:int = 0;
		private const m_dispatcher:qb2SimpleEventDispatcher = new qb2SimpleEventDispatcher();
		
		public function qb2A_MathEntity()
		{
			include "../lang/macros/QB2_ABSTRACT_CLASS";
		}
		
		[qb2_virtual] public function clone():*
		{
			var clonedObject:qb2A_MathEntity = new ((this as Object).constructor);
			
			clonedObject.copy_protected(this);
			
			return clonedObject;
		}
		
		[qb2_virtual] protected function copy_protected(otherObject:*):void
		{
		}
		
		private function getDispatchingBlockCount():int
		{
			return m_dispatchBlockCount;
		}
		
		private function setDispatchingBlockCount(count:int):void
		{
			m_dispatchBlockCount = count;
		}
		
		public function getEventDispatcher():qb2SimpleEventDispatcher
		{
			return m_dispatcher;
		}
		
		protected final function addEventListenerToSubEntity(mathEntity:qb2A_MathEntity, dispatchChangedEvent:Boolean):void
		{
			if ( mathEntity == null )  return;
			
			mathEntity.getEventDispatcher().addEventListener(onSubEntityChanged_private);
			
			if ( dispatchChangedEvent )
			{
				this.dispatchChangedEvent();
			}
		}
		
		protected final function removeEventListenerFromSubEntity(mathEntity:qb2A_MathEntity, dispatchChangedEvent:Boolean):void
		{
			if ( mathEntity == null )  return;
			
			mathEntity.getEventDispatcher().removeEventListener(onSubEntityChanged_private);
			
			if ( dispatchChangedEvent )
			{
				this.dispatchChangedEvent();
			}
		}
		
		public final function pushEventDispatchBlock():void
		{
			this.setDispatchingBlockCount(this.getDispatchingBlockCount() + 1);
		}
		
		public final function popEventDispatchBlock():void
		{
			var newCount:int = this.getDispatchingBlockCount() - 1;
			this.setDispatchingBlockCount(newCount);
			
			if ( newCount <= 0 )
			{
				qb2_assert(newCount == 0);
				
				dispatchChangedEvent();
			}
		}
		
		private function onSubEntityChanged_private(entity:qb2A_MathEntity):void
		{
			this.dispatchChangedEvent();
			
			this.onSubEntityChanged(entity);
		}
		
		[qb2_virtual] protected function onSubEntityChanged(entity:qb2A_MathEntity):void
		{
			
		}
		
		[qb2_virtual] protected function onChanged():void
		{
			
		}
		
		protected final function dispatchChangedEvent():void
		{
			if ( this.getDispatchingBlockCount() > 0 )
			{
				return;
			}
			
			this.getEventDispatcher().dispatchEvent(this);
			
			this.onChanged();
		}
	}
}