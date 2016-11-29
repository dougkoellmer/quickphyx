/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package quickb2.physics.core.bridge
{
	import quickb2.lang.*;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.operators.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2U_Matrix;
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2P_PhysicsPropMap;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.utils.qb2U_Geom;
	import quickb2.utils.bits.qb2E_BitwiseOp;
	import quickb2.utils.prop.qb2E_PropConcatType;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2MutablePropMap;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	
	import quickb2.physics.core.*;
	import quickb2.physics.core.tangibles.*;
	import quickb2.display.retained.qb2I_ActorContainer;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 * 
	 * @private
	 */
	public class qb2P_FlushCollector extends Object
	{
		private static const s_emptyCollector:qb2P_FlushCollector = new qb2P_FlushCollector();
		private static const s_propertiesNeedingTransforms:qb2P_PropertiesNeedingTransform = new qb2P_PropertiesNeedingTransform();
		
		private static const s_utilTransform1:qb2AffineMatrix = new qb2AffineMatrix();
		private static const s_utilTransform2:qb2AffineMatrix = new qb2AffineMatrix();
		
		
		
		private var m_world:qb2World						= null;
		private var m_dirtyFlags:int						= 0x0;
		
		private const m_changedProperties:qb2MutablePropFlags = new qb2MutablePropFlags();
		
		public const propertyMap:qb2P_PhysicsPropMap = new qb2P_PhysicsPropMap();
		
		public var actorContainer:qb2I_ActorContainer	= null;
		public const transform:qb2AffineMatrix			= new qb2AffineMatrix();
		public var rotationStack:Number					= 0;
		
		public var m_pixelsPerMeter:Number = -1;
		
		public var baseSurfaceArea:Number = 0.0;
		public var baseMassDelta:Number = 0.0;
		
		private var m_autoRelease:Boolean;
		
		private var m_object:qb2A_PhysicsObject;
		
		public function qb2P_FlushCollector()
		{
			clean();
		}
		
		public function getObject():qb2A_PhysicsObject
		{
			return m_object;
		}
		
		public function getWorld():qb2World
		{
			return m_world;
		}
		
		private static function needsRigidTransform(dirtyFlags:int, changedProperties:qb2MutablePropFlags):Boolean
		{
			var mask:int = qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED | qb2PF_DirtyFlag.ADDED_OR_NEEDS_MAKING;
			
			if ( (dirtyFlags & mask) != 0 )
			{
				return true;
			}
			
			if ( changedProperties.isOverlapped(s_propertiesNeedingTransforms) )
			{
				return true;
			}
			
			return false;
		}
		
		private static function needsWorldTransform(dirtyFlags:int):Boolean
		{
			var mask:int = qb2PF_DirtyFlag.WORLD_TRANSFORM_CHANGED | qb2PF_DirtyFlag.ADDED_OR_NEEDS_MAKING;
			
			return (dirtyFlags & mask) != 0;
		}
		
		private function inheritChangedProperties(object:qb2A_PhysicsObject, node_nullable:qb2P_FlushNode, parentCollector:qb2P_FlushCollector, propertyType_nullable:qb2E_PropType):void
		{
			//--- DRK > First we're effectively copying the parent collector's change flags, then doing an AND_NOT to subtract from that the properties that 'objects' owns.
			qb2PU_PhysicsObjectBackDoor.subtractFromInheritedChangeFlags(object, parentCollector.m_changedProperties, this.m_changedProperties, propertyType_nullable);
			
			//--- DRK > The MASS change flag is an exception that bleeds down through the tree no matter what.
			if ( parentCollector.m_changedProperties.isBitSet(qb2S_PhysicsProps.MASS) )
			{
				this.m_changedProperties.setBit(qb2S_PhysicsProps.MASS, true);
			}
			
			//--- DRK > Now we just OR the node's change flags if the node exists.
			if ( node_nullable != null )
			{
				this.m_changedProperties.bitwise(qb2E_BitwiseOp.OR, node_nullable.getChangedProperties(), this.m_changedProperties, propertyType_nullable);
			}
		}
		
		public function initWithRootOrDescendant(node_nullable:qb2P_FlushNode, object:qb2A_PhysicsObject, parentCollector_nullable:qb2P_FlushCollector, isRoot:Boolean):void
		{
			var parentCollectorGuaranteed:qb2P_FlushCollector = parentCollector_nullable != null ? parentCollector_nullable : s_emptyCollector;
			
			this.baseSurfaceArea = parentCollectorGuaranteed.baseSurfaceArea;
			this.baseMassDelta = parentCollectorGuaranteed.baseMassDelta;
			
			m_object = object;
			
			var dirtyFlagsFromNode:int = 0x0;
			
			if ( node_nullable != null )
			{
				dirtyFlagsFromNode = node_nullable.getAggregateDirtyFlags();
			}
			
			var effectiveDirtyFlags:int = parentCollectorGuaranteed.m_dirtyFlags | dirtyFlagsFromNode;
			effectiveDirtyFlags &= ~qb2PF_DirtyFlag.FLAGS_TO_NOT_SEND_DOWN_TREE;
			
			var actorContainer:qb2I_ActorContainer = object.getSelfComputedProp(qb2S_PhysicsProps.ACTOR) as qb2I_ActorContainer;
			if ( actorContainer != null )
			{
				this.actorContainer = actorContainer;
			}
			else
			{
				this.actorContainer = parentCollectorGuaranteed.actorContainer;
			}
			
			var pixelsPerMeter:* = object.getSelfComputedProp(qb2S_PhysicsProps.PIXELS_PER_METER);
			if ( pixelsPerMeter != null )
			{
				this.m_pixelsPerMeter = pixelsPerMeter;
			}
			
			if ( parentCollector_nullable == null )
			{
				this.m_world = object.getWorld();
			}
			else
			{
				this.m_world = parentCollectorGuaranteed.m_world;
			}
			
			if ( isRoot && (dirtyFlagsFromNode & qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER) != 0x0 )
			{
				qb2_assert(parentCollector_nullable != null);
				
				//--- DRK > Here, the parentCollector has populated its m_changedProperties with the all properties that are set in the ancestors
				//---		which will soon cease to be ancestors of 'object'. We'll subtract from these the changed flags that 'object' owns
				//---		in order to figure out which properties 'changed' as a result of remove from the tree.
				qb2PU_PhysicsObjectBackDoor.subtractFromInheritedChangeFlags(object, parentCollectorGuaranteed.m_changedProperties, this.m_changedProperties, /*propertyType=*/null);
				m_changedProperties.setBit(qb2S_PhysicsProps.MASS, false);// if mass is defined in to-be-gone ancestors, we'll hit handle that in a mass rebalance later.
				m_changedProperties.bitwise(qb2E_BitwiseOp.OR, node_nullable.getChangedProperties(), m_changedProperties, /*propertyType=*/null);
			}
			else
			{
				if ( (effectiveDirtyFlags & qb2PF_DirtyFlag.IMPLICITLY_NEEDS_PROPERTIES) != 0x0 )
				{
					qb2PU_PhysicsObjectBackDoor.populatePropertyMapAsDescendant(object, parentCollectorGuaranteed.propertyMap, this.propertyMap, null);
					
					if ( isRoot && (dirtyFlagsFromNode & qb2PF_DirtyFlag.ADDED_TO_CONTAINER) != 0x0 )
					{
						qb2_assert(parentCollector_nullable != null);
						
						qb2PU_PhysicsObjectBackDoor.subtractFromInheritedChangeFlags(object, parentCollectorGuaranteed.propertyMap.getOwnership(), this.m_changedProperties, /*propertyType=*/null);
						m_changedProperties.setBit(qb2S_PhysicsProps.MASS, false);// if mass is defined in newly obtained ancestors, we'll hit handle that in a mass rebalance later.
						m_changedProperties.bitwise(qb2E_BitwiseOp.OR, node_nullable.getChangedProperties(), m_changedProperties, /*propertyType=*/null);
					}
					else
					{
						inheritChangedProperties(object, node_nullable, parentCollectorGuaranteed, null);
					}
				}
				else
				{
					var propertyTypeCount:int = qb2Enum.getCount(qb2E_PropType);
					for ( var i:int = 0; i < propertyTypeCount; i++ )
					{
						var propertyType:qb2E_PropType = qb2Enum.getEnumForOrdinal(qb2E_PropType, i);
						
						if ( (effectiveDirtyFlags & qb2PF_DirtyFlag.DIRTY_PROPERTY_FLAGS[i]) != 0 )
						{
							qb2PU_PhysicsObjectBackDoor.populatePropertyMapAsDescendant(object, parentCollectorGuaranteed.propertyMap, this.propertyMap, propertyType);
							
							inheritChangedProperties(object, node_nullable, parentCollectorGuaranteed, propertyType);
						}
					}
				}
			}
			
			//--- DRK > Calculate the transform for this object's children, if needed.
			//TODO: 	Don't concat transform if number of children is zero.
			var asTangible:qb2A_TangibleObject = object as qb2A_TangibleObject;
			if ( asTangible != null )
			{				
				var asBody:qb2Body = object as qb2Body;
				
				//--- DRK > If this is the top of a rigid hierarchy...
				if ( asBody != null && object.getAncestorBody() == null )
				{
					//this.m_dirtyFlags &= ~(qb2PF_DirtyFlag.WORLD_TRANSFORM_CHANGED | qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED);
				}
				else
				{
					//--- DRK > If this is above the top of a rigid hierarchy...
					if ( object.getAncestorBody() == null )
					{
						if ( needsWorldTransform(effectiveDirtyFlags) )
						{
							if ( object.getParent() != null )
							{
								if ( object.getParent().getParent() == null )
								{
									qb2U_Geom.calcTransform(object.getParent(), this.transform);
								}
								else
								{
									qb2U_Geom.calcTransform(object.getParent(), s_utilTransform1);
									qb2U_Matrix.multiply(parentCollectorGuaranteed.transform, s_utilTransform1, this.transform);
								}
								
								this.rotationStack = parentCollectorGuaranteed.rotationStack + object.getParent().getRotation();
							}
						}
					}
					//--- DRK > If this is below the top of a rigid hierarchy.
					else if ( object.getAncestorBody() != null )
					{
						if( needsRigidTransform(effectiveDirtyFlags, m_changedProperties) )
						{
							var asShape:qb2Shape = object as qb2Shape;
							
							if ( asShape != null )
							{
								if ( object.getAncestorBody() == object.getParent() )
								{
									qb2U_Geom.calcTransform(asShape, this.transform);
								}
								else if ( object.getAncestorBody() == object.getParent().getParent() )
								{
									qb2U_Geom.calcTransform(object.getParent(), s_utilTransform1);
									qb2U_Geom.calcTransform(asShape, s_utilTransform2);
									qb2U_Matrix.multiply(s_utilTransform1, s_utilTransform2, this.transform);
								}
								else
								{
									qb2U_Geom.calcTransform(object.getParent(), s_utilTransform1);
									qb2U_Matrix.multiply(parentCollectorGuaranteed.transform, s_utilTransform1, this.transform);
									qb2U_Geom.calcTransform(asShape, s_utilTransform1);
									this.transform.concat(s_utilTransform1);
								}
							}
							else
							{
								if ( object.getAncestorBody() == object.getParent().getParent() )
								{
									qb2U_Geom.calcTransform(object.getParent(), this.transform);
								}
								else if( object.getParent() != object.getAncestorBody() )
								{
									qb2U_Geom.calcTransform(object.getParent(), s_utilTransform1);
									qb2U_Matrix.multiply(parentCollectorGuaranteed.transform, s_utilTransform1, this.transform);
								}
							}
							
							this.rotationStack = parentCollectorGuaranteed.rotationStack + object.getParent().getRotation();
						}
					}
				}
			}
			
			if ( node_nullable != null )
			{
				this.appendDirtyFlags(node_nullable.getDirtyFlags());
			}
			
			this.appendDirtyFlags(parentCollectorGuaranteed.m_dirtyFlags);
		}
		
		private function appendDirtyFlags(dirtyFlags:int):void
		{
			//--- DRK > This check makes sure that order of operations is respected, so an object can't be flagged for making and then flagged for destroying,
			//---		only the other way around.  The flusher (in combination with back end) should gracefully handle the first case, so this should just be an optimization and additional line of defense.
			//---		An example of the second case is if a joint and one of its attachments is in the world, in the middle of a timestep...then its second attachment is added, which triggers a make on the joint (but doesn't actually make it cause we're in the middle of timestep), then the 
			//---		second attachment is immediately removed, which triggers a destroy on the joint.  The validator will then only attempt a destroy, which will be a no-op because the joint is not made (unless the second object added is an ancestor).
			//---		If we didn't have this check, then the validator would also send a needless "make" to the back end after the no-op destroy, which would return null anyway, but, yea...just early-outting it here.
			//---		NOTE: With new system, I believe node flags should always get cleared, and simply retained on the collector until later if they can't be flushed immediately, so below clearing of flags should just be an artifact of the old system.
			if ( (dirtyFlags & qb2PF_DirtyFlag.NEEDS_REMAKING) == qb2PF_DirtyFlag.NEEDS_DESTROYING )
			{
				m_dirtyFlags &= ~qb2PF_DirtyFlag.NEEDS_MAKING;
			}
			
			m_dirtyFlags |= dirtyFlags;
		}
		
		public function initWithRootAncestors(rootNode:qb2P_FlushNode):void
		{
			var dirtyFlags:int = rootNode.getAggregateDirtyFlags();
			
			if ( dirtyFlags == 0x0 )  return;
			
			var ancestor:qb2A_PhysicsObjectContainer = rootNode.getObject().getParent()
			
			while ( ancestor != null )
			{
				this.collectFromAncestorOfRoot(ancestor, rootNode.getObject(), dirtyFlags);
				
				ancestor = ancestor.getParent();
			}
			
			if ( m_pixelsPerMeter < 0 )
			{
				m_pixelsPerMeter = qb2S_PhysicsProps.PIXELS_PER_METER.getDefaultValue();
			}
		}
		
		private function collectFromAncestorOfRoot(ancestor:qb2A_PhysicsObjectContainer, originalRoot:qb2A_PhysicsObject, dirtyFlags:int):void
		{
			if ( (dirtyFlags & qb2PF_DirtyFlag.REMOVED_FROM_CONTAINER) != 0 )
			{
				qb2PU_PhysicsObjectBackDoor.appendOwnershipFromAncestor(ancestor, this.m_changedProperties);
			}
			else
			{
				if ( (dirtyFlags & qb2PF_DirtyFlag.IMPLICITLY_NEEDS_PROPERTIES) != 0 )
				{
					qb2PU_PhysicsObjectBackDoor.appendPropertiesFromAncestor(ancestor, this.propertyMap, null);
				}
				else
				{
					var propertyTypeCount:int = qb2Enum.getCount(qb2E_PropType);
					for ( var i:int = 0; i < propertyTypeCount; i++ )
					{
						var propertyType:qb2E_PropType = qb2Enum.getEnumForOrdinal(qb2E_PropType, i);
						
						var dirtyPropertyFlag:int = qb2PF_DirtyFlag.DIRTY_PROPERTY_FLAGS[propertyType.getOrdinal()];
				
						if ( (dirtyFlags & dirtyPropertyFlag) != 0 )
						{
							qb2PU_PhysicsObjectBackDoor.appendPropertiesFromAncestor(ancestor, this.propertyMap, propertyType);
						}
					}
				}
			}
		
			if ( ancestor != originalRoot.getParent() )
			{
				if ( originalRoot.getAncestorBody() == null && ancestor.getAncestorBody() == null )
				{
					if ( needsWorldTransform(dirtyFlags) )
					{
						concatAncestorTransform(this.transform, ancestor, originalRoot);
					}
				}
				
				if ( originalRoot.getAncestorBody() != null && ancestor.getAncestorBody() != null )
				{
					if ( needsRigidTransform(dirtyFlags, m_changedProperties) )
					{
						concatAncestorTransform(this.transform, ancestor, originalRoot);
					}
				}
			}
			
			if ( actorContainer == null )
			{
				actorContainer = ancestor.getSelfComputedProp(qb2S_PhysicsProps.ACTOR) as qb2I_ActorContainer;
			}
			
			var pixelsPerMeter:* = ancestor.getSelfComputedProp(qb2S_PhysicsProps.PIXELS_PER_METER);
			
			if ( this.m_pixelsPerMeter < 0 && pixelsPerMeter != null )
			{
				this.m_pixelsPerMeter = pixelsPerMeter;
			}
			
			m_world = ancestor.getWorld();
		}
		
		private function concatAncestorTransform(thisTransform:qb2AffineMatrix, ancestor:qb2A_PhysicsObjectContainer, originalRoot:qb2A_PhysicsObject):void
		{
			if ( ancestor == originalRoot.getParent() )
			{
				return;
			}
			else if ( originalRoot.getParent() != null && originalRoot.getParent().getParent() == ancestor )
			{
				qb2U_Geom.calcTransform(ancestor, this.transform);
				this.rotationStack += ancestor.getRotation();
			}
			else
			{
				qb2U_Geom.calcTransform(ancestor, s_utilTransform1);
				thisTransform.preConcat(s_utilTransform1);
				this.rotationStack += ancestor.getRotation();
			}
		}
		
		public function getChangedProps():qb2PropFlags
		{
			return m_changedProperties;
		}
		
		public function clean():void
		{
			this.m_dirtyFlags = 0x0;
			
			m_changedProperties.clear();
			
			this.m_world = null;
			this.actorContainer = null;
			
			propertyMap.clear();
			
			rotationStack = 0;
			
			m_autoRelease = true;
			
			this.m_pixelsPerMeter = -1;
			
			this.m_object = null;
			
			this.baseSurfaceArea = 0.0;
			this.baseMassDelta = 0.0;
		}
		
		public function shouldRelease():Boolean
		{
			return m_autoRelease;
		}
		
		public function retain():void
		{
			m_autoRelease = false;
		}
		
		public function autoRelease():void
		{
			m_autoRelease = true;
		}
		
		public function areDirtyFlagsCleared():Boolean
		{
			return m_dirtyFlags == 0;
		}
		
		public function clearDirtyFlag(flag:int):void
		{
			m_dirtyFlags &= ~flag;
		}
		
		public function hasDirtyFlag(flag:int):Boolean
		{
			return (m_dirtyFlags & flag) != 0;
		}
		
		public function hasAnyDirtyFlag(flag:int):Boolean
		{
			return (m_dirtyFlags & flag) != 0;
		}
		
		public function appendChangedProperties(changeFlags:qb2PropFlags):void
		{
			m_changedProperties.bitwise(qb2E_BitwiseOp.OR, changeFlags, m_changedProperties);
		}
	}
}