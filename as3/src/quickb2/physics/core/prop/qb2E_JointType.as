package quickb2.physics.core.prop
{
	import quickb2.lang.*;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.operators.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.utils.prop.qb2E_PropType;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_JointType extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const DISTANCE:qb2E_JointType = new qb2E_JointType();
		public static const ROPE:qb2E_JointType = new qb2E_JointType();
		public static const PISTON:qb2E_JointType = new qb2E_JointType();
		public static const REVOLUTE:qb2E_JointType = new qb2E_JointType();
		public static const WELD:qb2E_JointType = new qb2E_JointType();
		public static const MOUSE:qb2E_JointType = new qb2E_JointType();
	}
}