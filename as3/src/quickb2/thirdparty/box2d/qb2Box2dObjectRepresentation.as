package quickb2.thirdparty.box2d 
{
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.backend.qb2BackEndResult;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.utils.prop.qb2PropMap;
	
	/**
	 * ...
	 * @author 
	 */
	[qb2_abstract] public class qb2Box2dObjectRepresentation 
	{
		private var m_physicsObject:qb2A_PhysicsObject;
		private var m_worldRep:qb2Box2dWorldRepresentation;
		
		public function qb2Box2dObjectRepresentation() 
		{
			
		}
		
		internal final function init(physicsObject:qb2A_PhysicsObject, box2dWorldRep:qb2Box2dWorldRepresentation):void
		{
			m_physicsObject = physicsObject;
			m_worldRep = box2dWorldRep;
		}
		
		internal final function clean():void
		{
			m_physicsObject = null;
			m_worldRep = null;
		}
		
		[qb2_abstract] public function makeBox2dObject(propertyMap:qb2PropMap, transform:qb2AffineMatrix, rotationStack:Number, result_out:qb2BackEndResult):void{}
		
		[qb2_abstract] public function hasBox2dObject():Boolean { return false; }
		
		[qb2_abstract] public function destroyBox2dObject():void{}
		
		public function getWorldRepresentation():qb2Box2dWorldRepresentation
		{
			return m_worldRep;
		}
		
		public function getPhysicsObject():qb2A_PhysicsObject
		{
			return m_physicsObject;
		}
	}
}