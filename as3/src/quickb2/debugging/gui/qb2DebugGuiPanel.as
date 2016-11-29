/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package quickb2.debugging.gui
{
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	import quickb2.lang.*;
	
	import quickb2.debugging.drawing.qb2F_DebugDrawOption;
	import quickb2.debugging.drawing.qb2S_DebugDraw;
	import quickb2.debugging.gui.subpanels.qb2DebugGuiSubPanel;
	import quickb2.debugging.gui.subpanels.qb2DebugGuiSubPanelAbout;
	import quickb2.debugging.gui.subpanels.qb2DebugGuiSubPanelControl;
	import quickb2.debugging.gui.subpanels.qb2DebugGuiSubPanelDrawing;
	import quickb2.debugging.gui.subpanels.qb2DebugGuiSubPanelLogging;
	import quickb2.debugging.gui.subpanels.qb2DebugGuiSubPanelStats;
	import quickb2.debugging.gui.subpanels.qb2I_DebugGuiUpdatingSubPanel;
	
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.event.qb2Event;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiPanel extends Window
	{
		private const m_subPanels:Vector.<qb2DebugGuiSubPanel> = new Vector.<qb2DebugGuiSubPanel>();
		private const m_updatingSubPanels:Vector.<qb2I_DebugGuiUpdatingSubPanel> = new Vector.<qb2I_DebugGuiUpdatingSubPanel>();
		
		public function qb2DebugGuiPanel()
		{
			initialize();
		}
		
		private function initialize():void
		{
			addSubPanel(new qb2DebugGuiSubPanelAbout());
			addSubPanel(new qb2DebugGuiSubPanelDrawing());
			addSubPanel(new qb2DebugGuiSubPanelLogging());
			addSubPanel(new qb2DebugGuiSubPanelStats());
			addSubPanel(new qb2DebugGuiSubPanelControl());
			
			this.title = "quickb2 debug panel";
			this.hasMinimizeButton = true;
			this.draggable = true;
			this.grips.visible = true;
			this.alpha = qb2S_DebugGui.INITIAL_ALPHA;
			this.width = qb2S_DebugGui.INITIAL_WIDTH;
			this.height = qb2S_DebugGui.INITIAL_HEIGHT;
			addEventListener(Event.ADDED_TO_STAGE, added); // to start fps
			
			//initSettings();
			
			s_instance = this;
		}
		
		public static function getInstance():qb2DebugGuiPanel
		{
			return s_instance ? s_instance : new qb2DebugGuiPanel();
		}
		
		private static var s_instance:qb2DebugGuiPanel = null;
		
		public function addSubPanel(subPanel:qb2DebugGuiSubPanel):void
		{
			m_subPanels.push(subPanel);
			
			if (subPanel as qb2I_DebugGuiUpdatingSubPanel)
			{
				m_updatingSubPanels.push(subPanel as qb2I_DebugGuiUpdatingSubPanel);
			}
		}
		
		private function update(evt:qb2Event):void
		{
			for (var j:int = 0; j < m_updatingSubPanels.length; j++)
			{
				m_updatingSubPanels[j].update();
			}
			
			qb2S_DebugGui.setPersistentData(qb2S_DebugGui.WINDOW_X_ID, this.x);
			qb2S_DebugGui.setPersistentData(qb2S_DebugGui.WINDOW_Y_ID, this.y);
		}
		
		/*private function initSettings():void
		   {
		   if ( qb2S_DebugGui.rememberSettings )
		   {
		   //--- Set the shared data initially it looks like it hasn't been set before.
		   if ( !data.hasOwnProperty("outlines") )
		   {
		   for ( var key:String in checkboxMap)
		   {
		   data[key] = qb2S_DebugDraw.flags & checkboxMap[key] ? true : false
		   }
		
		   data.boundBoxRangeLow     = qb2S_DebugDraw.boundBoxStartDepth;
		   data.boundBoxRangeHigh    = qb2S_DebugDraw.boundBoxEndDepth;
		   data.boundCircleRangeLow  = qb2S_DebugDraw.boundCircleStartDepth;
		   data.boundCircleRangeHigh = qb2S_DebugDraw.boundCircleEndDepth;
		   data.centroidRangeLow     = qb2S_DebugDraw.centroidStartDepth;
		   data.centroidRangeHigh    = qb2S_DebugDraw.centroidEndDepth;
		
		   data.alphaSliderValue     = .75;
		
		   data.windowMinimized = false;
		   data.windowX = data.windowY = 0;
		   }
		
		   //---- Set window settings based on shared properties.
		   for ( key in checkboxMap)
		   {
		   manualSet(this[key], checkboxMap[key],      data[key]     == true);
		   }
		
		   boundBoxRange.lowValue     = data.boundBoxRangeLow;
		   boundBoxRange.highValue    = data.boundBoxRangeHigh;
		   boundCircleRange.lowValue  = data.boundCircleRangeLow;
		   boundCircleRange.highValue = data.boundCircleRangeHigh;
		   centroidRange.lowValue     = data.centroidRangeLow;
		   centroidRange.highValue    = data.centroidRangeHigh;
		
		   alphaSlider.value          = data.alphaSliderValue;
		
		   this.minimized = data.windowMinimized == true;
		   this.x = data.windowX;
		   this.y = data.windowY;
		   }
		   else
		   {
		   for ( key in checkboxMap)
		   {
		   this[key].selected = qb2S_DebugDraw.flags & checkboxMap[key] ? true : false;
		   }
		
		   boundBoxRange.lowValue     = qb2S_DebugDraw.boundBoxStartDepth;
		   boundBoxRange.highValue    = qb2S_DebugDraw.boundBoxEndDepth;
		
		   boundCircleRange.lowValue  = qb2S_DebugDraw.boundCircleStartDepth;
		   boundCircleRange.highValue = qb2S_DebugDraw.boundCircleEndDepth;
		
		   centroidRange.lowValue  = qb2S_DebugDraw.centroidStartDepth;
		   centroidRange.highValue = qb2S_DebugDraw.centroidEndDepth;
		
		   alphaSlider.value = .75;
		   }
		
		   alphaChange(null);
		 }*/
		
		/*private static function manualSet(checkBox:CheckBox, bit:uint, flag:Boolean):void
		   {
		   checkBox.selected = flag;
		   if ( flag )
		   qb2S_DebugDraw.flags |= bit;
		   else
		   qb2S_DebugDraw.flags &= ~bit;
		 }*/
		
		public override function set minimized(value:Boolean):void
		{
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				
				if (child != grips && child != _minimizeButton && child != _titleLabel && child != _titleBar && child != _panel)
				{
					child.visible = !value;
				}
			}
			
			super.minimized = value;
			qb2S_DebugGui.setPersistentData(qb2S_DebugGui.WINDOW_MINIMIZED_ID, value);
			
			if (!minimized)
			{
				this.setChildIndex(_panel, 0);
			}
		}
		
		private function added(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, added, false);
			addEventListener(Event.REMOVED_FROM_STAGE, removed, false, 0, true);
			qb2Time.getInstance().addEventListener(qb2Time.TICK_EVENT_TYPE, update, null, true);
		}
		
		private function removed(evt:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, removed, false);
			addEventListener(Event.ADDED_TO_STAGE, added, false, 0, true);
			qb2Time.getInstance().removeEventListener(qb2Time.TICK_EVENT_TYPE, update);
		}
	}
}