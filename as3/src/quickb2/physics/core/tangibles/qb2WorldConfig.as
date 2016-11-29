package quickb2.physics.core.tangibles 
{
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.platform.input.qb2I_Mouse;
	import quickb2.utils.qb2I_Clock;
	import quickb2.utils.qb2I_Timer;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2WorldConfig extends Object
	{
		/**
		 * If true, physics will update based on the actual elapsed time since the last update.
		 * If false, the simulation will update on the ideal fixed time step of the timer used to drive the update.
		 * 
		 * @default true
		 * @see #defaultTimeStep
		 */
		public var autoStepWithRealTimeDelta:Boolean = false;
		
		/**
		 * Number of position iterations to use for each automatic time step. A higher number will produce a slower but more accurate simulation.
		 * @default 3
		 */
		public var autoStepPositionIterations:int = 3;
		
		/**
		 * Number of velocity iterations to use for each automatic time step. A higher number will produce a slower but more accurate simulation.
		 * @default 3
		 */
		public var autoStepVelocityIterations:int = 8;
		
		/**
		 * If autoStepWithRealTimeDelta is true, this is the maximum step that will be taken per frame.  Large timesteps cause instabilities,
		 * so this setting makes it so that under heavy load, or on slow computers, the physics don't go completely haywire.
		 * 
		 * @default = 1.0/10.0
		 * @see #autoStepWithRealTimeDelta
		 */
		public var autoStepMaximumRealTimeDelta:Number = 1.0 / 10.0;
		
		/**
		 * If set, objects in the world will be drawn after every time step. This is typically used
		 * for debugging or prototyping, like making sure geometry lines up nicely with actors. In some cases
		 * it can also be used for production-level rendering, but the actor system is usually a better bet.
		 * 
		 * @default null
		 */
		public var graphics:qb2I_Graphics2d = null;
	}
}