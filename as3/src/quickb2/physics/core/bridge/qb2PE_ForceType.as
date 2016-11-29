package quickb2.physics.core.bridge 
{
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author ...
	 */
	public class qb2PE_ForceType extends qb2Enum
	{
		public static const ANGULAR_FORCE:qb2PE_ForceType = new qb2PE_ForceType();
		public static const ANGULAR_IMPULSE:qb2PE_ForceType = new qb2PE_ForceType();
		public static const LINEAR_FORCE:qb2PE_ForceType = new qb2PE_ForceType();
		public static const LINEAR_IMPULSE:qb2PE_ForceType = new qb2PE_ForceType();
	}
}