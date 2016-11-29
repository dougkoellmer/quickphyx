package quickb2.platform 
{
	import quickb2.event.qb2I_EventDispatcher;
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	
	[Event(name="RESIZED", type="quickb2.event.qb2ScreenEvent")]
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public interface qb2I_Window extends qb2I_EventDispatcher
	{
		function getWindowTop():Number;
		function getWindowLeft():Number;
		function getWindowWidth():Number;
		function getWindowHeight():Number;
	}
}