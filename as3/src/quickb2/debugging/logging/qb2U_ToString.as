package quickb2.debugging.logging 
{
	import flash.utils.Dictionary;
	import quickb2.lang.foundation.*;
	import quickb2.lang.types.*;
	;
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public final class qb2U_ToString extends qb2UtilityClass
	{
		private static const DEFAULT:int = -1;
		
		private static const s_objects:Vector.<Object> = new Vector.<Object>();
		private static const s_strings:Vector.<String> = new Vector.<String>();
		private static const s_counts:Vector.<int> = new Vector.<int>();
		
		public static function auto(object:Object, ... variableAndValuePairs):String
		{
			start(object);
			for ( var i:int = 0; i < variableAndValuePairs.length; i+=2 )
			{
				var variableName:String = variableAndValuePairs[i];
				var variableValue:* = variableAndValuePairs[i + 1];
				
				if ( variableValue != null )
				{
					if ( variableValue is int )
					{
						addSignedIntVariable(variableName, variableValue);
					}
					else if ( variableValue is uint )
					{
						addUnsignedIntVariable(variableName, variableValue);
					}
					else if( variableValue is Number )
					{
						addFloatVariable(variableName, variableValue);
					}
					else if ( variableValue is String )
					{
						addStringVariable(variableName, variableValue, true);
					}
					else
					{
						addVariable(variableName, variableValue);
					}
				}
				else
				{
					addStringVariable(variableName, null, false);
				}
			}
			return end();
		}
		
		public static function start(object:Object):void
		{
			if ( s_objects.length && s_objects[s_objects.length-1] != object || !s_objects.length )
			{
				var className:String = null;
				if( qb2S_ToString.useQualifiedClassNames )
				{
					className = qb2A_FirstClassType.getInstance(object.constructor).getQualifiedName();
				}
				else
				{
					className = qb2A_FirstClassType.getInstance(object.constructor).getSimpleName();
				}
				
				s_objects.push(object);
				s_strings.push(qb2S_ToString.classBrackets.charAt(0) + className + qb2S_ToString.variableBrackets.charAt(0));
				s_counts.push(1);
			}
			else
			{
				s_counts[s_objects.length - 1]++;
			}
		}
		
		public static function addStringVariable(variableName:String, value:String, quoted:Boolean):void
		{
			var currString:String = s_strings[s_strings.length - 1];
			
			if ( value == null || quoted == false )
			{
				value = value ? value : qb2S_ToString.nullString;
				
				currString += variableName + qb2S_ToString.equalityCharacter + value + qb2S_ToString.variableDelimiter;
			}
			else
			{
				currString += variableName + qb2S_ToString.equalityCharacter + qb2S_ToString.stringQuoteCharacter +
								value + qb2S_ToString.stringQuoteCharacter + qb2S_ToString.variableDelimiter;
			}
			
			s_strings[s_strings.length - 1] = currString;
		}
		
		public static function addVariable(variableName:String, value:Object):void
		{			
			addStringVariable(variableName, value.toString(), false);
		}
		
		public static function addFloatVariable(variableName:String, value:Number, precision:int = DEFAULT):void
		{
			precision = precision == DEFAULT ? qb2S_ToString.defaultFloatingPointPrecision : precision;
			
			addStringVariable(variableName, value.toFixed(precision), false);
		}
		
		public static function addUnsignedIntVariable(variableName:String, value:uint, base:int = DEFAULT ):void
		{
			base = base == DEFAULT ? qb2S_ToString.defaultIntegerBase : base;
			
			addStringVariable(variableName, value.toString(base), false);
		}
		
		public static function addSignedIntVariable(variableName:String, value:int, base:int = DEFAULT):void
		{
			base = base == DEFAULT ? qb2S_ToString.defaultIntegerBase : base;
			
			addStringVariable(variableName, value.toString(base), false);
		}
		
		public static function end():String
		{
			var currString:String = s_strings[s_strings.length-1];
			
			if ( !currString )
			{
				return null;
			}
			
			if ( s_counts[s_counts.length-1] > 1 )
			{
				s_counts[s_counts.length - 1]--;
				
				return null;
			}
			
			//--- Strip off trailing comma if necessary.
			var lastDelimiterIndex:int = currString.lastIndexOf(qb2S_ToString.variableDelimiter);
			if ( lastDelimiterIndex >= 0 )
			{
				currString = currString.substring(0, currString.length  - qb2S_ToString.variableDelimiter.length);
			}
			
			//--- Append ending brackets.
			currString += qb2S_ToString.variableBrackets.charAt(1) + qb2S_ToString.classBrackets.charAt(1);
			
			s_strings.pop();
			s_objects.pop();
			s_counts.pop();
			
			return currString;
		}
	}
}