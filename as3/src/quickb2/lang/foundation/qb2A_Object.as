package quickb2.lang.foundation 
{
	import quickb2.debugging.logging.*;
	import quickb2.lang.types.*;
	import quickb2.lang.errors.*;
	
	/**
	 * Base class for many quickb2 classes. Declares many foundational methods like clone, copy, convertTo, and more.
	 * 
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_Object extends Object
	{
		/**
		 * Constructing a qb2A_Object directly, without subclassing, results in a runtime exception.
		 */
		public function qb2A_Object()
		{
			include "../macros/QB2_ABSTRACT_CLASS";
		}
		
		/**
		 * Attempts to convert this object to another type "T". (T is taken from C++ templating conventions).
		 * Out of the box, this function supports basic String conversion.  Override this method to return more
		 * verbose String representations, or to do advanced conversions between types with different inheritance
		 * chains.  For example, you could override this function for a Rectangle class and make it so that
		 * myRect.convertTo(Polygon) returns a polygon representation of the rectangle.
		 * 
		 * @param	T The type to convert to.
		 * @return A new instance of the converted type, or null if conversion fails.
		 */
		[qb2_virtual] public function convertTo(T:Class):*
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this);
			}
			
			return this as T;
		}
		
		[qb2_virtual] public function clone():*
		{
			var clonedObject:qb2A_Object = this.getClass().newInstance();
			
			clonedObject.copy_protected(this);
			
			return clonedObject;
		}
		
		[qb2_virtual] protected function copy_protected(otherObject:*):void
		{
		}
		
		public function getClass():qb2Class
		{
			return qb2Class.getInstance((this as Object).constructor);
		}
	}
}