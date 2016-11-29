package quickb2.debugging.gui.subpanels 
{
	import com.bit101.components.Label;
	import com.bit101.components.VUISlider;
	import com.greensock.loading.core.DisplayObjectLoader;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import quickb2.debugging.drawing.qb2F_DebugDrawOption;
	import quickb2.debugging.drawing.qb2S_DebugDraw;
	import quickb2.debugging.gui.components.qb2DebugGuiCheckBox;
	import quickb2.debugging.gui.components.qb2DebugGuiRangeSlider;
	import quickb2.debugging.gui.components.qb2DebugGuiSlider;
	import quickb2.debugging.gui.qb2S_DebugGui;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiSubPanelDrawing extends qb2DebugGuiSubPanel
	{
		private var m_outlines:qb2DebugGuiCheckBox;
		private var m_fills:qb2DebugGuiCheckBox;
		private var m_verts:qb2DebugGuiCheckBox;
		private var m_positions:qb2DebugGuiCheckBox;
		private var m_centroids:qb2DebugGuiCheckBox;
		private var m_boundBoxes:qb2DebugGuiCheckBox;
		private var m_boundCircles:qb2DebugGuiCheckBox;
		private var m_joints:qb2DebugGuiCheckBox;
		private var m_frictionPoints:qb2DebugGuiCheckBox;
		private var m_decomposition:qb2DebugGuiCheckBox;
		
		private var m_alphaSlider:qb2DebugGuiSlider;
		
		private var m_boundBoxRange:qb2DebugGuiRangeSlider;
		private var m_centroidRange:qb2DebugGuiRangeSlider;
		private var m_boundCircleRange:qb2DebugGuiRangeSlider;
		
		private const m_flagMap:Dictionary = new Dictionary(true);
		
		public function qb2DebugGuiSubPanelDrawing() 
		{
			super();
			initialize();			
		}
		private function initialize():void
		{
			m_name = "Drawing";
			
			//--- Create all the checkbox components.
			const components:Vector.<qb2DebugGuiCheckBox> = Vector.<qb2DebugGuiCheckBox>();
			components.push
			(
				m_outlines 			= new qb2DebugGuiCheckBox("outlines", 		this, 0, 0, "Draw Lines", 			checkBoxChange),
				m_fills 			= new qb2DebugGuiCheckBox("fills", 			this, 0, 0, "Draw Fills", 			checkBoxChange),
				m_verts 			= new qb2DebugGuiCheckBox("verts", 			this, 0, 0, "Draw Vertices", 		checkBoxChange),
				m_positions 		= new qb2DebugGuiCheckBox("positions", 		this, 0, 0, "Draw Positions", 		checkBoxChange),
				m_centroids 		= new qb2DebugGuiCheckBox("centroids", 		this, 0, 0, "Draw Centroids", 		checkBoxChange),
				m_boundBoxes 		= new qb2DebugGuiCheckBox("boundBoxes", 	this, 0, 0, "Draw Bound Boxes", 	checkBoxChange),
				m_boundCircles 		= new qb2DebugGuiCheckBox("boundCircles", 	this, 0, 0, "Draw Bound Circles", 	checkBoxChange),
				m_joints 			= new qb2DebugGuiCheckBox("joints", 		this, 0, 0, "Draw Joints", 			checkBoxChange),
				m_frictionPoints 	= new qb2DebugGuiCheckBox("frictionPoints", this, 0, 0, "Draw FrictionZ", 		checkBoxChange),
				m_decomposition 	= new qb2DebugGuiCheckBox("decomposition", 	this, 0, 0, "Draw Decomposition", 	checkBoxChange)
			);
			
			//--- Associate check boxes with their draw flags.
			m_flagMap[m_outlines] 		= qb2F_DebugDrawOption.OUTLINES;
			m_flagMap[m_fills] 			= qb2F_DebugDrawOption.FILLS;
			m_flagMap[m_verts]			= qb2F_DebugDrawOption.VERTICES;
			m_flagMap[m_positions] 		= qb2F_DebugDrawOption.POSITIONS;
			m_flagMap[m_centroids] 		= qb2F_DebugDrawOption.CENTROIDS;
			m_flagMap[m_boundBoxes] 	= qb2F_DebugDrawOption.BOUND_BOXES;
			m_flagMap[m_boundCircles] 	= qb2F_DebugDrawOption.BOUND_CIRCLES;
			m_flagMap[m_joints] 		= qb2F_DebugDrawOption.JOINTS;
			m_flagMap[m_frictionPoints] = qb2F_DebugDrawOption.FRICTION_Z_POINTS;
			m_flagMap[m_decomposition] 	= qb2F_DebugDrawOption.DECOMPOSITION;
			
			//--- Lay checkboxes out.
			const marginX:Number 	= qb2S_DebugGui.panelMarginX;
			const marginY:Number 	= qb2S_DebugGui.panelMarginY;
			const spacingY:Number 	= qb2S_DebugGui.panelSpacingY;
			const startY:Number 	= marginY;
			for (var i:int = 0; i < components.length; i++) 
			{
				var item:qb2DebugGuiCheckBox = components[i];
				item.x = marginX;
				item.y = startY + i * (item.height + spacingY);
				item.syncWithPersistentData();
			}
			
			/*m_alphaSlider = new qb2DebugGuiSlider(this, 110, 10, "Alpha", alphaChange);
			m_alphaSlider.labelPrecision = 2;
			m_alphaSlider.tick = .05;
			m_alphaSlider.height = 155;
			m_alphaSlider.maximum = 1;*/
			
			m_boundBoxRange = new qb2DebugGuiRangeSlider(this, 0, startY);
			m_boundBoxRange.minimum = 0;
			m_boundBoxRange.maximum = 10;
			m_boundBoxRange.tick = 1;
			m_boundBoxRange.addEventListener(Event.CHANGE, rangeChange);
			var boundBoxRangeLabel:Label = new Label(this, 0, startY + 10, "Bound Box Depth");
			m_boundBoxRange.x = this.width / 2 - boundBoxRange.width / 2;
			m_boundBoxRangeLabel.x = this.width / 2 - m_boundBoxRangeLabel.width / 2;
		
			m_boundCircleRange = new HRangeSlider(this, 0, startY + incY);
			m_boundCircleRange.minimum = 0;
			m_boundCircleRange.maximum = 10;
			m_boundCircleRange.tick = 1;
			m_boundCircleRange.addEventListener(Event.CHANGE, rangeChange);
			var boundCircleRangeLabel:Label = new Label(this, 0, startY + incY + 10, "Bound Circle Depth");
			m_boundCircleRange.x = this.width / 2 - boundBoxRange.width / 2;
			m_boundCircleRangeLabel.x = this.width / 2 - boundBoxRangeLabel.width / 2;
			
			m_centroidRange = new HRangeSlider(this, 0, startY + incY*2);
			m_centroidRange.minimum = 0;
			m_centroidRange.maximum = 10;
			m_centroidRange.tick = 1;
			m_centroidRange.addEventListener(Event.CHANGE, rangeChange);
			var centroidRangeLabel:Label = new Label(this, 0, startY + incY*2 + 10, "Centroid Depth");
			m_centroidRange.x = this.width / 2 - centroidRange.width / 2;
			m_centroidRangeLabel.x = this.width / 2 - centroidRangeLabel.width / 2;
		}
		
		/*private function alphaChange(evt:Event):void
		{
			var alphaHex:uint = uint(alphaSlider.value * (0xFF as Number)) << 24;
			qb2S_DebugDraw.vertexAlpha = qb2S_DebugDraw.fillAlpha = qb2S_DebugDraw.outlineAlpha =
			qb2S_DebugDraw.boundBoxAlpha = qb2S_DebugDraw.centroidAlpha = qb2S_DebugDraw.frictionPointAlpha = alphaHex;
			setSharedData("alphaSliderValue", alphaSlider.value);
		}
		
		private function rangeChange(evt:Event):void
		{
			if ( evt.currentTarget == boundBoxRange )
			{
				qb2S_DebugDraw.boundBoxStartDepth = boundBoxRange.lowValue;
				qb2S_DebugDraw.boundBoxEndDepth   = boundBoxRange.highValue;
				
				qb2S_DebugGui.setSharedData("boundBoxRangeLow", boundBoxRange.lowValue);
				qb2S_DebugGui.setSharedData("boundBoxRangeHigh", boundBoxRange.highValue);
			}
			else if( evt.currentTarget == centroidRange )
			{
				qb2S_DebugDraw.centroidStartDepth = centroidRange.lowValue;
				qb2S_DebugDraw.centroidEndDepth   = centroidRange.highValue;
				
				qb2S_DebugGui.setSharedData("centroidRangeLow", centroidRange.lowValue);
				qb2S_DebugGui.setSharedData("centroidRangeHigh", centroidRange.highValue);
			}
			
			else if( evt.currentTarget == boundCircleRange )
			{
				qb2S_DebugDraw.boundCircleStartDepth = boundCircleRange.lowValue;
				qb2S_DebugDraw.boundCircleEndDepth   = boundCircleRange.highValue;
				
				qb2S_DebugGui.setSharedData("boundCircleRangeLow", boundCircleRange.lowValue);
				qb2S_DebugGui.setSharedData("boundCircleRangeHigh", boundCircleRange.highValue);
			}
		}*/
		
		private function checkBoxChange(evt:Event):void
		{
			var checkBox:qb2DebugGuiCheckBox = evt.currentTarget as qb2DebugGuiCheckBox;
			var isFlagOn:Boolean = checkBox.selected;
			var drawFlag:uint = m_flagMap[checkBox] as uint;
			
			if ( isFlagOn )
			{
				qb2S_DebugDraw.flags |= drawFlag;
			}
			else
			{
				qb2S_DebugDraw.flags &= ~drawFlag;
			}
		}
	}
}