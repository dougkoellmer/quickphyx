package quickb2.lang.types 
{
	import quickb2.lang.foundation.qb2AbstractClassEnforcer;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Type
	{
		public static function isNumeric(value:*):Boolean
		{
			return (value is Number) || (value is int) || (value is uint);
		}
		
		public static function isBoolean(value:*):Boolean
		{
			return (value is Boolean);
		}
		
		/**
		 * Evaluates whether object is a type of T (instance of T, interface implementation of T, etc).
		 * Unlike the native 'is' keyword, this works also if object is a Class itself.
		 * 
		 * @author 
		 */
		public static function isKindOf(object:Object, T:Class):Boolean
		{
			if ( object == null )  return false;
			
			var objectAsClass:Class = object as Class;
		
			if ( objectAsClass != null )
			{
				//--- Check the easiest case first.
				if ( objectAsClass === T )
				{
					return true;
				}
				
				//--- Works for checking if a class is a subclass of a base class, but doesn't work for interfaces.
				if ( T.prototype.isPrototypeOf(objectAsClass.prototype) )
				{
					return true;
				}
				
				//--- This checks for objectAsClass being an implementer of T if T is an interface.
				//--- Also just a catch-all for possible unknown problems with above two cases.
				//--- Abstract quickb2 classes (with qb2A_ prefix) have their runtime exception temporarily disabled.
				var isInstance:Boolean = false;
				qb2AbstractClassEnforcer.getInstance().pushDisable();
				{
					try
					{
						//TODO: Cache the testInstance.
						var testInstance:Object = new objectAsClass;
						isInstance = (testInstance as T) != null;
					}
					catch(e:Error){}
				}
				qb2AbstractClassEnforcer.getInstance().popDisable();
				
				return isInstance;
			}
			else
			{
				//---- Faster to do null check of dynamic cast than use the is keyword.
				return (object as T) != null;
			}
		}
		
		/**
		 * Evaluates whether the given class is in the inheritance chain between subClass and superClass, inclusive.
		 * 
		 * @author 
		 */
		public static function isInChain(T:Class, subClass:Class, superClass:Class):Boolean
		{
			return isKindOf(T, superClass) && isKindOf(subClass, T) || isKindOf(T, subClass);
		}
	}
}