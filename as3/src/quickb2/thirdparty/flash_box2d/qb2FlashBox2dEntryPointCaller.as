package quickb2.thirdparty.flash_box2d 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.backend.qb2I_BackEndWorldRepresentation;
	
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.physics.core.tangibles.qb2WorldConfig;
	import quickb2.physics.extras.qb2WindowWalls;
	import quickb2.physics.extras.qb2WindowWallsConfig;
	import quickb2.physics.utils.qb2EntryPointConfig;
	import quickb2.platform.input.qb2I_Mouse;
	import quickb2.platform.qb2I_EntryPoint;
	import quickb2.platform.qb2I_Window;
	import quickb2.thirdparty.box2d.qb2Box2dWorldRepresentation;
	import quickb2.thirdparty.flash.*;
	import quickb2.utils.qb2I_Clock;
	import quickb2.utils.qb2I_Timer;
	
	/**
	 * 
	 * @author 
	 */
	public class qb2FlashBox2dEntryPointCaller extends qb2FlashEntryPointCaller
	{
		public function qb2FlashBox2dEntryPointCaller(config_nullable:qb2EntryPointConfig):void 
		{
			super(new qb2Box2dWorldRepresentation(), config_nullable);
		}
	}
}