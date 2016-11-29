package quickb2.physics.core.iterators 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.lang.*;
	
	import quickb2.lang.types.*;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2AttachedJointIterator implements qb2I_Iterator
	{
		private var m_tang:qb2A_TangibleObject = null;
		private var m_jointList:qb2Joint = null;
		private var m_returnType:Class = null;
		
		public function qb2AttachedJointIterator(tang_nullable:qb2A_TangibleObject = null, T__extends__qb2Joint_nullable:Class = null ) 
		{
			initialize(tang_nullable, T__extends__qb2Joint_nullable);
		}
		
		public function initialize(tang:qb2A_TangibleObject, T__extends__qb2Joint_nullable:Class = null):void
		{
			m_tang = tang;
			m_jointList = tang != null ? m_tang.getJointList() : null;
			m_returnType = T__extends__qb2Joint_nullable != null ? T__extends__qb2Joint_nullable : qb2Joint;
		}
		
		public function next():*
		{
			//--- Advance the pointer to the next joint that satisfies the return type desired.
			while ( m_jointList != null && !qb2U_Type.isKindOf(m_jointList, m_returnType) )
			{
				m_jointList = m_jointList != null ? m_jointList.getNextJoint(m_tang) : null;
			}
			
			var toReturn:qb2Joint = m_jointList;
			
			//--- Advance the pointer to the next joint for the next iteration.
			m_jointList = m_jointList != null ? m_jointList.getNextJoint(m_tang) : null;
			
			return toReturn;
		}
	}
}