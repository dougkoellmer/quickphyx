package quickb2.debugging.gui.subpanels 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2DebugGuiSubPanelAbout extends qb2DebugGuiSubPanel
	{
		[Embed(source = '../qb2Logo_tiny.png')]
		private static var LogoClass:Class;
		private var m_logoBitmap:Bitmap = new LogoClass;
		private var m_logo:Sprite = new Sprite();
		
		public function qb2DebugGuiSubPanelAbout() 
		{
			initialize();
		}
		
		private function initialize():void
		{
			m_name = "About";
			
			m_logo.addChild(m_logoBitmap);
			//logo.scaleX = logo.scaleY = .5;
			m_logo.x = stepButton.x + stepButton.width / 2 - m_logo.width / 2;
			m_logo.y = stepButton.y - m_logo.height - 7;
			addChild(m_logo);
			m_logo.buttonMode = true;
			m_logo.mouseChildren = false;
			m_logo.addEventListener(MouseEvent.CLICK, goToOpenSourcePage, false, 0, true);
		}
		
		private function goToOpenSourcePage(evt:MouseEvent):void
		{
			navigateToURL(new URLRequest("http://code.google.com/p/quickb2"), "_blank");
		}
	}
}