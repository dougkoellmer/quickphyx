package quickb2.debugging.gui 
{
	import com.bit101.components.Window;
	import flash.display.Stage;
	import quickb2.debugging.logging.qb2I_Printer;
	import quickb2.debugging.logging.qb2S_Print;

	/**
	 * ...
	 * @author 
	 */
	public class qb2DebugGuiFlashConsole extends Window implements qb2I_Printer
	{
		public function qb2DebugGuiFlashConsole(stage:Stage) 
		{
			qb2S_Print.printers.push(this);
		}
		
		public function print(...args):void
		{
			
		}
	}
}