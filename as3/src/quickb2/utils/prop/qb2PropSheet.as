package quickb2.utils.prop 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.utils.iterator.qb2I_ResettableIterator;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2PropSheet 
	{
		private const m_rules:Vector.<qb2PropRule> = new Vector.<qb2PropRule>();
		
		public function qb2PropSheet() 
		{
			
		}
		
		public function addRule(rule:qb2PropRule):void
		{
			if ( rule.getSheet() != null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ALREADY_IN_USE, "Rule already has a sheet.");
			}
			
			m_rules.push(rule);
			
			rule.onAttached(this, m_rules.length-1);
		}
		
		public function removeRule(rule:qb2PropRule):void
		{
			if ( rule.getSheet() != this )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_RELATIONSHIP, "Rule must be a part of this sheet.");
			}
			
			m_rules.splice(rule.getSheetIndex(), 1);
			
			rule.onRemoved();
		}
		
		public function computePropertyMap(ancestorIterator:qb2I_ResettableIterator, psuedoType_nullable:qb2PropPseudoType = null):qb2PropMap
		{
			var map:qb2PropMap = null;
			
			for ( var i:int = m_rules.length-1; i >= 0; i-- )
			{
				var rule:qb2PropRule = m_rules[i];
				
				if ( rule.matchesAnySelector(ancestorIterator, psuedoType_nullable) )
				{
					if ( map == null )
					{
						map = new qb2PropMap();
					}
					
					map.concat_internal(rule.getMap(), map, qb2E_PropConcatType.X_OR);
				}
			}
			
			return map;
		}
	}
}