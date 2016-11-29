package quickb2.physics.utils 
{
	import quickb2.lang.foundation.qb2ConfigClass;
	
	/**
	 * An configuration reflecting some common default settings for a basic physics simulation.
	 * 
	 * @author 
	 */
	public class qb2EntryPointConfig extends qb2ConfigClass
	{

		public function qb2EntryPointConfig(options_nullable:qb2F_EntryPointOption = null)
		{
			if ( options_nullable != null )
			{
				options = options_nullable
			}
		}
		
		public var options:qb2F_EntryPointOption;
		
		public var pixelsPerMeter:Number = 30;
		
		public var windowWallOverhang:Number = 5;
		
		public var gravityY:Number = 10;
		
		public var debugDragAcceleration:Number = 100;
	}
}