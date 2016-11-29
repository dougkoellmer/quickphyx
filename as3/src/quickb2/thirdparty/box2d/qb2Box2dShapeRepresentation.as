package quickb2.thirdparty.box2d
{
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import quickb2.display.immediate.graphics.*;
	import quickb2.lang.foundation.*;
	import quickb2.lang.operators.*;
	import quickb2.lang.types.*;
	import quickb2.math.*;
	import quickb2.math.geo.*;
	import quickb2.math.geo.bounds.*;
	import quickb2.math.geo.coords.*;
	import quickb2.math.geo.curves.*;
	import quickb2.math.geo.curves.iterators.*;
	import quickb2.math.geo.surfaces.planar.*;
	import quickb2.physics.core.*;
	import quickb2.physics.core.backend.*;
	import quickb2.physics.core.prop.qb2E_LengthUnit;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2PS_PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.prop.qb2PU_PhysicsProp;
	import quickb2.physics.core.tangibles.*;
	import quickb2.physics.utils.qb2U_Geom;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.prop.qb2PropValueSet;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public final class qb2Box2dShapeRepresentation extends qb2Box2dBodyRepresentation implements qb2I_BackEndShape
	{
		private static const INERTIA_UNDEFINED:Number = -1;
		private static const INVALID_POINT_COUNT:int = -1;
		private static const NORMALIZED_MASS:Number = 1;
		
		private static const s_utilValueSet:qb2PropValueSet = new qb2PropValueSet(3);
		private static const s_utilMatrix:qb2AffineMatrix = new qb2AffineMatrix();
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		private static const s_utilVector2:qb2GeoVector = new qb2GeoVector();
		private static const s_utilFilter:Object = new Object();

		
		private const m_box2dFixtures:Vector.<b2Fixture> = new Vector.<b2Fixture>();
		private const m_massData:qb2MassData = new qb2MassData();
		
		public override function makeBox2dObject(propertyMap:qb2PropMap, transform:qb2AffineMatrix, rotationStack:Number, result_out:qb2BackEndResult):void
		{
			result_out.set(qb2E_BackEndResult.SUCCESS);
			
			if ( m_box2dFixtures.length > 0 )
			{
				qb2_assert(false);
				return;
			}
			
			if ( makeBox2dObject_earlyOut(result_out) )  return;
			
			var geometry:qb2A_GeoEntity = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.GEOMETRY);
			
			if ( geometry == null )
			{
				return;
			}
			
			var ancestorBody:qb2Body = getPhysicsObject().getAncestorBody();
			
			var box2dBody:b2Body = null;
		
			if ( ancestorBody != null )
			{
				box2dBody = (ancestorBody.getBackEndRepresentation() as qb2Box2dBodyRepresentation).getBox2dBody();
				
				qb2_assert(box2dBody != null);
			}
			else
			{
				super.makeBox2dObject(propertyMap, transform, rotationStack, result_out);
				
				box2dBody = this.getBox2dBody();
				
				transform = null;
			}
			
			makeBox2dFixtures(transform, propertyMap);
		}
		
		private function makeBox2dFixtures(transform_nullable:qb2AffineMatrix, propertyMap:qb2PropMap):void
		{
			m_massData.momentOfInertia = INERTIA_UNDEFINED;
			
			var geometry:qb2A_GeoEntity = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.GEOMETRY);
			if ( geometry == null )
			{
				return;
			}
			
			var box2dBody:b2Body = null;
			
			if ( getPhysicsObject().getAncestorBody() == null )
			{
				box2dBody = this.getBox2dBody();
			}
			else
			{
				box2dBody = (this.getPhysicsObject().getAncestorBody().getBackEndRepresentation() as qb2Box2dBodyRepresentation).getBox2dBody();
			}
			
			qb2U_Box2dFixtureMaking.makeFixturesFromGeometry(propertyMap, transform_nullable, box2dBody, this.m_box2dFixtures);
			setUserDataOnFixtures();
			
			var mass:Number = propertyMap.getProperty(qb2S_PhysicsProps.MASS);
			
			if ( mass > 0 )
			{
				queueForMassReset();
				
				var explicitlySetLocalCenterOfMass:Boolean = tryToSetExplicitLocalCenterOfMass(propertyMap, null, s_utilValueSet);
				recalculateMassProperties(transform_nullable, propertyMap, !explicitlySetLocalCenterOfMass);
				if ( !explicitlySetLocalCenterOfMass )
				{
					adjustLocalCenterOfMassIfNeeded(propertyMap, s_utilValueSet);
				}
				transformLocalMassPropertiesToRigidRoot(transform_nullable, propertyMap);
			}
			else
			{
				m_massData.momentOfInertia = 0;
			}
			
			this.setBox2dNumericProperties(propertyMap, null);
			this.setBox2dBooleanProperties(propertyMap, null);
			this.setContactReporting(propertyMap, null);
		}
		
		private function setUserDataOnFixtures():void
		{
			for ( var i:int = 0; i < m_box2dFixtures.length; i++ )
			{
				m_box2dFixtures[i].SetUserData(this);
			}
		}
		
		private function updateGeometry(transform_nullable:qb2AffineMatrix, propertyMap:qb2PropMap, result_out:qb2BackEndResult):void
		{
			result_out.set(qb2E_BackEndResult.SUCCESS);
			
			if ( getWorldRepresentation().isLocked() )
			{
				result_out.set(qb2E_BackEndResult.TRY_AGAIN_LATER);
			}
			
			this.destroyBox2dFixtures(true);
			
			makeBox2dFixtures(transform_nullable, propertyMap);
		}
		
		private function destroyBox2dFixtures(actuallyDestroyFixtures:Boolean):void
		{
			if ( actuallyDestroyFixtures && m_box2dFixtures.length > 0 )
			{
				queueForMassReset();
			}
			
			for ( var i:int = 0; i < m_box2dFixtures.length; i++ )
			{
				var fixture:b2Fixture = m_box2dFixtures[i];
				
				fixture.SetUserData(null);
				
				if ( actuallyDestroyFixtures )
				{
					fixture.GetBody().DestroyFixture(fixture);
				}
			}
			
			m_box2dFixtures.length = 0;
		}
		
		public override function destroyBox2dObject():void
		{
			if ( getBox2dBody() == null )
			{
				this.destroyBox2dFixtures(true);
			}
			else
			{
				//--- DRK > If this is a "solo" shape, destroying the b2Body implicitly destroys the fixtures,
				//---		which chains down into this::onImplicitlyDestroyed() then destroyBox2dFixtures(false).
				//---		We prefer the implicit route because it's a little more efficient for Box2d.
				super.destroyBox2dObject();
			}
		}
		
		public function onImplicitlyDestroyed():void
		{
			this.destroyBox2dFixtures(false);
		}
		
		internal override function queueForMassReset():void
		{
			if ( getBox2dBody() != null )
			{
				super.queueForMassReset();
			}
			else
			{
				//--- DRK > Here, we have to get this shape's body. Normally we could go through the tangible's 
				//---		ancestorBody and get its body representation, but if this method is called from the 
				//---		destroy queue in the world representation, then that link might have been lost.
				var firstFixture:b2Fixture = m_box2dFixtures.length > 0 ? m_box2dFixtures[0] : null;
				
				//--- DRK > Fixture may have been nulled out by an implicit destroy from somewhere.
				if (firstFixture != null )
				{
					//--- DRK > Don't think this should ever turn up null if firstFixture isn't null.
					var bodyRep:qb2Box2dBodyRepresentation = firstFixture.GetBody().GetUserData() as qb2Box2dBodyRepresentation;
					
					if ( bodyRep != null )
					{
						bodyRep.queueForMassReset();
					}
					else
					{
						qb2_assert(false);
					}
				}
			}
		}
		
		public override function updateTransform(transform_nullable:qb2AffineMatrix, rotationStack:Number, pixelsPerMeter:Number, result_out:qb2BackEndResult):void
		{
			result_out.set(qb2E_BackEndResult.SUCCESS);
			
			if ( getWorldRepresentation().isLocked() )
			{
				result_out.set(qb2E_BackEndResult.TRY_AGAIN_LATER);
			}
			
			if ( getBox2dBody() != null )
			{
				super.updateTransform(transform_nullable, rotationStack, pixelsPerMeter, result_out);
			}
			else
			{
				//TODO: Take current fixtures, and ideally just shift them and recompute mass or something...
				//		probably have to recreate them, but should do so somehow using existing fixtures...essentially cloning them and repositioning them.
				//		This is to save on the relatively potentially high cost of remaking them from scratch from front-end geometry.
			}
		}
	
		public function draw(graphics:qb2I_Graphics2d, pixelsPerMeter:Number):void
		{
			var objectSpace:qb2A_PhysicsObject = getPhysicsObject().getAncestorBody() != null ? getPhysicsObject().getAncestorBody() : getPhysicsObject();
			
			qb2U_Box2dDraw.drawShapes(m_box2dFixtures, graphics, objectSpace, pixelsPerMeter);
		}
		
		protected override function setBox2dBooleanProperties(propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void
		{
			super.setBox2dBooleanProperties(propertyMap, changeFlags_nullable);
			
			if ( m_box2dFixtures.length == 0 )  return;
			
			if ( !qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_GHOST, changeFlags_nullable) && !qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_ACTIVE, changeFlags_nullable) )  return;
			
			var isGhost:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_GHOST);
			var isActive:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_ACTIVE);
			
			if ( !isActive )
			{
				isGhost = true;
			}
			
			for ( var i:int = 0; i < m_box2dFixtures.length; i++ )
			{
				var fixture:b2Fixture = m_box2dFixtures[i];
				fixture.SetSensor(isGhost);
			}
		}
		
		protected override function setBox2dNumericProperties(propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void
		{
			super.setBox2dNumericProperties(propertyMap, changeFlags_nullable);
			
			if ( m_box2dFixtures.length == 0 )  return;
			
			var isFrictionChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.FRICTION, changeFlags_nullable);
			var isRestitutionChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.RESTITUTION, changeFlags_nullable);
			
			if ( !isFrictionChanged && !isRestitutionChanged )  return;
			
			var friction:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.FRICTION);
			var restitution:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.RESTITUTION);
			
			for ( var i:int = 0; i < m_box2dFixtures.length; i++ )
			{
				var fixture:b2Fixture = m_box2dFixtures[i];
				
				if ( isFrictionChanged )
				{
					fixture.SetFriction(friction);
				}
				
				if ( isRestitutionChanged )
				{
					fixture.SetRestitution(restitution);
				}
			}
		}
		
		private function setContactReporting(propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags):void
		{
			var reportContactStartChanged:Boolean	= qb2U_Box2d.isChangeFlagSet(qb2PS_PhysicsProp.REPORTS_CONTACT_STARTED, changeFlags_nullable);
			var reportContactEndChanged:Boolean		= qb2U_Box2d.isChangeFlagSet(qb2PS_PhysicsProp.REPORTS_CONTACT_ENDED, changeFlags_nullable);
			var reportPreSolveChanged:Boolean		= qb2U_Box2d.isChangeFlagSet(qb2PS_PhysicsProp.REPORTS_PRE_SOLVE, changeFlags_nullable);
			var reportPostSolveChanged:Boolean		= qb2U_Box2d.isChangeFlagSet(qb2PS_PhysicsProp.REPORTS_POST_SOLVE, changeFlags_nullable);
			var isActiveChanged:Boolean				= qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_ACTIVE, changeFlags_nullable);
			
			if ( !reportContactStartChanged && !reportContactEndChanged && !reportPreSolveChanged && !reportPostSolveChanged && !isActiveChanged)  return;
			
			var isActive:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_ACTIVE);
			var reportContactStart:Boolean = isActive && propertyMap.getPropertyOrDefault(qb2PS_PhysicsProp.REPORTS_CONTACT_STARTED);
			var reportContactEnd:Boolean = isActive && propertyMap.getPropertyOrDefault(qb2PS_PhysicsProp.REPORTS_CONTACT_ENDED);
			var reportPreSolve:Boolean = isActive && propertyMap.getPropertyOrDefault(qb2PS_PhysicsProp.REPORTS_PRE_SOLVE);
			var reportPostSolve:Boolean = isActive && propertyMap.getPropertyOrDefault(qb2PS_PhysicsProp.REPORTS_POST_SOLVE);
			
			for ( var i:int = 0; i < m_box2dFixtures.length; i++ )
			{
				var fixture:b2Fixture = m_box2dFixtures[i];
				
				fixture.m_reportBeginContact = reportContactStart;
				fixture.m_reportEndContact = reportContactEnd;
				fixture.m_reportPreSolve = reportPreSolve;
				fixture.m_reportPostSolve = reportPostSolve;
			}
		}
		
		public override function setProperties(propertyMap:qb2PropMap, changeFlags:qb2PropFlags, transform_nullable:qb2AffineMatrix, result_out:qb2BackEndResult):void
		{
			result_out.set(qb2E_BackEndResult.SUCCESS);
			
			if ( setProperties_earlyOut(changeFlags, result_out) )  return;
				
			if ( qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.GEOMETRY, changeFlags) ||
				 qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.PIXELS_PER_METER, changeFlags) )
			{
				updateGeometry(transform_nullable, propertyMap, result_out);
				
				return;
			}
			
			var tessellationChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.CURVE_TESSELLATION, changeFlags) || qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.CURVE_POINT_COUNT, changeFlags) || qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.MAX_CURVE_TESSELLATION_POINTS, changeFlags);
			var styleChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.CURVES_HAVE_ROUNDED_CAPS, changeFlags) || qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.CURVES_HAVE_ROUNDED_CORNERS, changeFlags) || qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.CURVE_THICKNESS, changeFlags);
			var geometry:qb2A_GeoEntity = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.GEOMETRY);
			
			if ( tessellationChanged || styleChanged && qb2U_Type.isKindOf(geometry, qb2A_GeoCurve) )
			{
				var curve:qb2A_GeoCurve = qb2U_Box2d.getCurve(geometry);
				
				if ( curve != null )
				{
					if ( getWorldRepresentation().isLocked() )
					{
						result_out.set(qb2E_BackEndResult.TRY_AGAIN_LATER);
						
						return;
					}
					else
					{
						updateGeometry(transform_nullable, propertyMap, result_out);
						
						return;
					}
				}
			}
			else
			{
				handleCenterOfMassChange(propertyMap, changeFlags, transform_nullable, result_out);
				
				if( !result_out.isSuccess() )
				{
					return;
				}
				
				var isDensityChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.DENSITY, changeFlags);
				var isDensityUnitChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.DENSITY_LENGTH_UNIT, changeFlags);
				var isMassChanged:Boolean = qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.MASS, changeFlags);
				var isActiveChanged:Boolean = getBox2dBody() == null && qb2U_Box2d.isChangeFlagSet(qb2S_PhysicsProps.IS_ACTIVE, changeFlags);
				
				if ( isDensityChanged || isMassChanged || isDensityUnitChanged || isActiveChanged )
				{
					if ( getWorldRepresentation().isLocked() )
					{
						result_out.set(qb2E_BackEndResult.TRY_AGAIN_LATER);
						
						return;
					}
					
					queueForMassReset();
					
					//--- DRK > If moment of inertia is already defined, then this method will just set the mass and early out.
					//---		If inertia is undefined, then it will calculate that if needed, i.e. if new mass is greater than zero.
					recalculateMassProperties(transform_nullable, propertyMap, false);
				}
			}
			
			setContactReporting(propertyMap, changeFlags);
			setBox2dBooleanProperties(propertyMap, changeFlags);
			setBox2dNumericProperties(propertyMap, changeFlags);
			
			result_out.set(qb2E_BackEndResult.SUCCESS);
		}
		
		private function tryToSetExplicitLocalCenterOfMass(propertyMap:qb2PropMap, changeFlags_nullable:qb2PropFlags, valueSet_out:qb2PropValueSet):Boolean
		{
			queueForMassReset();
			
			qb2PU_PhysicsProp.getCoordinate(propertyMap, changeFlags_nullable, qb2S_PhysicsProps.CENTER_OF_MASS, valueSet_out);
			var hasAllComponentsDefined:Boolean = true;
			var i:int;
			for ( i = 0; i < 2; i++ )
			{
				var value:* = valueSet_out.getValue(i);
				
				if ( !qb2U_Type.isNumeric(value) )
				{
					hasAllComponentsDefined = false;
				}
			}
			
			if ( hasAllComponentsDefined )
			{
				//--- DRK > Easy case...kinda hacky, but we scale the moment of inertia up to pixel-space,
				//---		because the transformMassData method scales it back down to meter space.
				var pixelsPerMeter:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.PIXELS_PER_METER);
				qb2PU_PhysicsProp.copyValueSetToCoordinate(valueSet_out, m_massData.centerOfMass);
				m_massData.momentOfInertia *= (pixelsPerMeter * pixelsPerMeter);
				
				return true;
			}
			
			return false;
		}
		
		private function adjustLocalCenterOfMassIfNeeded(propertyMap:qb2PropMap, valueSet:qb2PropValueSet):void
		{
			for ( var i:int = 0; i < 2; i++ )
			{
				var value:* = valueSet.getValue(i);
			
				if ( qb2U_Type.isNumeric(value) )
				{
					m_massData.centerOfMass.setComponent(i, value as Number);
				}
			}
		}
		
		private function handleCenterOfMassChange(propertyMap:qb2PropMap, changeFlags:qb2PropFlags, transform_nullable:qb2AffineMatrix, result_out:qb2BackEndResult):void
		{
			var isCenterOfMassChanged:Boolean = qb2PU_PhysicsProp.isCoordinatePropertySet(changeFlags, qb2S_PhysicsProps.CENTER_OF_MASS, false);
				
			if ( !isCenterOfMassChanged )  return;
			
			if ( getWorldRepresentation().isLocked() )
			{
				result_out.set(qb2E_BackEndResult.TRY_AGAIN_LATER);
				
				return;
			}
			
			if( !tryToSetExplicitLocalCenterOfMass(propertyMap, changeFlags, s_utilValueSet) )
			{
				//--- DRK > Here, we may don't really have to recalculate moment of intertia, but we do anyway
				//---		because it's pretty much just as fast as recalculating center of mass alone, and
				//---		and simplifies logic that is already too complex...
				m_massData.momentOfInertia = INERTIA_UNDEFINED;
				recalculateMassProperties(transform_nullable, propertyMap, true);
				adjustLocalCenterOfMassIfNeeded(propertyMap, s_utilValueSet);
			}
			
			transformLocalMassPropertiesToRigidRoot(transform_nullable, propertyMap);

			return;
		}
		
		private function recalculateMassProperties(transform_nullable:qb2AffineMatrix, propertyMap:qb2PropMap, recalculateCenterOfMass:Boolean):void
		{
			m_massData.mass = propertyMap.getProperty(qb2S_PhysicsProps.MASS);
			
			if ( m_massData.momentOfInertia /*is already*/ >= 0 )  return;
			
			if ( m_massData.mass <= 0 )  return;
			
			var geometry:qb2A_GeoEntity = propertyMap.getProperty(qb2S_PhysicsProps.GEOMETRY);
			
			if ( geometry == null || m_massData.mass == 0 )
			{
				m_massData.momentOfInertia = 0;
				
				return;
			}
			
			s_utilPoint1.zeroOut();
			if ( transform_nullable != null )
			{
				s_utilPoint1.transformBy(transform_nullable);
			}
			
			if ( qb2U_Type.isKindOf(geometry, qb2GeoPoint) )
			{
				//--- DRK > A point radius of zero here won't have created any box2d fixtures, but can still affect the mass properties.
				var geometryAsPoint:qb2GeoPoint = geometry as qb2GeoPoint;
				var pointRadius:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.POINT_RADIUS);
				m_massData.momentOfInertia = qb2U_MomentOfInertia.circularDisk(NORMALIZED_MASS, pointRadius);
				m_massData.momentOfInertia = qb2U_MassFormula.parallelAxisTheorem(m_massData.momentOfInertia, m_massData.mass, s_utilPoint1.calcDistanceSquaredTo(geometryAsPoint));
				
				if ( recalculateCenterOfMass )
				{
					m_massData.centerOfMass.copy(geometryAsPoint);
				}
			}
			else
			{
				m_massData.momentOfInertia = geometry.calcMomentOfInertia(NORMALIZED_MASS, s_utilPoint1, recalculateCenterOfMass ? m_massData.centerOfMass : null);
			}
		}
		
		private function transformLocalMassPropertiesToRigidRoot(transform_nullable:qb2AffineMatrix, propertyMap:qb2PropMap):void
		{
			if ( m_massData.momentOfInertia > 0 )
			{
				if ( transform_nullable != null )
				{
					m_massData.centerOfMass.transformBy(transform_nullable);
				}
				
				var pixelsPerMeter:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.PIXELS_PER_METER);
				m_massData.centerOfMass.scaleByNumber(1 / pixelsPerMeter);
				m_massData.momentOfInertia /= (pixelsPerMeter * pixelsPerMeter);
			}
		}
		
		public override function setContactFilter(filter_copied_nullable:qb2ContactFilter):void
		{
			for ( var i:int = 0; i < m_box2dFixtures.length; i++ )
			{
				var fixture:b2Fixture = m_box2dFixtures[i];
				
				if ( filter_copied_nullable == null )
				{
					s_utilFilter.categoryBits = 0x1;
					s_utilFilter.groupIndex = 0;
					s_utilFilter.maskBits = 0xFFFFFFFF;
				}
				else
				{
					s_utilFilter.categoryBits = filter_copied_nullable.getCategoryFlags();
					s_utilFilter.groupIndex = filter_copied_nullable.getGroupIndex();
					s_utilFilter.maskBits = filter_copied_nullable.getMaskFlags();
				}
				
				fixture.SetFilterData(s_utilFilter, true);
			}
		}
		
		public function getShape():qb2Shape
		{
			return getPhysicsObject() as qb2Shape;
		}
		
		public override function hasBox2dObject():Boolean
		{
			return m_box2dFixtures.length > 0 || super.hasBox2dObject();
		}
		
		public function getCenterOfMass():qb2GeoPoint
		{
			return m_massData.centerOfMass;
		}
		
		public function getMomentOfInertia():Number
		{
			return m_massData.momentOfInertia;
		}
	}
}