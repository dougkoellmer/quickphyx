package quickb2.debugging.gui.components 
{
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiPushButton extends PushButton
	{
		
		public function qb2DebugGuiPushButton(persistentKey:String = null, parent:DisplayObjectContainer = null, xPos:Number = 0, yPos:Number = 0, label:String = "")
		{
			super(parent, xPos, yPos, label);
		}
	}
}