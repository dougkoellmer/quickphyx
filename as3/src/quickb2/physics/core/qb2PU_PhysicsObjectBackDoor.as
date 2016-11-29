package quickb2.physics.core 
{
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.lang.foundation.qb2PrivateUtilityClass;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.primitives.qb2Boolean;
	import quickb2.utils.prop.qb2E_PropConcatType;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.prop.qb2PropMapStack;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2PU_PhysicsObjectBackDoor extends qb2PrivateUtilityClass
	{		
		public static function isBackEndRepresentable(thisArg:qb2A_PhysicsObject):Boolean
		{
			return thisArg.isBackEndRepresentable();
		}
		
		public static function invalidate(thisArg:qb2A_PhysicsObject, flags:int, changeFlags_nullable:qb2MutablePropFlags = null):void
		{
			thisArg.invalidate(flags, changeFlags_nullable);
		}
		
		public static function setNextSibling(thisArg:qb2A_PhysicsObject, sibling:qb2A_PhysicsObject):void
		{
			thisArg.m_nextSibling = sibling;
		}
		
		public static function setPreviousSibling(thisArg:qb2A_PhysicsObject, sibling:qb2A_PhysicsObject):void
		{
			thisArg.m_previousSibling = sibling;
		}
		
		public static function setParent(thisArg:qb2A_PhysicsObject, parent:qb2A_PhysicsObjectContainer):void
		{
			thisArg.m_parent = parent;
		}
		
		public static function getPropertyMap(thisArg:qb2A_PhysicsObject):qb2MutablePropMap
		{
			return thisArg.m_propertyMap;
		}
		
		public static function setProperty(thisArg:qb2A_PhysicsObject, property:qb2PhysicsProp, value:*, invalidate:Boolean):void
		{
			thisArg.setPhysicsProp_internal(property, value, invalidate);
		}
		
		public static function setAncestorBody(thisArg:qb2A_PhysicsObject, body:qb2Body):void
		{
			thisArg.m_ancestorBody = body;
		}
		
		public static function recomputePhysicsProps_relay(thisArg:qb2A_PhysicsObject):void
		{
			thisArg.recomputePhysicsProps_relay();
		}
		
		public static function recomputeStyleProps_relay(thisArg:qb2A_PhysicsObject):void
		{
			thisArg.recomputeStyleProps_relay();
		}
		
		public static function onStepComplete_protected(thisArg:qb2A_PhysicsObject):void
		{
			thisArg.onStepComplete_protected_relay();
		}
		
		public static function onStepComplete_internal(thisArg:qb2A_PhysicsObject):void
		{
			thisArg.onStepComplete_internal();
		}
		
		public static function depthFirst_push(thisArg:qb2A_PhysicsObject, graphics_nullable:qb2I_Graphics2d, stylePropStack:qb2PropMapStack, pushedStyles_out:qb2Boolean):void
		{
			thisArg.depthFirst_push(graphics_nullable, stylePropStack, pushedStyles_out);
		}
		
		public static function depthFirst_pop(thisArg:qb2A_PhysicsObject, stylePropStack:qb2PropMapStack, popStyles:Boolean):void
		{
			thisArg.depthFirst_pop(stylePropStack, popStyles);
		}
		
		public static function setBackEndRepresentation(thisArg:qb2A_SimulatedPhysicsObject, representation:qb2I_BackEndRepresentation):void
		{
			thisArg.setBackEndRepresentation(representation);
		}
		
		public static function onAddedToWorld(thisArg:qb2A_PhysicsObject, world:qb2World, changeFlags_out:qb2MutablePropFlags):void
		{
			thisArg.onAddedToWorld(world, changeFlags_out);
		}
		
		public static function onRemovedFromWorld(thisArg:qb2A_PhysicsObject, changeFlags_out:qb2MutablePropFlags):void
		{
			thisArg.onRemovedFromWorld(changeFlags_out);
		}
		
		public static function spliceFromSiblings(thisArg:qb2A_PhysicsObject):void
		{
			thisArg.spliceFromSiblings();
		}
		
		public static function subtractFromInheritedChangeFlags(thisArg:qb2A_PhysicsObject, changedProperties:qb2PropFlags, flags_out:qb2MutablePropFlags, type_nullable:qb2E_PropType):void
		{
			thisArg.subtractFromInheritedChangeFlags(changedProperties, flags_out, type_nullable);
		}
		
		public static function appendOwnershipFromAncestor(ancestor:qb2A_PhysicsObject, flags_out:qb2MutablePropFlags):void
		{
			ancestor.appendOwnershipAsAncestor(flags_out);
		}
		
		public static function appendPropertiesFromAncestor(ancestor:qb2A_PhysicsObject, map_out:qb2MutablePropMap, type_nullable:qb2E_PropType):void
		{
			ancestor.appendPropertiesAsAncestor(map_out, type_nullable);
		}
		
		public static function populatePropertyMapAsDescendant(mapOwner:qb2A_PhysicsObject, ancestorsMap:qb2PropMap, map_out:qb2MutablePropMap, type_nullable:qb2E_PropType):void
		{
			mapOwner.populatePropertyMapAsDescendant(ancestorsMap, map_out, type_nullable);
		}
		
		public static function getFlushId(thisArg:qb2A_PhysicsObject):int
		{
			return thisArg.getFlushId();
		}
		
		public static function setFlushId(thisArg:qb2A_PhysicsObject, value:int):void
		{
			thisArg.setFlushId(value);
		}
	}
}