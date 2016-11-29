package quickb2.physics.core.bridge 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2PF_SimulatedObjectFlag 
	{
		// for internal use only
		public static const MIGHT_HAVE_PINCHES:int			= 0x02000000;
		public static const IS_SLEEPING:int			 		= 0x04000000;
		public static const IS_DEEP_CLONING:int				= 0x08000000;
		
		public static const REPORTS_CONTACT_STARTED:int		= 0x10000000;
		public static const REPORTS_CONTACT_ENDED:int		= 0x20000000;
		public static const REPORTS_PRE_SOLVE:int			= 0x40000000;
		public static const REPORTS_POST_SOLVE:int			= 0x80000000;
		
		public static const CONTACT_REPORTING_FLAGS:int		= REPORTS_CONTACT_STARTED	| REPORTS_CONTACT_ENDED |
															  REPORTS_PRE_SOLVE			| REPORTS_POST_SOLVE    ;
															  
		public static const RESERVED_FLAGS:int				= IS_SLEEPING /*| FLAGGED_FOR_DESTROY*/ | IS_DEEP_CLONING | MIGHT_HAVE_PINCHES;
		
		public static const FLAGS_ILLEGAL_FOR_USER:int		= CONTACT_REPORTING_FLAGS | RESERVED_FLAGS;
	}
}