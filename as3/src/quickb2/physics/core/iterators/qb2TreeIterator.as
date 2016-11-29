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

package quickb2.physics.core.iterators
{
	import flash.utils.Dictionary;
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.qb2A_PhysicsObject;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.*;
	
	
	
	/**
	 * Provides a convenient way to traverse a qb2A_PhysicsObjectContainer hierarchy in either level order or depth first order, left or right.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2TreeIterator implements qb2I_Iterator
	{		
		private var m_returnType:Class;
		
		private var m_currentObject:qb2A_PhysicsObject = null;
		private var m_nextObject:qb2A_PhysicsObject = null;
		
		private var m_queueIndex:int = 0;
		private const m_queue:Vector.<qb2A_PhysicsObject> = new Vector.<qb2A_PhysicsObject>();
		
		private var m_order:qb2E_TreeIteratorOrder;
		private var m_skipNextBranch:Boolean = false;
		
		private var m_isLevelOrder:Boolean;
		
		public function qb2TreeIterator(object_nullable:qb2A_PhysicsObject = null, returnType_nullable:Class = null, order_nullable:qb2E_TreeIteratorOrder = null) 
		{
			initialize(object_nullable, returnType_nullable, order_nullable);
		}
		
		public function initialize(object:qb2A_PhysicsObject, returnType_nullable:Class = null, order_nullable:qb2E_TreeIteratorOrder = null):void
		{
			m_order = order_nullable != null ? order_nullable : qb2E_TreeIteratorOrder.DEPTH_FIRST_ORDER_LEFT_TO_RIGHT;
			m_returnType = returnType_nullable ? returnType_nullable : qb2A_PhysicsObject;
			
			if ( m_order == qb2E_TreeIteratorOrder.LEVEL_ORDER_LEFT_TO_RIGHT || m_order == qb2E_TreeIteratorOrder.LEVEL_ORDER_RIGHT_TO_LEFT )
			{
				m_queue.length = 0;
				m_queueIndex = 0;
				m_currentObject = null;
				m_nextObject = object;
				m_isLevelOrder = true;
			}
			else
			{
				m_currentObject = null;
				m_nextObject = object;
				m_isLevelOrder = false;
			}
			
			m_skipNextBranch = false;
		}
			
		public function skipBranch():void
		{
			m_skipNextBranch = true;
		}
		
		public function next():*
		{
			var toReturn:qb2A_PhysicsObject = null;
			
			do
			{
				if ( m_isLevelOrder )
				{
					if ( m_currentObject == null && m_nextObject == null )
					{
						return null;
					}
					
					if ( m_currentObject != null && !m_skipNextBranch)
					{
						if ( qb2U_Type.isKindOf(m_currentObject, qb2A_PhysicsObjectContainer) )
						{
							var toQueue:qb2A_PhysicsObject = null;
							
							if ( m_order == qb2E_TreeIteratorOrder.LEVEL_ORDER_LEFT_TO_RIGHT )
							{
								toQueue = (m_currentObject as qb2A_PhysicsObjectContainer).getFirstChild();
								while ( toQueue != null )
								{
									m_queue.push(toQueue);
									
									toQueue = toQueue.getNextSibling();
								}
							}
							else
							{
								toQueue = (m_currentObject as qb2A_PhysicsObjectContainer).getLastChild();
								
								while ( toQueue != null )
								{
									m_queue.push(toQueue);
									
									toQueue = toQueue.getPreviousSibling();
								}
							}
						}
					}
					
					m_currentObject = m_nextObject;
					toReturn = m_currentObject;
					
					if ( m_queueIndex < m_queue.length )
					{
						m_nextObject = m_queue[m_queueIndex];
						m_queueIndex++;
					}
					else
					{
						m_nextObject = null;
					}
				}
				else
				{
					if ( m_nextObject == null )
					{
						return null;
					}
					
					if ( m_skipNextBranch )
					{
						if ( m_currentObject == null )
						{
							return null;
						}
						else
						{
							m_nextObject = findNextDepthFirstObject(m_currentObject, true);
						}
					}
					
					m_currentObject = m_nextObject;
					
					toReturn = m_currentObject;
					
					if ( m_currentObject != null )
					{
						m_nextObject = findNextDepthFirstObject(m_currentObject, false);
					}
				}
				
				m_skipNextBranch = false;
			}
			while( toReturn != null && !qb2U_Type.isKindOf(toReturn, m_returnType) )
			
			return toReturn;
		}
		
		private function findNextDepthFirstObject(currentObject:qb2A_PhysicsObject, skipBranch:Boolean):qb2A_PhysicsObject
		{
			var next:qb2A_PhysicsObject = currentObject;
			var isLeftToRight:Boolean = m_order == qb2E_TreeIteratorOrder.DEPTH_FIRST_ORDER_LEFT_TO_RIGHT;
			
			if ( qb2U_Type.isKindOf(next, qb2A_PhysicsObjectContainer) )
			{
				if ( !skipBranch )
				{
					next = isLeftToRight ? (next as qb2A_PhysicsObjectContainer).getFirstChild() : (next as qb2A_PhysicsObjectContainer).getLastChild();
				}
			}
			else
			{
				next = next.getNextSibling();
			}
			
			if ( next == null || skipBranch )
			{
				next = m_currentObject;
				
				while ( next != null && (isLeftToRight && next.getNextSibling() == null || !isLeftToRight && next.getPreviousSibling() == null) )
				{								
					next = next.getParent();
				}
				
				if ( next != null )
				{
					next = isLeftToRight ? next.getNextSibling() : next.getPreviousSibling();
				}
			}
			
			return next;
		}
	}
}