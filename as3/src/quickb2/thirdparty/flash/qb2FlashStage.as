package quickb2.thirdparty.flash 
{
	import flash.display.Stage;
	/**
	 * ...
	 * @author 
	 */
	public class qb2FlashStage 
	{
		internal static var s_stage:Stage;
		
		internal static function startUp(stage:Stage):void
		{
			s_stage = stage;
		}
		
		internal static function shutDown():void
		{
			s_stage = null;
		}
		
		public static function getInstance():Stage
		{
			return s_stage;
		}
	}
}