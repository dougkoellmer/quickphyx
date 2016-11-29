package quickb2.physics.core.prop 
{
	import quickb2.display.retained.qb2I_Actor;
	import quickb2.lang.foundation.qb2SettingsClass;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.utils.prop.qb2E_SpecialPropValue;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2S_PhysicsProps extends qb2SettingsClass
	{
		// for tangibles
		public static const IS_ACTIVE:qb2PhysicsProp						= new qb2PhysicsProp("IS_ACTIVE", true);
		public static const IS_SLEEPING:qb2PhysicsProp						= new qb2PhysicsProp("IS_SLEEPING", false);		
		public static const IS_BULLET:qb2PhysicsProp						= new qb2PhysicsProp("IS_BULLET", false);
		public static const IS_GHOST:qb2PhysicsProp							= new qb2PhysicsProp("IS_GHOST", false);
		public static const IS_SLEEPING_ALLOWED:qb2PhysicsProp				= new qb2PhysicsProp("IS_SLEEPING_ALLOWED", true);
		public static const IS_SLEEPING_WHEN_ADDED:qb2PhysicsProp			= new qb2PhysicsProp("IS_SLEEPING_WHEN_ADDED", false);
		public static const IS_DEBUG_DRAGGABLE:qb2PhysicsProp				= new qb2PhysicsProp("IS_DEBUG_DRAGGABLE", true);
		public static const IS_ROTATIONALLY_FIXED:qb2PhysicsProp			= new qb2PhysicsProp("IS_ROTATIONALLY_FIXED", false);
		public static const IS_SLICEABLE:qb2PhysicsProp						= new qb2PhysicsProp("IS_SLICEABLE", true);
		public static const IS_PARTIALLY_SLICEABLE:qb2PhysicsProp			= new qb2PhysicsProp("IS_PARTIALLY_SLICEABLE", true);
		public static const IS_DECOMPOSABLE:qb2PhysicsProp					= new qb2PhysicsProp("IS_DECOMPOSABLE", true);
		public static const CURVES_HAVE_ROUNDED_CAPS:qb2PhysicsProp			= new qb2PhysicsProp("CURVES_HAVE_ROUNDED_CAPS", true);
		public static const CURVES_HAVE_ROUNDED_CORNERS:qb2PhysicsProp		= new qb2PhysicsProp("CURVES_HAVE_ROUNDED_CORNERS", true);
		
		internal static const REPORTS_CONTACT_STARTED:qb2PhysicsProp		= new qb2PhysicsProp("REPORTS_CONTACT_STARTED", false);
		internal static const REPORTS_CONTACT_ENDED:qb2PhysicsProp			= new qb2PhysicsProp("REPORTS_CONTACT_ENDED", false);
		internal static const REPORTS_PRE_SOLVE:qb2PhysicsProp				= new qb2PhysicsProp("REPORTS_PRE_SOLVE", false);
		internal static const REPORTS_POST_SOLVE:qb2PhysicsProp				= new qb2PhysicsProp("REPORTS_POST_SOLVE", false);
		
		// for joints
		public static const COLLIDE_JOINT_ATTACHMENTS:qb2PhysicsProp		= new qb2PhysicsProp("COLLIDE_JOINT_ATTACHMENTS", true);
		public static const IS_SPRING_OPTIMIZED:qb2PhysicsProp				= new qb2PhysicsProp("IS_SPRING_OPTIMIZED", true);
		public static const IS_SPRING_FLIPPABLE:qb2PhysicsProp				= new qb2PhysicsProp("IS_SPRING_FLIPPABLE", false);
		public static const IS_ROPE:qb2PhysicsProp							= new qb2PhysicsProp("IS_ROPE", false);
		public static const IS_LENGTH_AUTO_SET:qb2PhysicsProp				= new qb2PhysicsProp("IS_LENGTH_AUTO_SET", true);
		public static const IS_DIRECTION_AUTO_SET:qb2PhysicsProp			= new qb2PhysicsProp("IS_DIRECTION_AUTO_SET", true);
		public static const IS_FREELY_ROTATEABLE:qb2PhysicsProp				= new qb2PhysicsProp("IS_FREELY_ROTATEABLE", false);
		
		
		public static const LINEAR_VELOCITY_LENGTH_UNIT:qb2PhysicsProp		= new qb2PhysicsProp("LINEAR_VELOCITY_LENGTH_UNIT", qb2E_LengthUnit.PIXELS.getOrdinal());
		public static const GRAVITY_LENGTH_UNIT:qb2PhysicsProp				= new qb2PhysicsProp("GRAVITY_LENGTH_UNIT", qb2E_LengthUnit.METERS.getOrdinal());
		public static const DENSITY_LENGTH_UNIT:qb2PhysicsProp				= new qb2PhysicsProp("DENSITY_LENGTH_UNIT", qb2E_LengthUnit.METERS.getOrdinal());
		public static const FORCE_LENGTH_UNIT:qb2PhysicsProp				= new qb2PhysicsProp("FORCE_LENGTH_UNIT", qb2E_LengthUnit.METERS.getOrdinal());
		
		public static const JOINT_TYPE:qb2PhysicsProp						= new qb2PhysicsProp("JOINT_TYPE", -1);
		
		public static const RESTITUTION:qb2PhysicsProp						= new qb2PhysicsProp("RESTITUTION", 0.0);
		public static const FRICTION:qb2PhysicsProp							= new qb2PhysicsProp("FRICTION", 0.2);
		public static const FRICTION_Z:qb2PhysicsProp						= new qb2PhysicsProp("FRICTION_Z", 0.0);
		public static const LINEAR_DAMPING:qb2PhysicsProp					= new qb2PhysicsProp("LINEAR_DAMPING", 0.0);
		public static const ANGULAR_DAMPING:qb2PhysicsProp					= new qb2PhysicsProp("ANGULAR_DAMPING", 0.0);
		public static const CURVE_TESSELLATION:qb2PhysicsProp				= new qb2PhysicsProp("CURVE_TESSELLATION", 20.0);
		public static const CURVE_POINT_COUNT:qb2PhysicsProp				= new qb2PhysicsProp("CURVE_POINT_COUNT", 0);
		public static const MAX_CURVE_TESSELLATION_POINTS:qb2PhysicsProp	= new qb2PhysicsProp("MAX_CURVE_TESSELLATION_POINTS", 250);
		public static const CURVE_THICKNESS:qb2PhysicsProp					= new qb2PhysicsProp("CURVE_THICKNESS", 1.0);
		public static const Z_HEIGHT:qb2PhysicsProp							= new qb2PhysicsProp("Z_HEIGHT", 0.0);
		public static const POINT_RADIUS:qb2PhysicsProp						= new qb2PhysicsProp("POINT_RADIUS", 1.0);
		
		public static const LENGTH:qb2PhysicsProp							= new qb2PhysicsProp("LENGTH", 0.0);
		public static const FREQUENCY_HZ:qb2PhysicsProp						= new qb2PhysicsProp("FREQUENCY_HZ", 5.0);
		public static const DAMPING_RATIO:qb2PhysicsProp					= new qb2PhysicsProp("DAMPING_RATIO", 0.7);
		public static const MAX_FORCE:qb2PhysicsProp						= new qb2PhysicsProp("MAX_FORCE", 100.0);
		public static const MAX_TORQUE:qb2PhysicsProp						= new qb2PhysicsProp("MAX_TORQUE", 0.0);
		public static const SPRING_K:qb2PhysicsProp							= new qb2PhysicsProp("SPRING_K", 0.0);
		public static const SPRING_DAMPING:qb2PhysicsProp					= new qb2PhysicsProp("SPRING_DAMPING", 0.0);
		public static const TARGET_SPEED:qb2PhysicsProp						= new qb2PhysicsProp("TARGET_SPEED", 0.0);
		public static const REFERENCE_ANGLE:qb2PhysicsProp					= new qb2PhysicsProp("REFERENCE_ANGLE", 0.0);
		public static const LOWER_LIMIT:qb2PhysicsProp						= new qb2PhysicsProp("LOWER_LIMIT", -Infinity);
		public static const UPPER_LIMIT:qb2PhysicsProp						= new qb2PhysicsProp("UPPER_LIMIT",  Infinity);
		public static const PIXELS_PER_METER:qb2PhysicsProp					= new qb2PhysicsProp("PIXELS_PER_METER", 1.0);
		public static const MASS:qb2PhysicsProp								= new qb2PhysicsProp("MASS", 0.0);
		public static const DENSITY:qb2PhysicsProp							= new qb2PhysicsProp("DENSITY", 0.0);
		public static const ROTATION:qb2PhysicsProp							= new qb2PhysicsProp("ROTATION", 0.0);
		public static const ANGULAR_VELOCITY:qb2PhysicsProp					= new qb2PhysicsProp("ANGULAR_VELOCITY", 0.0);		
		
		public static const ACTOR:qb2PhysicsProp							= new qb2PhysicsProp("ACTOR", null, qb2I_Actor);
		public static const ATTACHMENT_A:qb2PhysicsProp						= new qb2PhysicsProp("ATTACHMENT_A", null, qb2A_TangibleObject);
		public static const ATTACHMENT_B:qb2PhysicsProp						= new qb2PhysicsProp("ATTACHMENT_B", null, qb2A_TangibleObject);
		public static const CONTACT_FILTER:qb2PhysicsProp					= new qb2PhysicsProp("CONTACT_FILTER", null, qb2ContactFilter);
		public static const GEOMETRY:qb2PhysicsProp							= new qb2PhysicsProp("GEOMETRY", null, qb2A_GeoEntity);
		
		public static const ANCHOR_A:qb2CoordProp							= new qb2CoordProp("ANCHOR_A", null, qb2GeoPoint);
		public static const ANCHOR_B:qb2CoordProp							= new qb2CoordProp("ANCHOR_B", null, qb2GeoPoint);
		public static const POSITION:qb2CoordProp							= new qb2CoordProp("POSITION", null, qb2GeoPoint);
		public static const CENTER_OF_MASS:qb2CoordProp						= new qb2CoordProp("CENTER_OF_MASS", qb2E_SpecialPropValue.AUTO, qb2GeoPoint);
		public static const LINEAR_VELOCITY:qb2CoordProp					= new qb2CoordProp("LINEAR_VELOCITY", null, qb2GeoVector);
		public static const GRAVITY:qb2CoordProp							= new qb2CoordProp("GRAVITY", null, qb2GeoVector);
		
		
		/**
		 * The relationship between the physics world in meters and the Flash world in pixels.
		 * 30 pixels per 1 meter seems to be a good ratio for most simulations.
		 * ALL units passed back and forth through qb2World are in pixels, for convenience.
		 * 
		 * @default 30.0
		 */
	}
}