package quickb2.physics.utils 
{
	import quickb2.lang.*
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.lang.foundation.qb2Flag;
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2F_TransformOption extends qb2Flag
	{
		include "../../lang/macros/QB2_FLAG";
		
		public function qb2F_TransformOption(bits:uint = 0)
		{
			super(bits);
		}
		
		public static const TRANSFORM_MASS:qb2F_TransformOption 					= new qb2F_TransformOption();
		public static const TRANSFORM_JOINT_ANCHORS:qb2F_TransformOption  			= new qb2F_TransformOption();
		public static const TRANSFORM_ACTORS:qb2F_TransformOption  					= new qb2F_TransformOption();
		
		public static const ALL:qb2F_TransformOption								= qb2Flag.FFFFFFFF(qb2F_TransformOption);
		
	}
}