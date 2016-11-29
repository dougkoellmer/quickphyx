package quickb2.physics.core.joints 
{
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.style.qb2CompiledStyleRule;
	import quickb2.display.immediate.style.qb2StyleSheet;
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.prop.qb2E_JointType;
	import quickb2.physics.utils.qb2U_Joint;
	import quickb2.utils.prop.qb2PropMap;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2P_MouseJointComponent extends qb2PA_JointComponent
	{
		public function qb2P_MouseJointComponent() 
		{
			super(qb2E_JointType.MOUSE);
		}
		
		public override function draw(joint:qb2Joint, graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			graphics.getTransformStack().pushAndSet(qb2S_Math.IDENTITY_MATRIX);
			
			qb2U_Joint.calcGlobalAnchorA(this, s_utilPoint1);
			qb2U_Joint.calcGlobalAnchorB(this, s_utilPoint2);
			
			drawAnchor(s_utilPoint1, graphics, propertyMap_nullable);
			
			s_utilPoint2.calcDelta(s_utilPoint1, s_utilVector);
			if ( s_utilVector.calcLengthSquared() >= 1 )
			{
				s_utilMatrix.setToTranslation(s_utilPoint1);
				graphics.getTransformStack().pushAndConcat(s_utilMatrix);
				
				if ( styleSheet_nullable == null )
				{
					s_utilVector.draw(graphics);
				}
				else
				{
					s_utilVector.draw(graphics, propertyMap_nullable);				
				}
				
				graphics.getTransformStack().pop();
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
		
		*/
	}

}