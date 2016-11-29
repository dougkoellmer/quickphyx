package quickb2.physics.core.bridge 
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2PF_DirtyFlag
	{
		public static const NEEDS_MAKING:uint								= 0x00000001;
		public static const NEEDS_DESTROYING:uint							= 0x00000002;
		public static const BOOLEAN_PROPERTY_CHANGED:uint					= 0x00000004;
		public static const NUMERIC_PROPERTY_CHANGED:uint					= 0x00000008;
		public static const OBJECT_PROPERTY_CHANGED:uint					= 0x00000010;
		public static const WORLD_TRANSFORM_CHANGED:uint					= 0x00000020;
		public static const RIGID_TRANSFORM_CHANGED:uint					= 0x00000040;
		public static const VELOCITIES_CHANGED:uint							= 0x00000100;
		public static const SLEEP_STATE_CHANGED:uint						= 0x00000200;
		public static const MASS_CHANGED:uint								= 0x00000800;
		public static const ADDED_TO_CONTAINER:uint							= 0x00001000;
		public static const REMOVED_FROM_CONTAINER:uint						= 0x00002000
		public static const ACTOR_CHANGED:uint								= 0x00004000;
		
		private static const LAST_DIRTY_FLAG:uint							= ACTOR_CHANGED;
		public static const DIRTY_FLAGS:uint								= (LAST_DIRTY_FLAG << 1) - 1;
		
		public static const NEEDS_REMAKING:uint								= NEEDS_DESTROYING | NEEDS_MAKING;
		public static const DIRTY_FLAGS_TO_ALWAYS_CLEAR:uint				= ADDED_TO_CONTAINER | REMOVED_FROM_CONTAINER;
		public static const ADDED_OR_REMOVED:uint							= ADDED_TO_CONTAINER | REMOVED_FROM_CONTAINER;
		public static const ADDED_OR_NEEDS_MAKING:int						= ADDED_TO_CONTAINER | NEEDS_MAKING;
		public static const PROPERTY_CHANGED:int							= NUMERIC_PROPERTY_CHANGED | BOOLEAN_PROPERTY_CHANGED | OBJECT_PROPERTY_CHANGED;
		public static const ANY_TRANSFORM_CHANGED:int						= RIGID_TRANSFORM_CHANGED | WORLD_TRANSFORM_CHANGED;
		public static const IMPLICITLY_NEEDS_PROPERTIES:int					= ADDED_TO_CONTAINER | NEEDS_MAKING;
		

		public static const FLAGS_TO_CLEAR_ON_NO_BACK_END_REQUIRED:int		= DIRTY_FLAGS & ~(ADDED_OR_REMOVED | ACTOR_CHANGED);
		public static const FLAGS_TO_CLEAR_ON_MAKE_OR_DESTROY:uint			= DIRTY_FLAGS & ~(ACTOR_CHANGED);
		
		public static const FLAGS_TO_NOT_SEND_DOWN_TREE:int					= ACTOR_CHANGED;
		
		public static const ILLEGAL_RECURSION_FLAGS:uint					= DIRTY_FLAGS & ~PROPERTY_CHANGED;
		
		public static const DIRTY_PROPERTY_FLAGS:Array =
		[
			qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED,
			qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED,
			qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED
		];
		
		public static const WAS_VISITED:uint								= 0x00200000;
		public static const IS_BEING_VISITED:uint							= 0x00400000; // doesn't do anything for now.
		
		public static const VALIDATOR_FLAGS:uint							= WAS_VISITED | IS_BEING_VISITED;
	}
}