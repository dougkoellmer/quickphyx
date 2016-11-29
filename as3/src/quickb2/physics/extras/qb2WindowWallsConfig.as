package quickb2.physics.extras 
{
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2WindowWallsConfig extends Object
	{		
		public var minWidth:Number = 300;
		public var maxWidth:Number = 2000;
		public var minHeight:Number = 300;
		public var maxHeight:Number = 2000;
		public var overhang:Number = 0;
		public var wallThickness:Number = 1000;
		
		public var instantlyResize:Boolean = true;
		
		public function copy(otherConfig:qb2WindowWallsConfig):void
		{
			this.minWidth = otherConfig.minWidth;
			this.maxWidth = otherConfig.maxWidth;
			this.minHeight = otherConfig.minHeight;
			this.maxHeight = otherConfig.maxHeight;
			
			this.overhang      = otherConfig.overhang;
			this.instantlyResize  = otherConfig.instantlyResize;
			this.wallThickness = otherConfig.wallThickness;
		}
	}
}