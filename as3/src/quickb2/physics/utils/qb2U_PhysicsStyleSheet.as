package quickb2.physics.utils 
{
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.geo.bounds.qb2A_GeoBoundingRegion;
	import quickb2.math.qb2A_MathEntity;
	import quickb2.math.qb2S_Math;
	import quickb2.math.qb2U_Math;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.joints.qb2S_JointStyle;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2S_TangibleStyle;
	import quickb2.utils.prop.qb2PropSheet;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_PhysicsStyleSheet extends qb2UtilityClass
	{
		private static const DEFAULT_ALPHA:uint    					= 0xBF000000; // .75
		private static const DEFAULT_POINT_RADIUS:uint				= 3.0;
		private static const DEFAULT_ARROW_SIZE:uint				= 10.0;
		private static const DEFAULT_LINE_THICKNESS:uint			= 1.0;
		private static const DEFAULT_BOUNDING_AREA_LINE_COLOR:uint	= 0x00006633 | DEFAULT_ALPHA;
		private static const DEFAULT_TRACK_COLOR:uint = 0x00999999 | DEFAULT_ALPHA;
		private static const DEFAULT_JOINT_COLOR:uint = 0x00FF9900 | DEFAULT_ALPHA;
		private static const DEFAULT_JOINT_LINE_THICKNESS:Number = 2.0;
		
		public static function createDefaultStyleSheet():qb2PropSheet
		{
			/*var styleSheet:qb2StyleSheet = new qb2StyleSheet();
			
			var mathEntityRule:qb2StyleRule = new qb2StyleRule();
			styleSheet.setRuleForType(mathEntityRule, qb2A_MathEntity);
			{
				var boundsRule:qb2StyleRule = new qb2StyleRule();
				boundsRule.setParam(qb2S_Style.LINE_COLOR, DEFAULT_BOUNDING_AREA_LINE_COLOR);
				styleSheet.setRuleForType(boundsRule, qb2A_GeoBoundingRegion);
			}
			
			var physObjectRule:qb2StyleRule = new qb2StyleRule();
			styleSheet.setRuleForType(physObjectRule, qb2A_PhysicsObject);
			{
				var trackRule:qb2StyleRule = new qb2StyleRule();
				trackRule.setParam(qb2StyleParam.LINE_COLOR, DEFAULT_TRACK_COLOR);
				trackRule.setStyle(qb2StyleParam.ARROW_SIZE, DEFAULT_ARROW_SIZE);
				styleSheet.setRuleForType(trackRule, qb2Track);
				styleSheet.setRuleForPseudoClass(trackRule, qb2Track.PSEUDOTYPE_ARROW);
				
				var jointRule:qb2StyleRule = new qb2StyleRule();
				jointRule.setParam(qb2S_Style.FILL_COLOR, DEFAULT_JOINT_COLOR);
				jointRule.setParam(qb2S_Style.LINE_COLOR, DEFAULT_JOINT_COLOR);
				jointRule.setParam(qb2S_Style.LINE_THICKNESS, DEFAULT_JOINT_LINE_THICKNESS);
				styleSheet.setRuleForType(jointRule, qb2Joint);
				
				var anchorRule:qb2StyleRule = new qb2StyleRule();
				anchorRule.setParam(qb2S_JointStyle.ANCHOR_RADIUS, DEFAULT_POINT_RADIUS);
				styleSheet.setRuleForPseudoClass(anchorRule, qb2S_JointStyle.PSEUDOTYPE_ANCHOR);
				
				{
					var pistonJointRule:qb2StyleRule = new qb2StyleRule();
					pistonJointRule.setParam(qb2PistonJoint.SPRING_COILCOUNT, 10);
					pistonJointRule.setParam(qb2PistonJoint.SPRING_WIDTH, 50);
					pistonJointRule.setParam(qb2PistonJoint.SPRINGBASE_LENGTHRATIO, .5);
					pistonJointRule.setParam(qb2PistonJoint.SPRINGBASE_WIDTH, 40);
					styleSheet.setRuleForPseudoClass(pistonJointRule, qb2PistonJoint.PSEUDOTYPE_SPRING);
					styleSheet.setRuleForPseudoClass(pistonJointRule, qb2PistonJoint.PSEUDOTYPE_SPRINGBASE);
					
					var mouseJointRule:qb2StyleRule = new qb2StyleRule();
					mouseJointRule.setParam(qb2S_JointStyle.ARROW_SIZE, qb2S_JointStyle.DEFAULT_ARROW_SIZE);
					mouseJointRule.setParam(qb2S_JointStyle.ARROW_ANGLE,  qb2S_JointStyle.DEFAULT_ARROW_ANGLE );
					styleSheet.setRuleForPseudoClass(mouseJointRule, qb2S_JointStyle.PSEUDOTYPE_ARROW);
					
					var distanceJointRule:qb2StyleRule = new qb2StyleRule();
					distanceJointRule.setParam(qb2S_JointStyle.DASH_LENGTH, qb2S_JointStyle.DEFAULT_DASH_LENGTH);
					//styleSheet.setRuleForType(distanceJointRule, qb2DistanceJoint);
				}
				
				var tangRule:qb2StyleRule = new qb2StyleRule();
				tangRule.setParam(qb2S_Style.LINE_COLOR, 0x00000000 | DEFAULT_ALPHA);
				tangRule.setParam(qb2S_Style.LINE_THICKNESS, 1);
				styleSheet.setRuleForType(tangRule, qb2A_TangibleObject);
				{
					var dynamicRule:qb2StyleRule = new qb2StyleRule();
					dynamicRule.setParam(qb2S_Style.FILL_COLOR, 0x000000FF | DEFAULT_ALPHA);
					styleSheet.setRuleForPseudoClass(dynamicRule, qb2S_TangibleStyle.PSEUDOTYPE_DYNAMIC);
					
					var staticRule:qb2StyleRule = new qb2StyleRule();
					staticRule.setParam(qb2S_Style.FILL_COLOR, 0x00666666 | DEFAULT_ALPHA);
					styleSheet.setRuleForPseudoClass(staticRule, qb2S_TangibleStyle.PSEUDOTYPE_STATIC);
					
					var backEndRule:qb2StyleRule = new qb2StyleRule();
					backEndRule.setParam(qb2S_Style.LINE_COLOR, 0x00000000 | DEFAULT_ALPHA);
					backEndRule.setOption(qb2S_Style.DISABLE_FILLS, true);
					backEndRule.setOption(qb2S_Style.HIDDEN, true);
					styleSheet.setRuleForPseudoClass(backEndRule, qb2S_TangibleStyle.PSEUDOTYPE_BACKENDREP);
					
					var effectFieldRule:qb2StyleRule = new qb2StyleRule();
					effectFieldRule.addSelectorForType(qb2A_EffectField);
					effectFieldRule.setStyle(qb2StyleParam.FILL_COLOR, 0x00FF6666 | DEFAULT_ALPHA);
					
					var soundEmitterRule:qb2StyleRule = new qb2StyleRule();
					soundEmitterRule.addSelectorForType(qb2SoundEmitter);
					soundEmitterRule.setStyle(qb2StyleParam.FILL_COLOR, 0x00FFFF66 | DEFAULT_ALPHA);
					
					var terrainRule:qb2StyleRule = new qb2StyleRule();
					terrainRule.addSelectorForType(qb2Terrain);
					terrainRule.setStyle(qb2StyleParam.FILL_COLOR, 0x00006600 | DEFAULT_ALPHA);
					
					var tripSensorRule:qb2StyleRule = new qb2StyleRule();
					tripSensorRule.addSelectorForType(qb2TripSensor);
					tripSensorRule.setStyle(qb2StyleParam.FILL_COLOR, 0x00990099 | DEFAULT_ALPHA);
				}
			}
			
			return styleSheet;*/
			
			return null;
		}
		
		/*public static var vertexColor:uint           = 0x00000000;
		public static var vertexAlpha:Number         = DEFAULT_ALPHA;
		
		public static var positionColor:uint         = 0x00000000;
		public static var positionAlpha:Number       = DEFAULT_ALPHA;
		
		
		public static var centroidColor:uint         = 0x0000FFFF;
		public static var centroidAlpha:Number       = DEFAULT_ALPHA;
		
		public static var boundBoxStartDepth:uint    = 1;
		public static var boundBoxEndDepth:uint      = 1;
		
		public static var boundCircleStartDepth:uint = 1;
		public static var boundCircleEndDepth:uint   = 1;
		
		public static var centroidStartDepth:uint    = 1;
		public static var centroidEndDepth:uint      = 1;
		
		public static var frictionPointColor:Number  = 0x00FF0000;
		public static var frictionPointAlpha:Number  = DEFAULT_ALPHA;
		
		public static var tireFillColor:uint    = 0x00000000;
		public static var tireOutlineColor:uint = 0x00FFFFFF;
		public static var tireLoadColor:uint    = 0x00FF0000;
	
		public static var tireNumRotLines:uint  = 4;
		public static var tireLoadAlphaScale:Number = 20;
		public static var tireScale:Number = 1;
		
		public static var skidColor:uint  = 0x00000000;
		
		public static var tetherColor:uint = 0x0000FF00;
		public static var tetherThickness:Number = 2;
		public static var tetherAlpha:Number = 0xBF000000;
		
		public static var antennaColor:uint = 0x00CC00FF;
		
		public static var infiniteForDrawing:Number = 10000;*/
	}
}