package quickb2.physics.core.joints 
{
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.style.qb2CompiledStyleRule;
	import quickb2.display.immediate.style.qb2StyleSheet;
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.physics.utils.qb2U_Joint;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2P_DistanceJointComponent extends qb2PA_JointComponent
	{
		public function qb2P_DistanceJointComponent() 
		{
			super(qb2E_JointType.DISTANCE);
		}
		
		public override function draw(joint:qb2Joint, graphics:qb2I_Graphics2d, styleSheet_nullable:qb2StyleSheet = null):void
		{
			graphics.getTransformStack().pushAndSet(qb2S_Math.IDENTITY_MATRIX);
			
			qb2U_Joint.calcGlobalAnchorA(joint, s_utilPoint1);
			qb2U_Joint.calcGlobalAnchorB(joint, s_utilPoint2);
			
			//drawAnchor(s_utilPoint1, graphics, styleSheet_nullable);
			//drawAnchor(s_utilPoint2, graphics, styleSheet_nullable);
			
			var dashLength:Number;
			var styleRule:qb2CompiledStyleRule;
			if ( styleSheet_nullable != null )
			{
				styleRule = styleSheet_nullable.getCompiledRuleForInstance(this);
				styleRule.populateGraphics(graphics);
				dashLength = styleRule.getParam(qb2S_JointStyle.DASH_LENGTH);
			}
			else
			{
				dashLength = qb2S_JointStyle.DEFAULT_DASH_LENGTH;
			}
			
			graphics.pushParam(qb2E_DrawParam.FILL_COLOR, 0);
			
			s_utilPoint2.calcDelta(s_utilPoint1, s_utilVector);
			var distance:Number = s_utilVector.calcLength();
			s_utilVector.setLength(dashLength);
			var dashCount:int = Math.round(distance / dashLength);
			var actualDashLength:Number = distance / (dashCount as Number);
			graphics.moveTo(s_utilPoint1);
			
			for (var i:int = 0; i < dashCount; i++) 
			{
				s_utilPoint1.translateBy(s_utilVector);
				
				if ( i % 2 == 0 )
				{
					graphics.drawLineTo(s_utilPoint1);
				}
				else
				{
					graphics.moveTo(s_utilPoint1);
				}
			}
			
			graphics.popParam(qb2E_DrawParam.FILL_COLOR);
			
			if ( styleSheet_nullable != null )
			{
				styleRule.depopulateGraphics(graphics);
			}
			
			graphics.getTransformStack().pop();
		}
		
		/*public override function setProperty(property:qb2PhysicsProp, value:*):void
		{
			super.setProperty(property, value);
			
			if ( property == qb2S_PhysicsProps.LENGTH )
			{
				this.setProperty(qb2S_PhysicsProps.IS_SLEEPING, true);
			}
		}
		
		protected override function onAttachmentsChanged():void
		{
			updateLength();
		}
		
		protected override function onAnchorsChanged():void
		{
			updateLength();
		}
		
		private function updateLength():void
		{
			if ( !this.getEffectiveProp(qb2S_PhysicsProps.IS_LENGTH_AUTO_SET) )  return;
		
			if ( hasAttachments() )
			{
				var length:Number = qb2U_Joint.calcAnchorDistance(this);
				
				this.setProperty(qb2S_PhysicsProps.LENGTH, length);
			}
		}*/
	}

}