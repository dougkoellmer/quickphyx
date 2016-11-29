package quickb2.utils.prop 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.types.qb2U_Type;
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Prop extends qb2UtilityClass
	{
		private static const s_emptyPropertyMap:qb2PropMap = new qb2PropMap();
		
		public static function ensureInstance(propertyMap_nullable:qb2PropMap):qb2PropMap
		{
			return propertyMap_nullable != null ? propertyMap_nullable : s_emptyPropertyMap;
		}
		
		public static function getPropValue(property:qb2Prop, propertyMap_nullable:qb2PropMap):*
		{
			propertyMap_nullable = ensureInstance(propertyMap_nullable);
			return propertyMap_nullable.getPropertyOrDefault(property);
		}
		
		public static function getPropReference(propOrString:*):qb2Prop
		{
			if ( qb2U_Type.isKindOf(propOrString, String) )
			{
				return qb2Prop.getByName(propOrString as String);
			}
			
			return propOrString as qb2Prop;
		}
	}
}