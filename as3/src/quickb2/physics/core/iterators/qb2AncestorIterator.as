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
	import quickb2.utils.iterator.qb2I_ResettableIterator;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2AncestorIterator implements qb2I_ResettableIterator
	{
		private var m_type:Class = null;
		private var m_currObject:qb2A_PhysicsObject = null;
		private var m_originalObject:qb2A_PhysicsObject;
		
		public function qb2AncestorIterator(object:qb2A_PhysicsObject = null, returnType_nullable:Class = null, startWithParent:Boolean = true) 
		{			
			initialize(object, returnType_nullable, startWithParent);
		}
		
		public function initialize(object:qb2A_PhysicsObject, returnType_nullable:Class = null, startWithParent:Boolean = true):void
		{
			if ( object == null )  return;
			
			initialize_private(startWithParent ? object.getParent() : object, returnType_nullable);
		}
		
		private function initialize_private(object:qb2A_PhysicsObject, returnType_nullable:Class):void
		{
			m_currObject = object;
			m_originalObject = m_currObject;
			m_type = returnType_nullable != null ? returnType_nullable : qb2A_PhysicsObject;
		}
		
		public function reset():void
		{
			this.initialize(m_originalObject, m_type);
		}
		
		public function next():*
		{
			var toReturn:qb2A_PhysicsObject = m_currObject;
			
			while ( toReturn != null && (toReturn as m_type) == null )
			{
				toReturn = toReturn.getParent();
			}
			
			if ( toReturn != null )
			{
				m_currObject = toReturn.getParent();
			}
			
			return toReturn;
		}
	}
}