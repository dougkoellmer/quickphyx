package quickb2.utils.prop 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.utils.iterator.qb2I_ResettableIterator;
	import quickb2.lang.types.qb2U_Type;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2PropSelector 
	{
		private var m_rule:qb2PropRule = null;
		
		private var m_type:Class = null;
		private var m_group:String = null;
		private var m_id:String = null;
		private var m_pseudoType:qb2PropPseudoType = null;
		
		private var m_previous:qb2PropSelector = null;
		private var m_next:qb2PropSelector = null;
		private var m_last:qb2PropSelector = null;
		private var m_linkType:qb2E_PropSelectorLink = null;
		
		public function qb2PropSelector() 
		{
			m_last = this;
		}
		
		internal function isMatch(ancestorIterator:qb2I_ResettableIterator, pseudoType_nullable:qb2PropPseudoType = null):Boolean
		{
			var currentSelector:qb2PropSelector = this.getLast();
			var linkType:qb2E_PropSelectorLink = null;
			
			while ( currentSelector != null )
			{
				linkType = currentSelector.getNext() != null ? currentSelector.getLinkType() : null;
				
				if ( linkType == null )
				{
					var object:qb2I_UsesPropSheet = ancestorIterator.next();
					
					if ( !currentSelector.isIndividualMatch(object, pseudoType_nullable) )
					{
						return false;
					}
				}
				else if( linkType == qb2E_PropSelectorLink.CHILD )
				{
					var parent:qb2I_UsesPropSheet = ancestorIterator.next();
					
					if ( parent == null || !currentSelector.isIndividualMatch(parent, pseudoType_nullable) )
					{
						return false;
					}
				}
				else if ( linkType == qb2E_PropSelectorLink.DESCENDANT )
				{
					for ( var ancestor:qb2I_UsesPropSheet; (ancestor = ancestorIterator.next()) != null; )
					{
						if ( currentSelector.isIndividualMatch(ancestor, pseudoType_nullable) )
						{
							break; // found a matching selector...will return true at bottom.
						}
					}
					
					return false; // we go to the top of the hierarchy without finding a matching selector
				}
				
				currentSelector = currentSelector.getPrevious();
			}
			
			ancestorIterator.reset();
			
			return true;
		}
		
		private function isIndividualMatch(object:qb2I_UsesPropSheet, pseudoType:qb2PropPseudoType):Boolean
		{
			var type:Class = (object as qb2A_Object).getClass().getNativeType();
			var id:String = object.getId();
			var group:String = object.getGroup();
			
			var typesMatch:Boolean = (m_type == null || qb2U_Type.isKindOf(type, m_type)) && m_pseudoType == pseudoType;
			var idsMatch:Boolean = id == m_id && typesMatch;
			var groupsMatch:Boolean = m_group != null && group != null && group.search(m_group) >= 0 && typesMatch;
			
			return idsMatch || groupsMatch;
		}
		
		internal function append_contract():void
		{
			if ( this.getRule() != null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ALREADY_IN_USE, "Selector is already assigned to a rule.");
			}
		}
		
		public function getNext():qb2PropSelector
		{
			return m_next;
		}
		
		public function getPrevious():qb2PropSelector
		{
			return m_previous;
		}
		
		public function getLinkType():qb2E_PropSelectorLink
		{
			return m_linkType;
		}
		
		public function getLast():qb2PropSelector
		{
			return m_last;
		}
		
		public function append(selector:qb2PropSelector, link:qb2E_PropSelectorLink):void
		{
			if ( this.m_next != null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_STATE, "This selector already has a next.");
			}
			
			if ( selector.m_previous != null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ALREADY_IN_USE, "The selector to be appended is already part of another list.");
			}
			
			append_contract();
			
			selector.onAttached(this.getRule());
			
			this.m_next = selector;
			selector.m_previous = this;
			
			m_linkType = link;
		
			var current:qb2PropSelector = selector;
			
			while ( current != null )
			{
				current.m_last = selector;
				
				current = current.m_previous;
			}
		}
		
		public function copy(source:qb2PropSelector):void
		{
			this.set(source.m_type, source.m_group, source.m_id, source.m_pseudoType);
		}
		
		public function clone():qb2PropSelector
		{
			var current:qb2PropSelector = this;
			var previousClone:qb2PropSelector = null;
			var firstClone:qb2PropSelector = null;
			
			while ( current != null )
			{
				var currentClone:qb2PropSelector = new qb2PropSelector();
				currentClone.copy(current);
				currentClone.m_linkType = current.m_linkType;
				
				if ( firstClone == null )
				{
					firstClone = currentClone;
				}
				
				if ( previousClone != null )
				{
					previousClone.m_next = currentClone;
				}
				
				previousClone = currentClone;
				current = current.m_next;
			}
			
			return firstClone;
		}
		
		public function getRule():qb2PropRule
		{
			return m_rule;
		}
		
		private function setRule(rule:qb2PropRule):void
		{
			m_rule = rule;
			
			var current:qb2PropSelector = m_next;
			
			while ( current != null )
			{
				current.m_rule = rule;
				
				current = current.m_next;
			}
		}
		
		internal function onAttached(rule:qb2PropRule):void
		{
			setRule(rule);
		}
		
		internal function onDettached():void
		{
			setRule(null);
		}
		
		public static function newTypeSelector(type_nullable:Class):qb2PropSelector
		{
			var selector:qb2PropSelector = new qb2PropSelector();
			
			selector.setAsTypeSelector(type_nullable);
			
			return selector;
		}
		
		public static function newGroupSelector(group:String, type_nullable:Class = null, pseudoType_nullable:qb2PropPseudoType = null):qb2PropSelector
		{
			var selector:qb2PropSelector = new qb2PropSelector();
			
			selector.setAsGroupSelector(group, type_nullable, pseudoType_nullable);
			
			return selector;
		}
		
		public static function newIdSelector(id:String, type_nullable:Class = null, pseudoType_nullable:qb2PropPseudoType = null):qb2PropSelector
		{
			var selector:qb2PropSelector = new qb2PropSelector();
			
			selector.setAsIdSelector(id, type_nullable, pseudoType_nullable);
			
			return selector;
		}
		
		public static function newpseudoTypeSelector(pseudoType:qb2PropPseudoType):qb2PropSelector
		{
			var selector:qb2PropSelector = new qb2PropSelector();
			
			selector.setAspseudoTypeSelector(pseudoType);
			
			return selector;
		}
		
		public static function newWildcardSelector():qb2PropSelector
		{
			var selector:qb2PropSelector = new qb2PropSelector();
			
			selector.setAsWildcard();
			
			return selector;
		}
		
		private function set(type:Class, group:String, id:String, pseudoType:qb2PropPseudoType):void
		{
			m_type = type;
			m_group = group;
			m_id = id;
			m_pseudoType = pseudoType;
		}
		
		public function setAsTypeSelector(type_nullable:Class):void
		{
			set(type_nullable, null, null, null);
		}
		
		public function setAsGroupSelector(group:String, type_nullable:Class = null, pseudoType_nullable:qb2PropPseudoType = null):void
		{
			set(type_nullable, group, null, pseudoType_nullable);
		}
		
		public function setAsIdSelector(id:String, type_nullable:Class = null, pseudoType_nullable:qb2PropPseudoType = null):void
		{
			set(type_nullable, null, id, pseudoType_nullable);
		}
		
		public function setAspseudoTypeSelector(pseudoType:qb2PropPseudoType):void
		{
			set(null, null, null, pseudoType);
		}
		
		public function setAsWildcard():void
		{
			set(null, null, null, null);
		}
	}
}