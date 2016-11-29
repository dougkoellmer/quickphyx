package quickb2.lang.types 
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	import quickb2.math.geo.qb2E_GeoIntersectionFlags;
	
	import quickb2.lang.operators.*;
	
	import quickb2.lang.errors.*;
	
	/**
	 * @author 
	 */
	public final class qb2Class extends qb2A_FirstClassType implements qb2I_Constructor
	{
		private var m_superClass:qb2Class = null;
		private var m_superClassSet:Boolean = false;
		
		public static function getInstance(nativeType:Class):qb2Class
		{
			return qb2A_FirstClassType.getInstance(nativeType) as qb2Class;
		}
		
		/*public static function registerInstance(nativeType:Class, defaultConstructor:qb2I_Constructor):qb2Class
		{
			var clazz:qb2Class = qb2A_FirstClassType.registerInstance(nativeType) as qb2Class;
			
			clazz.pushConstructor(defaultConstructor);
			
			return clazz;
		}*/
		
		public function qb2Class(nativeType:Class)
		{
			super(nativeType);
		}
		
		public function getSuperClass():qb2Class
		{
			if ( !m_superClassSet )
			{
				var superClassName:String = getQualifiedSuperclassName(this.getNativeType());
				
				if ( superClassName != null )
				{
					var superFlashClass:Class = getDefinitionByName(superClassName) as Class;
					m_superClass = qb2Class.getInstance(superFlashClass);
				}
				
				m_superClassSet = true;
			}
			
			return m_superClass;
		}
		
		internal override function populateInterfaceArray():void
		{
			if ( m_interfacesPopulated )  return;
			
			var superClass:qb2Class = this.getSuperClass();
			
			if ( superClass )  // only Object can have a null super class.
			{
				superClass.populateInterfaceArray(); // just make sure super has its arrays populated.
				
				var thisXml:XML = flash.utils.describeType(this.getNativeType());
				var thisInterfaceList:XMLList = thisXml.factory.implementsInterface;
				
				var i:int, j:int;
				
				var allInterfaces:Vector.<qb2Interface> = new Vector.<qb2Interface>();
				
				for ( i = 0; i < thisInterfaceList.length(); i++ )
				{
					var qualifiedInterfaceName:String = thisInterfaceList[i].@type;
					var interfaceClass:Class = getDefinitionByName(qualifiedInterfaceName) as Class;
					var interfaceQb2:qb2Interface = qb2Interface.getInstance(interfaceClass);
					
					interfaceQb2.populateInterfaceArray();
			
					if ( superClass.m_superInterfaces.indexOf(interfaceQb2) < 0 && superClass.m_immediateInterfaces.indexOf(interfaceQb2) < 0)
					{
						allInterfaces.push(interfaceQb2);
					}
					else
					{
						m_superInterfaces.push(interfaceQb2);
					}
				}
				
				for ( i = 0; i < allInterfaces.length; i++ )
				{
					var isImmediate:Boolean = true;
					
					var ithInterface:qb2Interface = allInterfaces[i];
					
					for ( j = 0; j < allInterfaces.length; j++ )
					{
						var jthInterface:qb2Interface = allInterfaces[j];
						
						if ( jthInterface == ithInterface )  continue;
						
						if ( jthInterface.m_superInterfaces.indexOf(ithInterface) >= 0 || jthInterface.m_immediateInterfaces.indexOf(ithInterface) >= 0 )
						{
							isImmediate = false;
							break;
						}
					}
					
					if ( isImmediate )
					{
						m_immediateInterfaces.push(ithInterface);
					}
					else
					{
						m_superInterfaces.push(ithInterface);
					}
				}
			}
			
			m_interfacesPopulated = true;
		}
		
		internal override function nextSuper(progress:int):qb2A_FirstClassType
		{
			if ( progress == 0 )
			{
				return m_superClass;
			}
			else if ( (progress-1) <= m_immediateInterfaces.length - 1 )
			{
				return m_immediateInterfaces[progress-1];
			}
			
			return null;
		}
	}
}