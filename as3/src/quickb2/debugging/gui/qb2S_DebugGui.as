package quickb2.debugging.gui 
{
	import flash.net.SharedObject;
	import quickb2.lang.*
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2S_DebugGui
	{
		qb2_friend static const POLYGON_COUNT_TEXT:String  = "  POLYGONS";
		qb2_friend static const CIRCLE_COUNT_TEXT:String   = "  CIRCLES";
		qb2_friend static const JOINT_COUNT_TEXT:String    = "  JOINTS";
		
		public static var rememberSettings:Boolean = true;
		
		public static var panelMarginX:Number 	= 5;
		public static var panelMarginY:Number 	= 5;
		public static var panelSpacingY:Number	= 5;
		
		private static const PERSISTENT_VARIABLE_PREFIX:String = "qb2_debugGui_";

		private static const SHARED_OBJECT_ID:String 	= PERSISTENT_VARIABLE_PREFIX + "sharedObject";
		
		qb2_friend static const INITIAL_ALPHA:Number  		=   0.75;
		qb2_friend static const INITIAL_WIDTH:Number  		= 150.00;
		qb2_friend static const INITIAL_HEIGHT:Number 		= 415.00;
		
		qb2_friend static const WINDOW_X_ID:String 			= PERSISTENT_VARIABLE_PREFIX + "windowX";
		qb2_friend static const WINDOW_Y_ID:String 			= PERSISTENT_VARIABLE_PREFIX + "windowY";
		qb2_friend static const WINDOW_MINIMIZED_ID:String	= PERSISTENT_VARIABLE_PREFIX + "windowMinimized";
		
		
		qb2_friend static function getPersistentData(key:String):*
			{  return SharedObject.getLocal(SHARED_OBJECT_ID).data[key];  }
	
		qb2_friend static function setPersistentData(key:String, value:*):void
		{
			if ( !rememberSettings )  return;
			
			SharedObject.getLocal(SHARED_OBJECT_ID).data[key] = value;
		}
		
		qb2_friend static function doesPersistentDataExist(key:String):Boolean
		{
			return SharedObject.getLocal(SHARED_OBJECT_ID).data.hasOwnProperty(key);
		}
		
		qb2_friend static function createPersistentKey(baseName:String):String
		{
			return PERSISTENT_VARIABLE_PREFIX + baseName;
		}
	}
}