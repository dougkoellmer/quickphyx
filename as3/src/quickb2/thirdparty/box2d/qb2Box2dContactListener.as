package quickb2.thirdparty.box2d 
{
	import Box2DAS.Collision.b2Manifold;
	import Box2DAS.Dynamics.b2ContactImpulse;
	import Box2DAS.Dynamics.b2ContactListener;
	import Box2DAS.Dynamics.Contacts.b2Contact;
	import quickb2.physics.core.backend.qb2I_BackEndCallbacks;
	import quickb2.physics.core.tangibles.qb2Shape;
	
	
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Box2dContactListener extends b2ContactListener
	{
		private var m_callbacks:qb2I_BackEndCallbacks;
		private var m_backEnd:qb2Box2dWorldRepresentation;
		
		public function qb2Box2dContactListener() 
		{
			
		}
		
		public function initialize(callbacks:qb2I_BackEndCallbacks, backEnd:qb2Box2dWorldRepresentation):void
		{
			m_callbacks = callbacks;
			m_backEnd = backEnd;
		}
		
		public override function BeginContact(contact:b2Contact):void
		{
			var shape1:qb2Shape = contact.GetFixtureA().GetUserData() as qb2Shape;
			var shape2:qb2Shape = contact.GetFixtureB().GetUserData() as qb2Shape;
			
			try
			{
				m_callbacks.contactStarted(shape1, shape2, null);
			}
			catch (error:Error)
			{
				m_backEnd.setErrorDuringLastStep(error);
				throw error;
			}
		}
		
		public override function EndContact(contact:b2Contact):void
		{
			var shape1:qb2Shape = contact.GetFixtureA().GetUserData() as qb2Shape;
			var shape2:qb2Shape = contact.GetFixtureB().GetUserData() as qb2Shape;
			
			try
			{
				m_callbacks.contactEnded(shape1, shape2, null);
			}
			catch (error:Error)
			{
				m_backEnd.setErrorDuringLastStep(error);
				throw error;
			}
		}
		
		public override function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var shape1:qb2Shape = contact.GetFixtureA().GetUserData() as qb2Shape;
			var shape2:qb2Shape = contact.GetFixtureB().GetUserData() as qb2Shape;
			
			try
			{
				m_callbacks.preContact(shape1, shape2, null);
			}
			catch (error:Error)
			{
				m_backEnd.setErrorDuringLastStep(error);
				throw error;
			}
		}
		
		public override function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{
			var shape1:qb2Shape = contact.GetFixtureA().GetUserData() as qb2Shape;
			var shape2:qb2Shape = contact.GetFixtureB().GetUserData() as qb2Shape;
			
			try
			{
				m_callbacks.postContact(shape1, shape2, null);
			}
			catch (error:Error)
			{
				m_backEnd.setErrorDuringLastStep(error);
				throw error;
			}
		}
		
	}

}