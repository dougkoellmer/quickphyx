package quickb2.physics.core.bridge 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.surfaces.qb2A_GeoSurface;
	import quickb2.math.qb2U_Formula;
	import quickb2.physics.core.events.qb2ContainerEvent;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2PU_TangBackDoor;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	
	/**
	 * ...
	 * @author
	 */
	public class qb2PU_ContainerSubRoutines extends qb2UtilityClass
	{
		public static function handleContainerChange(eventQueue:qb2P_EventQueue, object:qb2A_PhysicsObject, node_nullable:qb2P_FlushNode, world:qb2World):void
		{
			if ( node_nullable == null )  return;
		
			if ( node_nullable.hasDirtyFlag(qb2PF_DirtyFlag.ADDED_TO_CONTAINER) )
			{
				onAddedToContainer(eventQueue, object, object.getParent(), world);
				
				node_nullable.clearDirtyFlag(qb2PF_DirtyFlag.ADDED_TO_CONTAINER);
			}
			else if ( node_nullable.hasDirtyFlag(qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER) )
			{
				onRemovedFromContainer(eventQueue, object, object.getParent(), world);
				
				node_nullable.clearDirtyFlag(qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER);
			}
		}
		
		public static function handleWorldChange(eventQueue:qb2P_EventQueue, object:qb2A_PhysicsObject, node_nullable:qb2P_FlushNode, parentCollector_nullable:qb2P_FlushCollector, changeFlags_out:qb2MutablePropFlags):void
		{
			if ( parentCollector_nullable != null && parentCollector_nullable.hasDirtyFlag(qb2PF_DirtyFlag.ADDED_TO_CONTAINER) || node_nullable != null && node_nullable.hasDirtyFlag(qb2PF_DirtyFlag.ADDED_TO_CONTAINER) )
			{
				if ( object.getParent().getWorld() != null )
				{
					qb2_assert(object.getWorld() == null);
					
					qb2PU_PhysicsObjectBackDoor.onAddedToWorld(object, object.getParent().getWorld(), changeFlags_out);
					
					eventQueue.pushContainerEvent(qb2ContainerEvent.ADDED_TO_WORLD, object, object, object.getWorld());
				}
			}
			else if ( parentCollector_nullable != null && parentCollector_nullable.hasDirtyFlag(qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER) || node_nullable != null && node_nullable.hasDirtyFlag(qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER) )
			{
				if ( object.getWorld() != null )
				{
					eventQueue.pushContainerEvent(qb2ContainerEvent.REMOVED_FROM_WORLD, object, object, object.getWorld());
					
					qb2PU_PhysicsObjectBackDoor.onRemovedFromWorld(object, changeFlags_out);
				}
			}
		}
		
		private static function onAddedToContainer(eventQueue:qb2P_EventQueue, dirtyObject:qb2A_PhysicsObject, currentAncestor:qb2A_PhysicsObjectContainer, world:qb2World):void
		{
			if ( currentAncestor == null )  return;
			
			var dirtyObjectAsTang:qb2A_TangibleObject = dirtyObject as qb2A_TangibleObject;
			
			//--- Do implicit mass-change processing.
			//--- DRK > NOTE: Moving this to mass subroutines until I can perhaps do an optimization pass.
			/*if ( dirtyObjectAsTang != null  )
			{
				qb2PU_TangBackDoor.incEffectiveMass(ancestor, dirtyObjectAsTang.getEffectiveProp(qb2S_PhysicsProps.MASS));
				qb2PU_TangBackDoor.incSurfaceArea(ancestor, dirtyObjectAsTang.getSurfaceArea());
				
				if ( dirtyObjectAsTang.getSurfaceArea() != 0.0 )
				{
					if ( currentAncestor.getSelfComputedProp(qb2S_PhysicsProps.MASS) != null )
					{
						qb2P_Flusher.getInstance().addToMassRebalanceList(currentAncestor);
					}
				}
				
				eventQueue.pushMassEvent(ancestor, dirtyObjectAsTang);
			}*/
			
			if ( currentAncestor == dirtyObject.getParent() )
			{				
				eventQueue.pushContainerEvent(qb2ContainerEvent.ADDED_TO_CONTAINER,		dirtyObject, dirtyObject, world);
				eventQueue.pushContainerEvent(qb2ContainerEvent.ADDED_OBJECT,			currentAncestor, dirtyObject, world);
			}
			else
			{
				eventQueue.pushContainerEvent(qb2ContainerEvent.DESCENDANT_ADDED_OBJECT, currentAncestor, dirtyObject, world);
			}
			
			onAddedToContainer(eventQueue, dirtyObject, currentAncestor.getParent(), world);
		}
		
		private static function onRemovedFromContainer(eventQueue:qb2P_EventQueue, dirtyObject:qb2A_PhysicsObject, currentAncestor:qb2A_PhysicsObjectContainer, world:qb2World):void
		{
			if ( currentAncestor == null )  return;
			
			var dirtyObjectAsTang:qb2A_TangibleObject = dirtyObject as qb2A_TangibleObject;
			
			//--- Do implicit mass-change processing.
			//--- DRK > NOTE: Moving this to mass subroutines until I can perhaps do an optimization pass.
			/*if ( dirtyObjectAsTang != null )
			{
				qb2PU_TangBackDoor.incEffectiveMass(ancestor, -dirtyObjectAsTang.getEffectiveProp(qb2S_PhysicsProps.MASS));
				qb2PU_TangBackDoor.incSurfaceArea(ancestor, -dirtyObjectAsTang.getSurfaceArea());
				
				if ( dirtyObjectAsTang.getSurfaceArea() != 0.0 )
				{
					if ( currentAncestor.getSelfComputedProp(qb2S_PhysicsProps.MASS) != null )
					{
						qb2P_Flusher.getInstance().addToMassRebalanceList(currentAncestor);
					}
				}
				
				eventQueue.pushMassEvent(ancestor, dirtyObjectAsTang);
			}*/
			
			if ( currentAncestor == dirtyObject.getParent() )
			{
				eventQueue.pushContainerEvent(qb2ContainerEvent.REMOVED_FROM_CONTAINER, dirtyObject, dirtyObject, world);
				eventQueue.pushContainerEvent(qb2ContainerEvent.REMOVED_OBJECT, currentAncestor, dirtyObject, world);
			}
			else
			{
				eventQueue.pushContainerEvent(qb2ContainerEvent.DESCENDANT_REMOVED_OBJECT, currentAncestor, dirtyObject, world);
			}
			
			onRemovedFromContainer(eventQueue, dirtyObject, currentAncestor.getParent(), world);
		}
	}
}