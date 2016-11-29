package quickb2.physics.driving 
{s
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2E_CarTransmissionType extends qb2Enum
	{
		include "../../../lang/macros/QB2_ENUM";
		
		public static const AUTOMATIC:qb2E_CarTransmissionType	= new qb2E_CarTransmissionType();
		public static const MANUAL:qb2E_CarTransmissionType		= new qb2E_CarTransmissionType();
	}
}