package quickb2.utils.prop 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.utils.iterator.qb2I_ResettableIterator;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2PropRule 
	{
		private const m_selectors:Vector.<qb2PropSelector> = new Vector.<qb2PropSelector>();
		
		private const m_map:qb2MutablePropMap = new qb2MutablePropMap();
		
		private var m_sheet:qb2PropSheet = null;
		private var m_sheetIndex:int = -1;
		
		public function qb2PropRule()
		{
		}
		
		public function matchesAnySelector(ancestorIterator:qb2I_ResettableIterator, psuedoType_nullable:qb2PropPseudoType = null):Boolean
		{
			for ( var i:int = 0; i < this.getSelectorCount(); i++ )
			{
				var selector:qb2PropSelector = this.getSelector(i);
				
				if ( selector.isMatch(ancestorIterator, psuedoType_nullable) )
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function addSelector(selector:qb2PropSelector):void
		{
			selector.append_contract();
			
			m_selectors.push(selector);
			
			selector.onAttached(this);
		}
		
		public function getSelectorCount():int
		{
			return m_selectors.length;
		}
		
		public function getSelector(index:int):qb2PropSelector
		{
			return m_selectors[index];
		}
		
		public function getMap():qb2MutablePropMap
		{
			return m_map;
		}
		
		public function getSheet():qb2PropSheet
		{
			return m_sheet;
		}
		
		internal function getSheetIndex():int
		{
			return m_sheetIndex;
		}
		
		internal function onAttached(sheet:qb2PropSheet, index:int):void
		{
			m_sheet = sheet;
			m_sheetIndex = index;
		}
		
		internal function onRemoved():void
		{
			m_sheet = null;
			m_sheetIndex = -1;
		}
	}
}