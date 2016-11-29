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

package quickb2.physics.core.iterators 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.physics.core.*;
	import quickb2.physics.core.tangibles.*;
	
	import quickb2.lang.*;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2ChildIterator implements qb2I_Iterator
	{
		private var m_type:Class = null;
		private var m_currObject:qb2A_PhysicsObject = null;
		private var m_forwardOrder:Boolean = true;
		
		public function qb2ChildIterator(container:qb2A_PhysicsObjectContainer = null, returnType:Class = null, order:qb2E_ChildIteratorOrder = null) 
		{
			initialize(container, returnType, order);
		}
		
		public function initialize(container:qb2A_PhysicsObjectContainer, returnType:Class = null, order:qb2E_ChildIteratorOrder = null):void
		{
			m_type  = returnType ? returnType : qb2A_PhysicsObject;
			order = order ? order : qb2E_ChildIteratorOrder.LEFT_TO_RIGHT;
			
			if ( container )
			{
				switch(order)
				{
					case qb2E_ChildIteratorOrder.LEFT_TO_RIGHT:
					{
						m_currObject = container.getFirstChild();
						m_forwardOrder = true;
						break;
					}
					case qb2E_ChildIteratorOrder.RIGHT_TO_LEFT:
					{
						m_currObject = container.getLastChild();
						m_forwardOrder = false;
						break;
					}
					
					default:
					{
						m_currObject = null;
						m_forwardOrder = true;
						break;
					}
				}
			}
			else if ( !container )
			{
				m_currObject = null;
			}
		}
		
		public function next():*
		{
			var toReturn:qb2A_PhysicsObject = m_currObject;
			
			while ( toReturn && m_type != null && !(toReturn as m_type) )
			{
				toReturn = m_forwardOrder ? toReturn.getNextSibling() : toReturn.getPreviousSibling();
			}
			
			if ( toReturn )
			{
				m_currObject = m_forwardOrder ? toReturn.getNextSibling() : toReturn.getPreviousSibling();
			}
			else
			{
				m_currObject = null;
			}
			
			return toReturn;
		}
	}
}