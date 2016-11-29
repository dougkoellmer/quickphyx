package quickb2.physics.core.joints 
{
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.utils.prop.qb2PropMap;
	
	/**
	 * ...
	 * @author 
	 */
	[qb2_abstract] public class qb2PA_JointComponent
	{
		private static const m_subComponents:Vector.<qb2PA_JointComponent> = new Vector.<qb2PA_JointComponent>();
		
		public function qb2PA_JointComponent(type:qb2E_JointType)
		{
			if ( m_subComponents.length <= type.getOrdinal() )
			{
				m_subComponents.length = type.getOrdinal() + 1;
			}
			
			m_subComponents[type.getOrdinal()] = this;
		}
		
		internal static function getComponent(type_nullable:qb2E_JointType):qb2PA_JointComponent
		{
			if ( type_nullable == null )
			{
				return null;
			}
			
			return m_subComponents[type_nullable.getOrdinal()];
		}
		
		[qb2_abstract] public function draw(joint:qb2Joint, graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void { }
	}
}