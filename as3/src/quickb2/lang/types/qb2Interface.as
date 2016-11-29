package quickb2.lang.types 
{
	import flash.utils.getDefinitionByName;
	
	
	
	/**
	 * ...
	 * @author 
	 */
	public final class qb2Interface extends qb2A_FirstClassType
	{
		public static function getInstance(nativeType:Class):qb2Interface
		{
			return qb2A_FirstClassType.getInstance(nativeType) as qb2Interface;
		}
		
		public function qb2Interface(nativeType:Class)
		{
			super(nativeType);
		}
		
		internal override function populateInterfaceArray():void
		{
			if ( m_interfacesPopulated )  return;
			
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
				
				allInterfaces.push(interfaceQb2);
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
			
			m_interfacesPopulated = true;
		}
		
		internal override function nextSuper(progress:int):qb2A_FirstClassType
		{
			if ( progress <= m_immediateInterfaces.length - 1 )
			{
				return m_immediateInterfaces[progress];
			}
			
			return null;
		}
	}
}