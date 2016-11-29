package quickb2.debugging.gui.components 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.NumericStepper;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import quickb2.debugging.gui.qb2S_DebugGui;
	
	import quickb2.lang.*;
	
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiCheckBox extends CheckBox implements qb2I_DebugGuiComponent
	{
		private var m_persistentKey:String = null;
		
		private static const cachedClickEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
		
		public function qb2DebugGuiCheckBox(persistentKey:String, parent:DisplayObjectContainer, xPos:Number, yPos:Number, label:String = "", defaultHandler:Function = null) 
		{
			super(parent, xPos, yPos, label, defaultHandler);
			
			m_persistentKey = qb2S_DebugGui.createPersistentKey(persistentKey);
		}
		
		public function syncWithPersistentData():void
		{
			if ( qb2S_DebugGui.doesPersistentDataExist(m_persistentKey) )
			{
				if ( selected != (qb2S_DebugGui.getPersistentData(m_persistentKey) as Boolean) )
				{
					dispatchEvent(cachedClickEvent);
				}
			}
		}
		
		protected override function onClick(evt:MouseEvent):void
		{
			super.onClick(evt);
			
			qb2S_DebugGui.setPersistentData(m_persistentKey, _selected);
		}
	}
}