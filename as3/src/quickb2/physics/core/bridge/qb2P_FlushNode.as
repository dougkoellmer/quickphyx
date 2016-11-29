package quickb2.physics.core.bridge 
{
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.utils.bits.qb2E_BitwiseOp;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2P_FlushNode
	{
		private var m_dirtyObject:qb2A_PhysicsObject;
		private var m_dirtyFlags:int = 0x0;
		private var m_aggregateDirtyFlags:int = 0x0;
		
		private const m_changedProperties:qb2MutablePropFlags = new qb2MutablePropFlags();
		
		private var m_cachedCollector:qb2P_FlushCollector = null;
		
		public function qb2P_FlushNode() 
		{
			
		}
		
		public function cacheCollector(collector:qb2P_FlushCollector):void
		{
			collector.retain();
			m_cachedCollector = collector;
		}
		
		public function getCachedCollector():qb2P_FlushCollector
		{
			return m_cachedCollector;
		}
		
		public function clearAggregateFlags():void
		{
			m_aggregateDirtyFlags = 0x0;
		}
		
		public function getChangedProperties():qb2MutablePropFlags
		{
			return m_changedProperties;
		}
		
		public function initialize(dirtyObject:qb2A_PhysicsObject):void
		{
			m_dirtyObject = dirtyObject;
		}
		
		public function getObject():qb2A_PhysicsObject
		{
			return m_dirtyObject;
		}
		
		public function hasAnyDirtyFlag(flags:int):Boolean
		{
			return (this.m_dirtyFlags & flags) != 0;
		}
		
		public function hasDirtyFlag(flag:int):Boolean
		{
			return (this.m_dirtyFlags & flag) == flag;
		}
		
		public function hasAggregateDirtyFlag(flag:int):Boolean
		{
			return (this.m_aggregateDirtyFlags & flag) == flag;
		}
		
		public function clearDirtyFlag(flag:int):void
		{
			this.m_dirtyFlags &= ~flag;
		}
		
		public function getAggregateDirtyFlags():int
		{
			return m_aggregateDirtyFlags;
		}
		
		public function getDirtyFlags():int
		{
			return m_dirtyFlags;
		}
		
		public function isClean():Boolean
		{
			return m_dirtyFlags == 0x0 && m_aggregateDirtyFlags == 0x0 && m_cachedCollector == null;
		}
		
		public function appendToAggregateDirtyFlags(flags:int):void
		{
			m_aggregateDirtyFlags |= flags;
		}
		
		public function appendDirtyFlags(flags:int, changedProperties_copied_nullable:qb2PropFlags):void
		{
			appendToAggregateDirtyFlags(flags);
			
			m_dirtyFlags |= flags;
			
			if ( changedProperties_copied_nullable != null )
			{
				m_changedProperties.bitwise(qb2E_BitwiseOp.OR, changedProperties_copied_nullable, m_changedProperties);
			}
		}
		
		public function clean():void
		{
			m_dirtyObject = null;
			
			m_dirtyFlags = 0x0;
			m_aggregateDirtyFlags = 0x0;
			
			m_changedProperties.clear();
			
			m_cachedCollector = null;
		}
	}
}