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
	
	/**
	 * This special subclass (the only subclass) of qb2EventType allows you to define multiple event types, useful when frequently adding and removing multiple listeners from a qb2I_EventDispatcher.
	 * The types stored as children of a qb2EventMultiType can even be qb2EventMultiType instances themselves, allowing you to build nested trees of qb2EventTypes.
	 * 
	 * @author Doug Koellmer
	 */
	public final class qb2EventMultiType extends qb2EventType
	{
		internal const m_childrenTypes:Vector.<qb2EventType> = new Vector.<qb2EventType>();
		
		internal static var s_instance:qb2EventMultiType = null;
		
		/**
		 * This factory method returns a singleton of qb2EventMultiType.  The singleton's child array is cleared every time this function is called.
		 * 
		 * @param	... childrenTypes  qb2EventTypes to assign as children to this qb2EventMultiType.
		 * 
		 * @return A singleton qb2EventMultiType.
		 */
		public static function getInstance( ... childrenTypes):qb2EventMultiType
		{
			s_instance = s_instance ? s_instance : new qb2EventMultiType();
			
			s_instance.m_childrenTypes.length = 0;
			var count:int = childrenTypes.length;
			for (var i:int = 0; i < count; i++) 
			{
				s_instance.m_childrenTypes.push(childrenTypes[i]);
			}
			
			return s_instance;
		}
		
		/**
		 * Creates a new qb2EventMultiType instance with the given child types
		 * 
		 * @param	... childrenTypes A list of "child" event types.
		 */
		public function qb2EventMultiType(... childrenTypes) 
		{
			for (var i:int = 0; i < childrenTypes.length; i++) 
			{
				m_childrenTypes.push(childrenTypes[i]);
			}
		}
	}
}