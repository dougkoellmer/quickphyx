package quickb2.lang.types 
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import quickb2.lang.errors.*;
	
	import quickb2.lang.operators.*;
	
	
	
	/**
	 * Wraps native first class types to provide easy-to-use methods
	 * for accessing run-time type information that can be hidden somewhat behind the scenes.
	 * 
	 * Also allows "poor man" reflection/type-introspection on runtimes that don't support it natively (e.g. C++).
	 * 
	 * @author 
	 */
	public class qb2A_FirstClassType extends Object
	{
		private static var s_types:Dictionary = null;
		
		private static var s_makingInstance:Boolean = false;
		
		private var m_nativeType:Class = null;
		
		private var m_name:String = null;
		
		internal const m_superInterfaces:Vector.<qb2Interface> = new Vector.<qb2Interface>();
		internal const m_immediateInterfaces:Vector.<qb2Interface> = new Vector.<qb2Interface>();
		
		protected var m_interfacesPopulated:Boolean = false;
		
		private const m_constructors:Vector.<qb2I_Constructor> = new Vector.<qb2I_Constructor>();
		
		/**
		 * A somewhat hacky function to determine if a given native class is an interface or not.
		 * 
		 * @param	nativeType
		 * @return
		 */
		private static function isNativeTypeAnInterface(nativeType:Class):Boolean
		{
			var superClassName:String = getQualifiedSuperclassName(nativeType);
			
			return superClassName == null && nativeType != Object;
		}
		
		public static function hasInstance(nativeType:Class):Boolean
		{
			return s_types[nativeType] != null
		}
		
		protected static function registerInstance(nativeType:Class):qb2A_FirstClassType
		{
			var isInterface:Boolean = isNativeTypeAnInterface(nativeType);
			
			var firstClassType:qb2A_FirstClassType = null;
				
			s_makingInstance = true;
			{
				firstClassType = s_types[nativeType] = isInterface ? new qb2Interface(nativeType) : new qb2Class(nativeType);
			}
			s_makingInstance = false;
			
			return firstClassType;
		}
		
		internal static function startUp():void
		{
			s_types = new Dictionary(true);
		}
		
		internal static function shutDown():void
		{
			s_types = null;
		}
		
		public static function getInstance(nativeType:Class):qb2A_FirstClassType
		{
			var firstClassType:qb2A_FirstClassType = s_types[nativeType];
			
			if ( firstClassType == null )
			{
				firstClassType = registerInstance(nativeType);
			}
			
			return firstClassType;
		}
		
		public function qb2A_FirstClassType(nativeType:Class)
		{
			if ( !s_makingInstance )
			{
				qb2U_Error.throwCode(qb2E_CompilerErrorCode.PRIVATE_CONSTRUCTOR);
			}
			
			m_nativeType = nativeType;
			this.m_name = this.getQualifiedName().split("::")[1];
		}
		
		[qb2_abstract] internal function populateInterfaceArray():void
		{
			include "../macros/QB2_ABSTRACT_METHOD";
		}
		
		public function isSubTypeOf(otherfirstClassType:qb2A_FirstClassType):Boolean
		{
			return this.getNativeType() is otherfirstClassType.getNativeType();
		}
		
		public function getNativeType():Class
		{
			return m_nativeType;
		}
		
		public function getSimpleName():String
		{
			return this.m_name;
		}
		
		public function getQualifiedName():String
		{
			return getQualifiedClassName(m_nativeType);
		}
		
		[qb2_abstract] internal function nextSuper(progress:int):qb2A_FirstClassType
		{
			include "../macros/QB2_ABSTRACT_METHOD";
			
			return null;
		}
		
		public function newInstance():*
		{
			var constructor:qb2I_Constructor = getConstructor();
			
			if ( constructor == null )
			{
				//TODO: Some environments (e.g. GWT) can't support this type of behavior.
				return new (this.getNativeType());
				
				//qb2U_Error.throwCode(qb2E_RuntimeErrorCode.UNDEFINED_CONSTRUCTOR);
			}
			
			return constructor.newInstance();
		}
		
		public function pushConstructor(constructor:qb2I_Constructor):void
		{
			m_constructors.push(constructor);
		}
		
		public function popConstructor():void
		{
			m_constructors.pop();
		}
		
		public function getConstructor():qb2I_Constructor
		{
			if ( m_constructors.length > 0 )
			{
				return m_constructors[m_constructors.length - 1];
			}
			
			return null;
		}
	}
}