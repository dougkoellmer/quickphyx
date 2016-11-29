package quickb2.physics.core.backend 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_BackEndProp extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const REACTION_FORCE:qb2E_BackEndProp			= new qb2E_BackEndProp();
		public static const REACTION_TORQUE:qb2E_BackEndProp		= new qb2E_BackEndProp();
		public static const IS_SLEEPING:qb2E_BackEndProp			= new qb2E_BackEndProp();
		public static const JOINT_ANGLE:qb2E_BackEndProp			= new qb2E_BackEndProp();
		public static const JOINT_SPEED:qb2E_BackEndProp			= new qb2E_BackEndProp();
		public static const JOINT_TORQUE:qb2E_BackEndProp			= new qb2E_BackEndProp();
		public static const ABSOLUTE_POSITION:qb2E_BackEndProp		= new qb2E_BackEndProp();
		public static const CENTER_OF_MASS:qb2E_BackEndProp			= new qb2E_BackEndProp();
		public static const ABSOLUTE_ROTATION:qb2E_BackEndProp		= new qb2E_BackEndProp();
		public static const LINEAR_VELOCITY:qb2E_BackEndProp		= new qb2E_BackEndProp();
		public static const ANGULAR_VELOCITY:qb2E_BackEndProp		= new qb2E_BackEndProp();
		public static const TRANSFORM:qb2E_BackEndProp				= new qb2E_BackEndProp();
	}
}