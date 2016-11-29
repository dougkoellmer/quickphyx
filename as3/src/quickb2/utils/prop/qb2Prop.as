package quickb2.utils.prop 
{
	import flash.utils.Dictionary;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.utils.qb2HashMap;
	
	/**
	 * ...
	 * @author ...
	 */
	[qb2_abstract] public class qb2Prop
	{
		private static const s_nameMap:qb2HashMap = new qb2HashMap(false);
		private static const s_ordinalTracker:qb2HashMap = new qb2HashMap(false);
		
		private var m_typeSpecificOrdinal:int;
		private var m_name:String;
		private var m_defaultValue:*;
		private var m_propertyType:qb2E_PropType;
		private var m_expectedType:Class;
		
		public function qb2Prop(propClass:Class, name:String, defaultValue:*, expectedType_nullable:* = null)
		{
			if ( s_nameMap.has(name) )
			{
				//TODO(DRK, LOG): Give warning.
			}
			
			s_nameMap.set(name, this);
			
			if ( expectedType_nullable == Boolean || qb2U_Type.isBoolean(defaultValue) )
			{
				m_propertyType = qb2E_PropType.BOOLEAN;
				m_defaultValue = defaultValue;
				m_expectedType = Boolean;
			}
			else if ( expectedType_nullable == Number || qb2U_Type.isNumeric(defaultValue) )
			{
				m_propertyType = qb2E_PropType.NUMERIC;
				m_defaultValue = defaultValue;
				m_expectedType = Number;
			}
 			else
			{
				m_propertyType = qb2E_PropType.OBJECT;
				m_defaultValue = defaultValue;
				m_expectedType = expectedType_nullable;
			}
			
			m_name = name;
			
			var tracker:Vector.<int> = s_ordinalTracker.get(propClass);
			if ( tracker == null )
			{
				tracker = new Vector.<int>(3, true);
				s_ordinalTracker.set(propClass, tracker);
			}
			
			m_typeSpecificOrdinal = tracker[m_propertyType.getOrdinal()];
			tracker[m_propertyType.getOrdinal()]++;
		}
		
		public static function getByName(name:String):qb2Prop
		{
			return s_nameMap.get(name);
		}
		
		public function getName():String
		{
			return m_name;
		}
		
		public function getType():qb2E_PropType
		{
			return m_propertyType;
		}
		
		public function getTypeSpecificOrdinal():int
		{
			return m_typeSpecificOrdinal;
		}
		
		public function getDefaultValue():*
		{
			return m_defaultValue;
		}
		
		public function getExpectedType():Class
		{
			return m_expectedType;
		}
	}
}