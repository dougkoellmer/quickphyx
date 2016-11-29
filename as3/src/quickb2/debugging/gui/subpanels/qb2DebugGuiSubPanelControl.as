package quickb2.debugging.gui.subpanels 
{
	import com.bit101.components.PushButton;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import quickb2.debugging.gui.components.qb2DebugGuiCheckBox;
	import quickb2.debugging.gui.components.qb2DebugGuiPushButton;
	import quickb2.debugging.gui.components.qb2DebugGuiSlider;
	import quickb2.physics.core.tangibles.qb2World;
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiSubPanelControl extends qb2DebugGuiSubPanel
	{
		private var m_pausePlayButton:qb2DebugGuiPushButton;
		private var m_stepButton:qb2DebugGuiPushButton;
		private var m_framerateSlider:qb2DebugGuiSlider;
		private var m_realtimeUpdateCheckBox:qb2DebugGuiCheckBox;
		private var m_timeStepSlider:qb2DebugGuiSlider;
		private var m_posIterSlider:qb2DebugGuiSlider;
		private var m_velIterSlider:qb2DebugGuiSlider;
		
		public function qb2DebugGuiSubPanelControl() 
		{
			initialize();
		}
		
		private function initialize():void
		{
			m_name = "Control";
			
			m_pausePlayButton = new qb2DebugGuiPushButton(this, 0, bottom, "Pause", buttonPushed);
			m_pausePlayButton.width *= .5;
			m_pausePlayButton.x = this.width - pausePlay.width - left;
			
			m_stepButton = new qb2DebugGuiPushButton(this, 0, bottom, "Step", buttonPushed);
			m_stepButton.width *= .5;
			m_stepButton.x = pausePlay.x;
			m_stepButton.y = pausePlay.y - stepButton.height - left;
			
			m_framerateSlider = new qb2DebugGuiSlider
		}
		
		private function buttonPushed(evt:Event):void
		{
			var sum:int = 0;
			
			var dict:Dictionary = qb2World.worldDict;
			if( evt.target == stepButton )
			{
				pausePlay.label = "Play"
				
				for (key in dict)
				{
					var world:qb2World = dict[key] as qb2World;
					
					if ( world.running )
					{
						world.stop();
					}
					else
					{
						var timeStep:Number = world.realtimeUpdate ? world.maximumRealtimeStep : world.defaultTimeStep;
						world.step(timeStep);
					}
				}
			}
			else if ( pausePlay.label == "Pause" )
			{
				pausePlay.label = "Play";
				
				for (var key:* in dict )
				{
					dict[key].stop();
				}
			}
			else if( pausePlay.label == "Play" )
			{
				pausePlay.label = "Pause";
				
				for (key in dict)
				{
					dict[key].start();
				}
			}
		}
	}
}