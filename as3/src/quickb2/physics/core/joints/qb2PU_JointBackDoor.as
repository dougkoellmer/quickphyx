package quickb2.physics.core.joints 
{
	import quickb2.lang.foundation.qb2PrivateUtilityClass;
	import quickb2.utils.prop.qb2PropMapStack;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2PU_JointBackDoor extends qb2PrivateUtilityClass
	{
		public static function markForMakeIfWarranted(thisArg:qb2Joint):void
		{
			thisArg.markForMakeIfWarranted();
		}
		
		public static function isRepresentable(thisArg:qb2Joint):void
		{
			thisArg.isRepresentable();
		}
		
		public static function onStepComplete_internal(thisArg:qb2Joint, stylePropStack:qb2PropMapStack):void
		{
			thisArg.onStepComplete_internal(stylePropStack);
		}
	}
}