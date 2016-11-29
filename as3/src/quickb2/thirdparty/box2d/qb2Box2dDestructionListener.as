package quickb2.thirdparty.box2d 
{
	import Box2DAS.Dynamics.b2DestructionListener;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.Joints.b2Joint;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.physics.core.backend.qb2I_BackEndCallbacks;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.thirdparty.box2d.joints.qb2Box2dJointRepresentation;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Box2dDestructionListener extends b2DestructionListener
	{
		private var m_callbacks:qb2I_BackEndCallbacks;
		
		public function qb2Box2dDestructionListener() 
		{
			
		}
		
		public function initialize(callbacks:qb2I_BackEndCallbacks):void
		{
			m_callbacks = callbacks;
		}
		
		public override function SayGoodbyeJoint(j:b2Joint):void
		{
			var jointRep:qb2Box2dJointRepresentation = j.GetUserData() as qb2Box2dJointRepresentation;
			
			if ( jointRep == null )
			{
				//--- DRK > TODO: I forget if this is a valid case...don't think it is.
				qb2_assert(false);
				
				return;
			}
			
			var joint:qb2Joint = jointRep.getJoint();
			jointRep.onImplicitlyDestroyed();
			jointRep.clean();
			
			m_callbacks.onJointRepresentationImplicitlyDestroyed(joint);
		}
		
		public override function SayGoodbyeFixture(f:b2Fixture):void
		{
			var shapeRep:qb2Box2dShapeRepresentation = f.GetUserData() as qb2Box2dShapeRepresentation;
			
			if ( shapeRep == null )
			{
				//--- DRK > This can happen when a shapeRep has multiple fixtures, e.g. for non-convex polygons.
				//---		In this case, the first fixture that's "said goodbye to" calls shapeRep.onImplicitlyDestroyed(),
				//---		and this then nulls out the user data of all the other fixtures managed by that shapeRep.
				return;
			}
			
			var shape:qb2Shape = shapeRep.getShape();
			shapeRep.onImplicitlyDestroyed();
			shapeRep.clean();
			
			m_callbacks.onShapeRepresentationImplicitlyDestroyed(shape);
		}
	}
}