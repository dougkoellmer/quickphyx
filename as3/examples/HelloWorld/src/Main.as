package 
{
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.text.*;
	import quickb2.display.immediate.style.qb2S_StyleProps;
	import quickb2.physics.extras.qb2FollowBody;
	import quickb2.physics.utils.qb2EntryPointConfig;
	import quickb2.physics.utils.qb2F_EntryPointOption;
	import quickb2.platform.qb2I_EntryPoint;
	import quickb2.thirdparty.flash_box2d.qb2FlashBox2dEntryPointCaller;
	
	import quickb2.math.geo.qb2U_GeoPointLayout;
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.backend.qb2I_BackEndWorldRepresentation;
	import quickb2.physics.core.iterators.qb2E_TreeIteratorOrder;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.extras.qb2WindowWalls;
	import quickb2.physics.extras.qb2WindowWallsConfig;
	import quickb2.physics.utils.qb2DebugDragger;
	import quickb2.physics.utils.qb2U_Family;
	import quickb2.physics.utils.qb2U_PhysicsStyleSheet;
	import quickb2.physics.utils.qb2U_Stock;
	import quickb2.platform.input.qb2A_Mouse;
	import quickb2.platform.input.qb2I_Mouse;
	import quickb2.platform.input.qb2MouseEvent;
	import quickb2.platform.qb2I_Window;
	import quickb2.thirdparty.box2d.qb2Box2dWorldRepresentation;
	import quickb2.thirdparty.flash.qb2FlashClock;
	import quickb2.thirdparty.flash.qb2FlashEnterFrameTimer;
	import quickb2.thirdparty.flash.qb2FlashMouse;
	import quickb2.thirdparty.flash.qb2FlashVectorGraphics2d;
	import quickb2.thirdparty.flash.qb2FlashWindow;
	import quickb2.utils.qb2I_Clock;
	import quickb2.utils.qb2I_Timer;
	
	import quickb2.event.*;
	import quickb2.lang.foundation.*;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.physics.core.*;
	import quickb2.physics.core.events.*;
	import quickb2.physics.core.tangibles.*;
	import quickb2.math.geo.coords.*;
	import quickb2.math.geo.surfaces.planar.*;
	import quickb2.display.immediate.graphics.*;
	import quickb2.physics.utils.qb2U_Stock;
	
	public class Main extends qb2FlashBox2dEntryPointCaller implements qb2I_EntryPoint
	{
		private var m_circleShape:qb2Shape;
		
		public function Main():void 
		{
			super(makeEntryPointConfig());
		}
		
		private function makeEntryPointConfig():qb2EntryPointConfig
		{
			var config:qb2EntryPointConfig = new qb2EntryPointConfig(qb2F_EntryPointOption.ALL);
			
			return config;
		}
		
		public function entryPoint():void
		{
			//--- DRK > Add some stuff to the world.
			m_circleShape = qb2U_Stock.newCircleShape(50, 0.0);
			m_circleShape.setProp(qb2S_PhysicsProps.MASS, 100.0);
			m_circleShape.setPosition(100, 100);
			m_circleShape.setProp(qb2S_StyleProps.FILL_COLOR, 0xFFFF0000);
			getWorld().addChild(m_circleShape);
			
			/*var followBody:qb2FollowBody = new qb2FollowBody();
			followBody.addChild(qb2U_Stock.newRectangleShape(100, 100, 1));
			m_world.addChild(followBody);*/

			
			getWorld().addEventListener(qb2StepEvent.POST_STEP, onPostStep);
		}
		
		private function onPostStep(event:qb2Event):void
		{
			//trace(m_circleShape.getPosition().getY());
		}
	}
}