package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.style.qb2S_Style;
	import quickb2.event.qb2Event;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2GeoCircle;
	import quickb2.math.geo.curves.qb2GeoCircularArc;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.surfaces.planar.qb2GeoCurveBoundedPlane;
	import quickb2.math.geo.surfaces.planar.qb2GeoEllipticalDisk;
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.events.qb2StepEvent;
	import quickb2.physics.core.property.qb2E_PhysicsProperty;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2S_TangibleStyle;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.utils.qb2EntryPointConfig;
	import quickb2.physics.utils.qb2F_EntryPointOption;
	import quickb2.physics.utils.qb2U_Family;
	import quickb2.platform.input.qb2MouseEvent;
	import quickb2.platform.qb2I_EntryPoint;
	import quickb2.thirdparty.flash.qb2FlashMouse;
	import quickb2.thirdparty.flash.qb2FlashVectorGraphics2d;
	import quickb2.thirdparty.flash_box2d.qb2FlashBox2dEntryPointCaller;
	
	/**
	 * ...
	 * @author
	 */
	public class Main extends qb2FlashBox2dEntryPointCaller implements qb2I_EntryPoint
	{
		public function Main():void 
		{
			//super(new qb2EntryPointConfig());
			super(new qb2EntryPointConfig(qb2F_EntryPointOption.ALL));
		}
		
		public function entryPoint():void
		{
			
			var line:qb2GeoLine = new qb2GeoLine();
			
			getWorld().setProperty(qb2E_PhysicsProperty.CURVE_TESSELLATION, 90);
			
			var ellipse:qb2GeoEllipticalDisk = new qb2GeoEllipticalDisk();
			ellipse.setMajorAxis(100, 0);
			ellipse.setMinorAxis(50);
			ellipse.rotateBy(qb2S_Math.RADIANS_30);
			var shape:qb2Shape = new qb2Shape(ellipse);
			shape.setMass(1);
			shape.setPosition(200, 200);
			shape.setRotation(qb2S_Math.RADIANS_30);
			//getWorld().addChild(shape);
			
			
			var arc:qb2GeoCircularArc = new qb2GeoCircularArc();
			arc.set(new qb2GeoPoint(200, 200), 100, 0, qb2S_Math.RADIANS_270);
			var boundedPlane:qb2GeoCurveBoundedPlane = new qb2GeoCurveBoundedPlane(arc);
			var planeShape:qb2Shape = new qb2Shape(boundedPlane);
			planeShape.setMass(1);
			getWorld().addChild(planeShape);
			
			//
			/*var graphics:qb2FlashVectorGraphics2d = new qb2FlashVectorGraphics2d(this.graphics);
			graphics.pushParam(qb2E_DrawParam.LINE_COLOR, 0xFF000000);
			arc.draw(graphics);*/
			
			
			/*var body:qb2Body = new qb2Body();
			body.addChild(shape));
			getWorld().addChild(body);*/
			
			//getWorld().addChild(qb2U_Stock.newCircleShape(30, 1));
			
			//getWorld().getConfig().styleSheet.getRuleForPseudoClass(qb2S_TangibleStyle.STYLEPSEUDOCLASS_BACKENDREP).unsetOption(qb2S_Style.HIDDEN);
			
			//qb2FlashMouse.getInstance(stage).addEventListener(qb2MouseEvent.MOUSE_CLICKED, onClick);
		}
		
		private function onClick(event:qb2MouseEvent):void
		{
			var shape:qb2Shape = qb2U_Family.findDescendantShape(getWorld(), qb2GeoEllipticalDisk);
			var currentTesselation:Number = shape.getProperty(qb2E_PhysicsProperty.CURVE_TESSELLATION);
			shape.setProperty(qb2E_PhysicsProperty.CURVE_TESSELLATION, currentTesselation / 2);
		}
	}
}