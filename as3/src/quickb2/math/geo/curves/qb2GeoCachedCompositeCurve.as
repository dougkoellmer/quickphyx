package quickb2.math.geo.curves 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2GeoCachedCompositeCurve extends qb2GeoCompositeCurve
	{
		private var m_length:Number;
		private var m_dirty:Boolean = false;
		
		public function qb2GeoCachedCompositeCurve() 
		{
			
		}
		
		protected override function onChanged():void
		{
			super.onChanged();
			
			m_dirty = true;
		}
		
		public override function calcLength():Number
		{
			if ( m_dirty )
			{
				m_length = super.calcLength();
				m_dirty = false;
			}
			
			return m_length;
		}
	}
}