package 
{
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import quickb2.debugging.profiling.qb2Benchmark;
	import quickb2.display.immediate.color.qb2S_Color;
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.iterators.qb2E_GeoCompositeCurveIteratorMode;
	import quickb2.math.geo.curves.iterators.qb2E_GeoTessellatorMode;
	import quickb2.math.geo.curves.iterators.qb2GeoCompositeCurveIterator;
	import quickb2.math.geo.curves.iterators.qb2GeoCurveTessellator;
	import quickb2.math.geo.curves.iterators.qb2GeoMultiCurveTessellator;
	import quickb2.math.geo.curves.iterators.qb2GeoTessellatorConfig;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2GeoCircle;
	import quickb2.math.geo.curves.qb2GeoCircularArc;
	import quickb2.math.geo.curves.qb2GeoCompositeCurve;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.qb2M_Math_Geo;
	import quickb2.math.qb2S_Math;
	import quickb2.platform.input.qb2MouseEvent;
	import quickb2.platform.qb2I_EntryPoint;
	import quickb2.thirdparty.flash.qb2FlashMouse;
	import quickb2.thirdparty.flash.qb2FlashVectorGraphics2d;
	import quickb2.thirdparty.flash.qb2M_Flash;
	import quickb2.thirdparty.flash_box2d.qb2FlashBox2dEntryPointCaller;
	
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite
	{
		private const m_textField:TextField = new TextField();
		
		private var m_graphics:qb2I_Graphics2d;
		private const m_tessellator:qb2GeoCurveTessellator = new qb2GeoCurveTessellator();
		private var m_config:qb2GeoTessellatorConfig = new qb2GeoTessellatorConfig();
		
		private const m_curves:Vector.<qb2A_GeoCurve> = new Vector.<qb2A_GeoCurve>();
		
		private const m_center:qb2GeoPoint = new qb2GeoPoint(400, 300);
		
		private var m_curveProgress:int = 0;
		private var m_subProgress:int = 0;
		
		public function Main()
		{
			qb2M_Flash.startUp(this.stage);
			qb2M_Math_Geo.startUp();
			
			m_graphics = new qb2FlashVectorGraphics2d(this.graphics);
		
			m_config.targetSegmentLength = 100;
			m_config.targetPointCount = 4;
			m_config.pointOverlapTolerance = 20;
			
			m_textField.width = 500;
			this.addChild(m_textField);
			
			qb2FlashMouse.getInstance(stage).addEventListener(qb2MouseEvent.MOUSE_CLICKED, step);
			
			makeCurves();
			
			step();
		}
		
		private function step():void
		{
			m_graphics.clearBuffer();
			
			if ( m_curveProgress >= m_curves.length )
			{
				m_textField.text = "All done!";
				
				return;
			}
			
			var curve:qb2A_GeoCurve = m_curves[m_curveProgress];
			
			m_graphics.pushParam(qb2E_DrawParam.LINE_COLOR, qb2S_Color.BLACK);
			curve.draw(m_graphics);
			m_graphics.popParam(qb2E_DrawParam.LINE_COLOR);
			
			if ( m_subProgress >= 4 )
			{
				m_subProgress = 0;
				m_curveProgress++;
				step();
				
				return;
			}
			
			switch(m_subProgress)
			{
				case 0:
				{
					m_config.mode = qb2E_GeoTessellatorMode.BY_SEGMENT_LENGTH;
					m_config.repeatEndpointForClosedCurves = false;
					break;
				}
				
				case 1:
				{
					m_config.mode = qb2E_GeoTessellatorMode.BY_SEGMENT_LENGTH;
					m_config.repeatEndpointForClosedCurves = true;
					break;
				}
				
				case 2:
				{
					m_config.mode = qb2E_GeoTessellatorMode.BY_POINT_COUNT;
					m_config.repeatEndpointForClosedCurves = false;
					break;
				}
				
				case 3:
				{
					m_config.mode = qb2E_GeoTessellatorMode.BY_POINT_COUNT;
					m_config.repeatEndpointForClosedCurves = true;
					break;
				}
			}
			
			
			m_graphics.pushParam(qb2E_DrawParam.LINE_COLOR, qb2S_Color.RED);
			m_graphics.pushParam(qb2E_DrawParam.LINE_THICKNESS, 2);
			var firstPoint:Boolean = true;
			var pointCount:int = 0;
			
			var radius:Number = 3;
			m_tessellator.initialize(curve, m_config);
			for ( var point:qb2GeoPoint; (point = m_tessellator.next()) != null; )
			{
				point.drawWithRadius(m_graphics, radius);
				if ( firstPoint )
				{
					m_graphics.moveTo(point);
					
					firstPoint = false;
				}
				else
				{
					//m_graphics.drawLineTo(point);
				}
				
				pointCount++;
				radius += 3;
			}
			m_graphics.popParam(qb2E_DrawParam.LINE_COLOR);
			m_graphics.popParam(qb2E_DrawParam.LINE_THICKNESS);
			
			m_textField.text = "point count: " + pointCount + "\n";
				
			if ( m_config.mode == qb2E_GeoTessellatorMode.BY_POINT_COUNT )
			{
				m_textField.text += 
					"mode: BY_POINT_COUNT\n" +
					"target point count: " + m_config.targetPointCount + "\n";
			}
			else
			{
				m_textField.text += 
					"mode: BY_SEGMENT_LENGTH\n" +
					"target segment length: " + m_config.targetSegmentLength + "\n";
			}
			
			m_textField.text += "repeatEndpointForClosedCurves: " + (m_config.repeatEndpointForClosedCurves ? "true" : "false") + "\n";	
			
			m_textField.text += curve.convertTo(String);
			
			m_subProgress++;
		}
		
		private function makeCurves():void
		{
			var line1:qb2GeoLine = new qb2GeoLine(new qb2GeoPoint(100, 200), new qb2GeoPoint(300, 200));
			var line2:qb2GeoLine = new qb2GeoLine(new qb2GeoPoint(310, 210), new qb2GeoPoint(400, 400));
			var composite2:qb2GeoCompositeCurve = new qb2GeoCompositeCurve(line1, line2);
			composite2.setIsClosed(true);
			
			/*var curveIterator:qb2GeoCompositeCurveIterator = new qb2GeoCompositeCurveIterator(composite2, qb2E_GeoCompositeCurveIteratorMode.GEOMETRY);
			var pointIterator:qb2GeoMultiCurveTessellator = new qb2GeoMultiCurveTessellator(curveIterator, m_config);
			
			for ( var point:qb2GeoPoint; point = pointIterator.next(); )
			{
				trace(point);
			}*/
			
			var composite2Clone:qb2GeoCompositeCurve = composite2.clone();
			composite2Clone.setIsClosed(false);
			var composite3:qb2GeoCompositeCurve = new qb2GeoCompositeCurve();
			composite3.addCurve(composite2Clone);
			var line3:qb2GeoLine = new qb2GeoLine(new qb2GeoPoint(400, 400), new qb2GeoPoint(100, 200));
			composite3.addCurve(line3);
			
			var composite4:qb2GeoCompositeCurve = composite2.clone();
			composite4.setIsClosed(true);
			
			m_center.incX( -100);
			var arc1:qb2GeoCircularArc = new qb2GeoCircularArc(m_center, 200, qb2S_Math.RADIANS_0, qb2S_Math.RADIANS_180);
			
			m_center.incX( 100);
			var circle:qb2GeoCircle = new qb2GeoCircle(m_center, 200);
			
			var composite1:qb2GeoCompositeCurve = new qb2GeoCompositeCurve();
			composite1.addCurve(arc1);
			
			m_curves.push(circle);
			m_curves.push(arc1);
			m_curves.push(composite3);
			m_curves.push(composite2);
			m_curves.push(composite4);
			
			m_curves.push(composite1);
		}
	}
}