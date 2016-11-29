package 
{
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.text.*;
	import quickb2.display.immediate.style.qb2StyleSheet;
	import quickb2.lang.qb2M_Lang;
	import quickb2.math.geo.curves.qb2GeoCircularArc;
	import quickb2.math.geo.qb2U_GeoPointLayout;
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.backend.qb2I_BackEndWorldRepresentation;
	
	import quickb2.physics.core.iterators.qb2E_TreeIteratorOrder;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.physics.core.joints.qb2DistanceJoint;
	import quickb2.physics.core.joints.qb2MouseJoint;
	import quickb2.physics.core.joints.qb2WeldJoint;
	import quickb2.physics.extras.qb2FollowBody;
	import quickb2.physics.extras.qb2WindowWalls;
	import quickb2.physics.extras.qb2WindowWallsConfig;
	import quickb2.physics.qb2M_Physics;
	import quickb2.physics.utils.qb2EntryPointConfig;
	import quickb2.physics.utils.qb2F_EntryPointOption;
	import quickb2.physics.utils.qb2U_Family;
	import quickb2.physics.utils.qb2U_Geom;
	import quickb2.physics.utils.qb2U_PhysicsStyleSheet;
	import quickb2.physics.utils.qb2U_Stock;
	import quickb2.platform.input.qb2A_Mouse;
	import quickb2.platform.input.qb2I_Mouse;
	import quickb2.platform.input.qb2MouseEvent;
	import quickb2.platform.qb2I_EntryPoint;
	import quickb2.platform.qb2I_Window;
	import quickb2.thirdparty.box2d.qb2Box2dWorldRepresentation;
	import quickb2.thirdparty.box2d.qb2M_Box2d;
	import quickb2.thirdparty.flash.qb2FlashClock;
	import quickb2.thirdparty.flash.qb2FlashEnterFrameTimer;
	import quickb2.thirdparty.flash.qb2FlashMouse;
	import quickb2.thirdparty.flash.qb2FlashVectorGraphics2d;
	import quickb2.thirdparty.flash.qb2FlashWindow;
	import quickb2.thirdparty.flash.qb2M_Flash;
	import quickb2.thirdparty.flash_box2d.qb2FlashBox2dEntryPointCaller;
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
	
	
	/** 
	 * Really simple example.
	 * 
	 * @author Doug Koellmer
	 */
	public class Main extends qb2FlashBox2dEntryPointCaller implements qb2I_EntryPoint
	{
		private var m_clickCount:int = 0;
		
		public function Main():void
		{
			super(new qb2EntryPointConfig(null));
		}
		
		public function entryPoint():void
		{
			var sprite:Sprite = new Sprite();
			this.addChild(sprite);
			var graphics:qb2I_Graphics2d = new qb2FlashVectorGraphics2d(sprite.graphics);
			graphics.pushParam(qb2E_DrawParam.FILL_COLOR, 0xFFFF0000);
			
			var circularArc:qb2GeoCircularArc = new qb2GeoCircularArc(new qb2GeoPoint(200, 200), 100, qb2S_Math.RADIANS_90, qb2S_Math.RADIANS_270);
			circularArc.draw(graphics);
			
			graphics.pushParam(qb2E_DrawParam.FILL_COLOR, null);
			circularArc.translateBy(new qb2GeoVector(100, 100));
			circularArc.draw(graphics);
			graphics.popParam(qb2E_DrawParam.FILL_COLOR);
			graphics.popParam(qb2E_DrawParam.FILL_COLOR);
			
			var group:qb2Group = new qb2Group();
			
			//--- DRK > Add some stuff to the world.
			var circularDiskShape:qb2Shape = qb2U_Stock.newCircleShape(50, 10);
			circularDiskShape.setPosition(100, 100);
			//circularDiskShape.setLinearVelocity(10, 0);
			var contactFilter:qb2ContactFilter = new qb2ContactFilter();
			//contactFilter.setGroupIndex( -1);
			//circularDiskShape.setContactFilter(contactFilter);
			//circularDiskShape.setAngularVelocity(Math.PI);
			//circularDiskShape.getLinearVelocity().set(1, 1);
			group.addChild(circularDiskShape);
			
			var rectangleShape:qb2Shape = qb2U_Stock.newRectangleShape(200, 100, 1);
			rectangleShape.setPosition(100, 300);
			contactFilter = contactFilter.clone();
			//rectangleShape.setContactFilter(contactFilter);
			//rectangleShape.setAngularVelocity(Math.PI);
			group.addChild(rectangleShape);
			
			getWorld().addChild(group);
			
			var distanceJoint:qb2DistanceJoint = new qb2DistanceJoint(circularDiskShape, rectangleShape);
			getWorld().addChild(distanceJoint);
			
			getWorld().addEventListener(qb2StepEvent.POST_STEP, onPostStep);
			
			qb2FlashMouse.getInstance(stage).addEventListener(qb2MouseEvent.MOUSE_CLICKED, onClick);
		}
		
		private function onClick(evt:qb2MouseEvent):void
		{
			var distanceJoint:qb2DistanceJoint = qb2U_Family.findDescendantOfType(getWorld(), qb2DistanceJoint) as qb2DistanceJoint;
			distanceJoint.setProperty(qb2E_PhysicsProperty.LENGTH, 100);
			
			return;
			
			switch(m_clickCount)
			{
				case 0:
				{
					var shape:qb2Shape = qb2U_Family.findDescendantShape(getWorld(), qb2GeoPolygon);
					//shape.setPosition(500, 300);
					shape.setRotation(Math.PI / 4);
					//shape.getGeometry().translate(new qb2GeoVector(0, 100));
					
					break;
				}
				
				case 1:
				{
					var walls:qb2WindowWalls = qb2U_Family.findDescendantOfType(getWorld(), qb2WindowWalls) as qb2WindowWalls;
					//qb2U_Geom.rotate(walls, Math.PI / 4, new qb2GeoPoint(stage.stageWidth / 2, stage.stageHeight / 2));
			
					break;
				}
				
				case 2:
				{
					var followBody:qb2FollowBody = qb2U_Family.findDescendantOfType(getWorld(), qb2FollowBody) as qb2FollowBody;
					followBody.setRotation(qb2S_Math.PI / 4);
			
					break;
				}
				
				case 3:
				{
					
					break;
				}
			}
			
			m_clickCount++;
		}
		
		private function onShapeAdded(evt:qb2ContainerEvent):void
		{
			trace("ERHERE");
		}
		
		private function onPostStep(evt:qb2Event):void
		{
		}
	}
}