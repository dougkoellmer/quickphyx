package quickb2.physics.core.prop 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2CoordProp extends qb2PhysicsProp
	{
		public var X:qb2PhysicsProp;
		public var Y:qb2PhysicsProp;
		public var Z:qb2PhysicsProp;
		
		public function qb2CoordProp(name:String, defaultValue:*, expectedType_nullable:* = null)
		{
			super(name, defaultValue, expectedType_nullable);
			
			defaultValue = defaultValue == null ? 0.0 : defaultValue;
			
			X = new qb2PhysicsProp(name+"_X", defaultValue);
			Y = new qb2PhysicsProp(name+"_Y", defaultValue);
			Z = new qb2PhysicsProp(name+"_Z", defaultValue);
		}
		
		public function getComponentProp(index:int):qb2PhysicsProp
		{
			switch(index)
			{
				case 0:  return X;
				case 1:  return Y;
				case 2:  return Z;
			}
			
			return null;
		}
	}
}