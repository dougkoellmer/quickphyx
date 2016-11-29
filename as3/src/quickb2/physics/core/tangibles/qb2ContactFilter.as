package quickb2.physics.core.tangibles 
{
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2ContactFilter
	{
		private var m_owner:qb2A_TangibleObject;
		
		private var m_groupIndex:int = 0;
		
		private var m_categoryFlags:int = 0x0;
		
		private var m_maskFlags:int = 0xffffffff;
		
		public function qb2ContactFilter(groupIndex:int = 0, categoryFlags:int = 0x1, maskFlags:int = 0xFFFFFFFF) 
		{
			m_owner = null;
			
			m_groupIndex = groupIndex;
			m_categoryFlags = categoryFlags;
			m_maskFlags = maskFlags;
		}
		
		protected function copy_protected(source:*):void
		{
			var sourceAsFilter:qb2ContactFilter = source as qb2ContactFilter;
			
			if ( sourceAsFilter != null )
			{
				this.m_groupIndex = sourceAsFilter.m_groupIndex;
				this.m_categoryFlags = sourceAsFilter.m_categoryFlags;
				this.m_maskFlags = sourceAsFilter.m_maskFlags;
			}
		}
		
		private function onChanged():void
		{
			
		}
		
		public function copy(source:*):void
		{
			this.copy_protected(source);
		}
		
		internal function onDetached():void
		{
			m_owner = null;
		}
		
		internal function onAttached(owner:qb2A_TangibleObject):void
		{
			m_owner = owner;
		}
		
		public function getOwner():qb2A_TangibleObject
		{
			return m_owner;
		}
		
		public function getGroupIndex():int
		{
			return m_groupIndex;
		}
		
		public function setGroupIndex(groupIndex:int):void
		{
			m_groupIndex = groupIndex;
			
			this.onChanged();
		}
		
		public function getCategoryFlags():int
		{
			return m_categoryFlags;
		}
		
		public function setCategoryFlags(categoryFlags:int):void
		{
			m_categoryFlags = categoryFlags;
			
			this.onChanged();
		}
		
		public function getMaskFlags():int
		{
			return m_maskFlags;
		}
		
		public function setMaskFlags(maskFlags:int):void
		{
			m_maskFlags = maskFlags;
			
			this.onChanged();
		}
	}
}