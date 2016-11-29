package quickb2.physics.core.backend 
{
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.tangibles.qb2Contact;
	import quickb2.physics.core.tangibles.qb2Shape;
	
	/**
	 * An interface that is given to the back-end in order to notify quickb2 of certain events and state changes. quickb2 implements this interface internally.
	 * 
	 * @author Doug Koellmer
	 */
	public interface qb2I_BackEndCallbacks 
	{
		function onJointRepresentationImplicitlyDestroyed(joint:qb2Joint):void;
		
		function onShapeRepresentationImplicitlyDestroyed(shape:qb2Shape):void;
		
		function preContact(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact):void;
		
		function contactStarted(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact):void;
		
		function contactEnded(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact):void;
		
		function postContact(shape1:qb2Shape, shape2:qb2Shape, contact:qb2Contact):void;
	}
}