package quickb2.physics.core.bridge 
{
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.utils.prop.qb2MutablePropFlags;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2P_PropertiesNeedingTransform extends qb2MutablePropFlags
	{
		public function qb2P_PropertiesNeedingTransform()
		{
			this.setBit(qb2S_PhysicsProps.GEOMETRY, true);
			this.setBit(qb2S_PhysicsProps.CURVE_POINT_COUNT, true);
			this.setBit(qb2S_PhysicsProps.MAX_CURVE_TESSELLATION_POINTS, true);
			this.setBit(qb2S_PhysicsProps.CURVE_TESSELLATION, true);
			this.setBit(qb2S_PhysicsProps.CURVE_THICKNESS, true);
			this.setBit(qb2S_PhysicsProps.CURVES_HAVE_ROUNDED_CAPS, true);
			this.setBit(qb2S_PhysicsProps.CURVES_HAVE_ROUNDED_CORNERS, true);
			this.setBit(qb2S_PhysicsProps.PIXELS_PER_METER, true);
			this.setBit(qb2S_PhysicsProps.CENTER_OF_MASS, true);
			this.setBit(qb2S_PhysicsProps.CENTER_OF_MASS.X, true);
			this.setBit(qb2S_PhysicsProps.CENTER_OF_MASS.Y, true);
			this.setBit(qb2S_PhysicsProps.CENTER_OF_MASS.Z, true);
		}
	}
}