package quickb2.utils.prop 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2PropValueSet 
	{
		private var m_values:Vector.<*>;
		
		public function qb2PropValueSet(length:int) 
		{
			m_values = new Vector.<*>(length, true);
		}
		
		public function getValue(index:int):*
		{
			return m_values[index];
		}
		
		public function setValue(index:int, value:*):void
		{
			m_values[index] = value;
		}
		
		public function setAllValues(value:*):void
		{
			for ( var i:int = 0; i < m_values.length; i++ )
			{
				m_values[i] = value;
			}
		}
		
		public function getLength():int
		{
			return m_values.length;
		}
		
		public function clear():void
		{
			setAllValues(null);
		}
	}
}