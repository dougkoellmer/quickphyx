package quickb2.physics.core.iterators 
{
	import flash.utils.Dictionary;
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2AttachedObjectIterator implements qb2I_Iterator
	{
		private const m_jointIterator:qb2AttachedJointIterator = new qb2AttachedJointIterator();
		
		private var m_returnType:Class = null;
		
		private var m_originalTang:qb2A_TangibleObject;
		private var m_queue:Vector.<qb2A_TangibleObject> = new Vector.<qb2A_TangibleObject>();
		private var m_alreadyVisited:Dictionary = null;
		
		public function qb2AttachedObjectIterator(tang_nullable:qb2A_TangibleObject = null, returnType_nullable:Class = null)
		{
			initialize(tang_nullable, returnType_nullable);
		}
		
		public function initialize(tang:qb2A_TangibleObject, returnType_nullable:Class = null):void
		{
			if ( tang == null )  return;
			
			m_returnType = returnType_nullable != null ? returnType_nullable : qb2A_TangibleObject;
			m_queue.length = 0;
			
			m_queue.push(tang);
			m_originalTang = tang;
			m_alreadyVisited = new Dictionary(true);
		}
		
		private function clean():void
		{
			m_originalTang = null;
			m_queue.length = 0;
			m_returnType = null;
		}
		
		public function next():*
		{
			var nextTang:qb2A_TangibleObject = null;
			
			while ( m_queue.length  > 0 )
			{
				nextTang = m_queue.pop();
				
				m_alreadyVisited[nextTang] = true;
				
				m_jointIterator.initialize(nextTang);
				
				for (var joint:qb2Joint; joint = m_jointIterator.next(); ) 
				{
					var otherObject:qb2A_TangibleObject = joint.getObjectA() == nextTang ? joint.getObjectB() : joint.getObjectA()
					
					if ( m_alreadyVisited[otherObject] )  continue;
					
					m_queue.push(otherObject);
				}
				
				if ( nextTang == m_originalTang )
				{
					continue;
				}
				
				if ( qb2U_Type.isKindOf(nextTang, m_returnType) )
				{
					break;
				}
			}
			
			if ( m_queue.length == 0 )
			{
				clean();
			}
			
			return nextTang;
		}
	}
}