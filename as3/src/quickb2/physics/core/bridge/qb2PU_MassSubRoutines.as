package quickb2.physics.core.bridge 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.surfaces.qb2A_GeoSurface;
	import quickb2.math.qb2U_Formula;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.prop.qb2PU_PhysicsProp;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2E_LengthUnit;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2PU_TangBackDoor;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.utils.qb2U_Geom;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	
	/**
	 * ...
	 * @author
	 */
	public class qb2PU_MassSubRoutines extends qb2UtilityClass
	{		
		public static function handleMassChange(eventQueue:qb2P_EventQueue, object:qb2A_PhysicsObject, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector, parentCollector_nullable:qb2P_FlushCollector):void
		{
			var asTangible:qb2A_TangibleObject = object as qb2A_TangibleObject;
			
			if ( asTangible == null )  return;
			
			if ( node_nullable != null )
			{
				if ( !handleUpwardsMassChange(eventQueue, asTangible, node_nullable, collector, parentCollector_nullable) )
				{
					handleDownwardsMassChange(eventQueue, asTangible, node_nullable, collector, parentCollector_nullable);
				}
			}
			else
			{
				handleDownwardsMassChange(eventQueue, asTangible, node_nullable, collector, parentCollector_nullable);
			}
		}
		
		private static function correctAncestorSurfaceAreas(root:qb2A_TangibleObject, tang:qb2A_TangibleObject, delta:Number):void
		{
			while ( tang != null && tang != root.getParent() )
			{
				qb2PU_TangBackDoor.incSurfaceArea(tang, delta);
				
				tang = tang.getParent();
			}
		}
		
		private static function updateSurfaceAreas(root:qb2A_TangibleObject, tang:qb2A_TangibleObject, baseSurfaceArea:Number):void
		{
			//TODO: If current tang has different geometry, and that geometry is changed (check for node), then calculate new baseSurfaceArea and continue chaining down.
			if ( root != tang )
			{
				var node:qb2P_FlushNode = qb2P_Flusher.getInstance().getFlushTree().getNode(tang);
				
				if ( node.getChangedProperties().isBitSet(qb2S_PhysicsProps.GEOMETRY) )
				{
					qb2_assert(false);
				}
				
				if( tang.getSelfComputedProp(qb2S_PhysicsProps.GEOMETRY) != null)  return;
			}
				
			if ( qb2U_Type.isKindOf(tang, qb2A_PhysicsObjectContainer) )
			{
				var asContainer:qb2A_PhysicsObjectContainer = tang as qb2A_PhysicsObjectContainer;
				
				var child:qb2A_PhysicsObject = asContainer.getFirstChild();
				while ( child != null )
				{
					var childAsTang:qb2A_TangibleObject = child as qb2A_TangibleObject;
					if ( childAsTang != null )
					{
						updateSurfaceAreas(root, childAsTang, baseSurfaceArea);
					}
					child = child.getNextSibling();
				}
			}
			else if ( qb2U_Type.isKindOf(tang, qb2Shape) )
			{
				var oldSurfaceArea:Number = tang.getSurfaceArea();
				var delta:Number = baseSurfaceArea - oldSurfaceArea;
				correctAncestorSurfaceAreas(root, tang, delta); //TODO: Do mass change from density*newSurfaceArea at the same time.
			}
		}
		
		private static function handleDownwardsMassChange(eventQueue:qb2P_EventQueue, asTangible:qb2A_TangibleObject, node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector, parentCollector:qb2P_FlushCollector):void
		{
			var densityLengthUnit:qb2E_LengthUnit	= collector.propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.DENSITY_LENGTH_UNIT);
			var changedProps:qb2PropFlags			= collector.getChangedProps();
			var isDensityUnitChanged:Boolean 		= changedProps.isBitSet(qb2S_PhysicsProps.DENSITY_LENGTH_UNIT);
			var isDensityChanged:Boolean			= changedProps.isBitSet(qb2S_PhysicsProps.DENSITY);
			var isMassChanged:Boolean				= changedProps.isBitSet(qb2S_PhysicsProps.MASS);
			var isGeometryChanged:Boolean			= changedProps.isBitSet(qb2S_PhysicsProps.GEOMETRY);
			var isCenterOfMassChanged:Boolean 		= qb2PU_PhysicsProp.isCoordinatePropertySet(changedProps, qb2S_PhysicsProps.CENTER_OF_MASS, true);
			var isPixelsPerMeterChanged:Boolean 	= changedProps.isBitSet(qb2S_PhysicsProps.PIXELS_PER_METER) && densityLengthUnit == qb2E_LengthUnit.METERS;
	
			if ( !isDensityChanged && !isMassChanged && !isGeometryChanged && !isCenterOfMassChanged && !isDensityUnitChanged && !isPixelsPerMeterChanged)  return;
			
			var asShape:qb2Shape = asTangible as qb2Shape;
			var massDelta:Number = 0.0;
			var surfaceArea:Number = asTangible.getSurfaceArea();
			var inheritedDensity:Number = collector.propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.DENSITY);
			
			if ( isMassChanged )
			{
				var computedMass:Number = collector.propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.MASS);
				var ratio:Number = collector.baseSurfaceArea > 0.0 ? surfaceArea / collector.baseSurfaceArea : 0.0;
				massDelta += ratio * collector.baseMassDelta;
			}
			
			if ( (isGeometryChanged && asShape != null) || isDensityChanged || isDensityUnitChanged || isPixelsPerMeterChanged)
			{
				var currentEffectiveMass:Number = asTangible.getEffectiveProp(qb2S_PhysicsProps.MASS);
				var newPixelBasedMass:Number = inheritedDensity * surfaceArea;
				
				if ( densityLengthUnit == qb2E_LengthUnit.METERS )  newPixelBasedMass /= (collector.m_pixelsPerMeter * collector.m_pixelsPerMeter);
				
				var densityBasedMassDelta:Number = newPixelBasedMass - currentEffectiveMass;
				
				massDelta += densityBasedMassDelta;
				
				correctAncestorMassProperties(asTangible.getParent(), densityBasedMassDelta, 0.0);
			}
			
			qb2PU_TangBackDoor.incEffectiveMass(asTangible, massDelta);
			
			eventQueue.pushMassEvent(asTangible, null);
		}
		
		private static function correctAncestorMassProperties(tang:qb2A_TangibleObject, massDelta:Number, surfaceAreaDelta:Number):void
		{
			while ( tang != null )
			{
				qb2PU_TangBackDoor.incEffectiveMass(tang, massDelta);
				qb2PU_TangBackDoor.incSurfaceArea(tang, surfaceAreaDelta);
				
				tang = tang.getParent();
			}
		}
		
		private static function handleUpwardsMassChange(eventQueue:qb2P_EventQueue, asTangible:qb2A_TangibleObject, node:qb2P_FlushNode, collector:qb2P_FlushCollector, parentCollector_nullable:qb2P_FlushCollector):Boolean
		{
			var densityLengthUnit:qb2E_LengthUnit	= collector.propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.DENSITY_LENGTH_UNIT);
			var changedProps:qb2PropFlags			= node.getChangedProperties();
			var isDensityUnitChanged:Boolean 		= changedProps.isBitSet(qb2S_PhysicsProps.DENSITY_LENGTH_UNIT);
			var isDensityChanged:Boolean			= changedProps.isBitSet(qb2S_PhysicsProps.DENSITY);
			var isMassChanged:Boolean				= changedProps.isBitSet(qb2S_PhysicsProps.MASS);
			var isTransformChanged:Boolean			= node.hasDirtyFlag(qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED);
			var isCenterOfMassChanged:Boolean 		= qb2PU_PhysicsProp.isCoordinatePropertySet(changedProps, qb2S_PhysicsProps.CENTER_OF_MASS, true);
			var isPixelsPerMeterChanged:Boolean 	= changedProps.isBitSet(qb2S_PhysicsProps.PIXELS_PER_METER) && densityLengthUnit == qb2E_LengthUnit.METERS;
			var isGeometryChanged:Boolean			= changedProps.isBitSet(qb2S_PhysicsProps.GEOMETRY);
	
			if ( !isDensityChanged && !isMassChanged && !isTransformChanged && !isGeometryChanged && !isCenterOfMassChanged && !isDensityUnitChanged && !isPixelsPerMeterChanged)  return false;
			
			if ( isTransformChanged )
			{
				qb2_assert(asTangible.getAncestorBody() != null);
			}
			
			var currentEffectiveMass:Number = asTangible.getEffectiveProp(qb2S_PhysicsProps.MASS);
			var currentEffectiveSurfaceArea:Number = asTangible.getSurfaceArea();
			var newSurfaceArea:Number = currentEffectiveSurfaceArea;
			
			var computedMass:* = asTangible.getSelfComputedProp(qb2S_PhysicsProps.MASS);
			var computedMassAsNumber:Number = computedMass != null ? computedMass : 0.0;
			var lagMass:Number = qb2PU_TangBackDoor.getLagMass(asTangible);
			var inheritedDensity:Number = collector.propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.DENSITY);
			
			var asShape:qb2Shape = asTangible as qb2Shape;
			var surfaceAreaDelta:Number = 0.0;
			var massDelta:Number = 0.0;
			var upwardsEventsStartingPoint:qb2A_TangibleObject = asTangible;
			var dispatchUpwardsEvents:Boolean = false;
			
			if ( isGeometryChanged )
			{
				var geometry:qb2A_GeoEntity = collector.propertyMap.getProperty(qb2S_PhysicsProps.GEOMETRY);
				var baseSurfaceArea:Number = qb2U_Geom.calcSurfaceArea(geometry, collector.propertyMap);
				collector.baseSurfaceArea = baseSurfaceArea;
				
				updateSurfaceAreas(asTangible, asTangible, baseSurfaceArea);
				
				newSurfaceArea = asTangible.getSurfaceArea();
				surfaceAreaDelta = newSurfaceArea - currentEffectiveSurfaceArea;
				
				dispatchUpwardsEvents = true;
			}
			
			//--- DRK > If any of these four are true, it will cover the case of the transform and/or center of mass being changed at the same time.
			//---		This is why it's an if/else, and why these are first.  If transform or center of mass case came first, it wouldn't cover
			//---		mass/density/geometry being changed, so we'd have to remove the if/else chain, turn it into an if/if/if chain go up the tree multiple
			//---		times.
			if ( isMassChanged || isDensityChanged || isDensityUnitChanged || isPixelsPerMeterChanged || (isGeometryChanged && asShape != null) )
			{
				if ( isMassChanged )
				{
					var massDeltaFromMassChange:Number = computedMassAsNumber - lagMass;
					collector.baseMassDelta = massDeltaFromMassChange;
					
					if ( newSurfaceArea > 0.0 )
					{
						massDelta += massDeltaFromMassChange;
					}
				}
				
				/*if ( isDensityChanged || isDensityUnitChanged || isPixelsPerMeterChanged)
				{
					var newPixelBasedMass:Number = inheritedDensity * newSurfaceArea;
					if ( densityLengthUnit == qb2E_LengthUnit.METERS )  newPixelBasedMass /= (collector.m_pixelsPerMeter * collector.m_pixelsPerMeter);
					
					massDelta += newPixelBasedMass - currentEffectiveMass;
				}*/
				
				dispatchUpwardsEvents = true;
			}
			else if ( isCenterOfMassChanged && (asTangible.getAncestorBody() != null || qb2U_Type.isKindOf(asTangible, qb2Body)) )
			{
				dispatchUpwardsEvents = true;
			}
			else if ( isTransformChanged )
			{
				upwardsEventsStartingPoint = asTangible.getParent();
				
				dispatchUpwardsEvents = true;
			}
			
			if ( dispatchUpwardsEvents )
			{
				dispatchMassEventsUpwards(eventQueue, asTangible, upwardsEventsStartingPoint, massDelta, surfaceAreaDelta);
			}
			
			return true;
		}
		
		private static function dispatchMassEventsUpwards(eventQueue:qb2P_EventQueue, eventSubject:qb2A_TangibleObject, currentAncestor:qb2A_TangibleObject, massDelta:Number, surfaceAreaDelta:Number):void
		{
			if ( currentAncestor == null )  return;
			
			if ( massDelta != 0.0 )
			{
				qb2PU_TangBackDoor.incEffectiveMass(currentAncestor, massDelta);
			}
			
			if ( surfaceAreaDelta != 0.0 )
			{
				qb2PU_TangBackDoor.incSurfaceArea(currentAncestor, surfaceAreaDelta);
				
				if ( currentAncestor != eventSubject )
				{
					if ( currentAncestor.getSelfComputedProp(qb2S_PhysicsProps.MASS) != null )
					{
						qb2P_Flusher.getInstance().addToMassRebalanceList(currentAncestor);
					}
				}
			}
			
			eventQueue.pushMassEvent(currentAncestor, eventSubject);
			
			//--- DRK > For situations where it's purely a center of mass change (at most), we don't go past a rigid ancestor.
			if ( surfaceAreaDelta == 0.0 && massDelta == 0.0 && currentAncestor.getAncestorBody() == null )  return;
			
			dispatchMassEventsUpwards(eventQueue, eventSubject, currentAncestor.getParent(), massDelta, surfaceAreaDelta);
		}
	}
}