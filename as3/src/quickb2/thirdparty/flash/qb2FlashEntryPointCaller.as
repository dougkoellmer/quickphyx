package quickb2.thirdparty.flash 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.style.qb2S_StyleProps;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.qb2S_GeoStyle;
	import quickb2.physics.core.backend.qb2I_BackEndWorldRepresentation;
	import quickb2.physics.core.joints.qb2S_JointStyle;
	import quickb2.physics.core.tangibles.qb2S_TangibleStyle;
	
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.physics.core.tangibles.qb2WorldConfig;
	import quickb2.physics.extras.qb2WindowWalls;
	import quickb2.physics.extras.qb2WindowWallsConfig;
	import quickb2.physics.utils.qb2DebugDragger;
	import quickb2.physics.utils.qb2EntryPointConfig;
	import quickb2.physics.utils.qb2F_EntryPointOption;
	import quickb2.physics.utils.qb2U_PhysicsStyleSheet;
	import quickb2.platform.input.qb2I_Mouse;
	import quickb2.platform.qb2I_EntryPoint;
	import quickb2.platform.qb2I_Window;
	import quickb2.thirdparty.box2d.qb2Box2dWorldRepresentation;
	import quickb2.thirdparty.flash.*;
	import quickb2.utils.qb2I_Clock;
	import quickb2.utils.qb2I_Timer;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2FlashEntryPointCaller extends Sprite
	{
		private var m_world:qb2World;
		private var m_config:qb2EntryPointConfig;
		private var m_backEnd:qb2I_BackEndWorldRepresentation;
		private var m_debugDragger:qb2DebugDragger;
		
		public function qb2FlashEntryPointCaller(backEnd:qb2I_BackEndWorldRepresentation, config_nullable:qb2EntryPointConfig):void 
		{
			m_config = config_nullable != null ? config_nullable : new qb2EntryPointConfig();
			m_backEnd = backEnd;
			m_debugDragger = null;
			
			if (stage != null)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//--- DRK > Populate the static name->prop dictionary for Prop.getByName();
			qb2S_PhysicsProps.ACTOR;
			qb2S_JointStyle.ANCHOR_RADIUS;
			qb2S_TangibleStyle.CENTROID_RADIUS;
			qb2S_GeoStyle.INFINITE;
			
			var entryPoint:qb2I_EntryPoint = this as qb2I_EntryPoint;
			
			if ( entryPoint == null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.MISSING_DEPENDENCY, "Subclass must implement qb2I_EntryPoint.");
			}
			
			m_world = new qb2World(m_backEnd);
			m_world.setProp(qb2S_PhysicsProps.PIXELS_PER_METER, m_config.pixelsPerMeter);
			m_world.setProp(qb2S_PhysicsProps.GRAVITY.Y, m_config.gravityY);
			var worldConfig:qb2WorldConfig = m_world.getConfig();
			
			if ( qb2F_EntryPointOption.DEBUG_DRAG.overlaps(m_config.options) )
			{
				var mouse:qb2I_Mouse = new qb2FlashMouse(this.stage);
				m_debugDragger = new qb2DebugDragger(mouse, m_world, m_config.debugDragAcceleration);
			}
			
			if ( qb2F_EntryPointOption.DEBUG_DRAW.overlaps(m_config.options) )
			{
				worldConfig.graphics = new qb2FlashVectorGraphics2d(this.graphics);
			}
			
			if ( qb2F_EntryPointOption.WINDOW_WALLS.overlaps(m_config.options) )
			{
				var window:qb2I_Window							= new qb2FlashWindow(this.stage);
				var windowWallsConfig:qb2WindowWallsConfig		= new qb2WindowWallsConfig();
				windowWallsConfig.overhang						= m_config.windowWallOverhang;
				var windowWalls:qb2WindowWalls					= new qb2WindowWalls(window, windowWallsConfig);
				m_world.addChild(windowWalls);
			}
			
			if ( qb2F_EntryPointOption.AUTO_STEP.overlaps(m_config.options) )
			{
				var timer:qb2I_Timer					= new qb2FlashEnterFrameTimer(this.stage);
				var clock:qb2I_Clock					= new qb2FlashClock();
				m_world.startAutoStep(timer, clock);
			}
			
			setTimeout(entryPoint.entryPoint, 0);
		}
		
		public function getDebugDragger():qb2DebugDragger
		{
			return m_debugDragger;
		}
		
		public function getWorld():qb2World
		{
			return m_world;
		}
	}
}