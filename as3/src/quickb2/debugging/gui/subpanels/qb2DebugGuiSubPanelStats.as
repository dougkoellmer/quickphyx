package quickb2.debugging.gui.subpanels 
{
	import com.bit101.components.Label;
	import flash.system.System;
	import flash.utils.Dictionary;
	import quickb2.debugging.gui.qb2S_DebugGui;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.qb2Time;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiSubPanelStats extends qb2DebugGuiSubPanel implements qb2I_DebugGuiUpdatingSubPanel
	{		
		private var m_frames:int = 0;
		private var m_startTime:int = 0;
		
		private var m_ramLabel:Label = null;
		private var m_fpsLabel:Label;
		private var m_polyCountLabel:Label;
		private var m_circCountLabel:Label;
		private var m_jointCountLabel:Label;
		
		public function qb2DebugGuiSubPanelStats() 
		{
			initialize();
		}
		
		private function initialize():void
		{
			m_name = "Stats";
		
			var leftMargin:Number = qb2S_DebugGui.panelMarginX;
			var heightOffset:Number = qb2S_DebugGui
			m_fpsLabel = new Label(this,    leftMargin, bottom+2, "FPS: ");
			m_ramLabel = new Label(this, leftMargin , m_fpsLabel.y - m_fpsLabel.height - heightOffset, "RAM: ");
			m_polyCountLabel = new Label(this, leftMargin, centroidRangeLabel.y + centroidRangeLabel.height + 10, "0" + qb2S_DebugGui.POLYGON_COUNT_TEXT);
			m_circCountLabel = new Label(this, leftMargin, m_polyCountLabel.y + m_polyCountLabel.height + heightOffset, "0" + qb2S_DebugGui.CIRCLE_COUNT_TEXT);
			m_jointCountLabel = new Label(this, leftMargin, m_circCountLabel.y + m_circCountLabel.height + heightOffset, "0" + qb2S_DebugGui.JOINT_COUNT_TEXT);
			m_fpsLabel = new Label(this,    leftMargin, bottom+2, "FPS: ");
		}
		
		public function update():void
		{
			var numPolys:uint = 0, numCircles:uint = 0, numJoints:uint = 0;
			
			var worldDict:Dictionary = qb2World.worldDict;
			for (var key:* in worldDict)
			{
				var world:qb2World = worldDict[key];
				numPolys   += world.getTotalNumPolygons();
				numCircles += world.getTotalNumCircles();
				numJoints  += world.getTotalNumJoints();
			}
			
			m_polyCountLabel.text  = numPolys   + qb2S_DebugGui.POLYGON_COUNT_TEXT;
			m_circCountLabel.text  = numCircles + qb2S_DebugGui.CIRCLE_COUNT_TEXT;
			m_jointCountLabel.text = numJoints  + qb2S_DebugGui.JOINT_COUNT_TEXT;
			
			m_frames++;
			var time:int = qb2Time.getInstance().getSystemTimeInMilliseconds();
			var elapsed:int = time - m_startTime;
			
			if( elapsed >= 500)
			{
				var fpsNum:int = Math.round(m_frames * 1000 / elapsed);
				m_frames = 0;
				m_startTime = time;
				
				m_fpsLabel.text = fpsNum + "  FPS";
				
				var memory:String = (System.totalMemory / 1000).toFixed(0);
				var memStringLen:int = memory.length;
				var newMemory:String = "";
				for (var i:int = memStringLen; i >= 0; i-= 3) 
				{
					var sliceLength:int = 3;
					var end:int = i - sliceLength;
					var numbersLeft:Boolean = end > 0;
					
					if ( !numbersLeft )
					{
						end = 0;
					}
					
					newMemory = (numbersLeft ? "," : "") + memory.slice(end, i) + newMemory;
				}
				m_ramLabel.text = newMemory + "  KB";
			}
		}
	}
}