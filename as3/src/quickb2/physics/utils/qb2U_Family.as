package quickb2.physics.utils 
{
	import flash.utils.Dictionary;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.physics.core.iterators.qb2AncestorIterator;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.utils.qb2U_String;
	
	import quickb2.physics.core.iterators.qb2ChildIterator;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2Body;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.lang.*
	
	
	/**
	 * A collection of utilities for modifying and querying a tree of physics objects.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2U_Family extends qb2UtilityClass
	{
		private static const s_treeIterator:qb2TreeIterator = new qb2TreeIterator();
		private static const s_ancestorIterator:qb2AncestorIterator = new qb2AncestorIterator();
		private static const s_childIterator:qb2ChildIterator = new qb2ChildIterator();
		
		public static function dismantleTree(root:qb2A_PhysicsObjectContainer):void
		{
			var child:qb2A_PhysicsObject = root.getFirstChild();
			
			while ( child != null )
			{
				var nextChild:qb2A_PhysicsObject = child.getNextSibling();
				
				if ( qb2U_Type.isKindOf(child, qb2A_PhysicsObjectContainer) )
				{
					dismantleTree(child as qb2A_PhysicsObjectContainer);
				}
				else
				{
					child.removeFromParent();
				}
				
				child = nextChild;
			}
			
			if ( root.getParent() != null )
			{
				root.removeFromParent();
			}
		}
		
		/**
		 * Gets the first common ancestor of this and another object, if any.
		 * If the two objects are in the same world, at the very least this function will return the world.
		 */
		public static function findCommonAncestor(objectA:qb2A_PhysicsObject, objectB:qb2A_PhysicsObject):qb2A_PhysicsObjectContainer
		{
			setAncestorPair(objectA, objectB);
			
			var currentLocalObject:qb2A_PhysicsObject = setAncestorPair_local;
			
			setAncestorPair_local = null;
			setAncestorPair_other = null;
			
			return currentLocalObject.getParent();
		}
		
		public static function explodeContainer(container:qb2A_PhysicsObjectContainer, preserveVelocities:Boolean = true, addToParent:Boolean = true):Vector.<qb2A_PhysicsObject>
		{
			/*var explodes:Vector.<qb2A_PhysicsObject> = new Vector.<qb2A_PhysicsObject>();
			
			var iterator:qb2ChildIterator = qb2ChildIterator.getInstance(container);
			
			if ( container as qb2Body )
			{
				var parentBody:qb2Body = container as qb2Body;
				
				for (var explodesI:qb2A_PhysicsObject; explodesI = iterator.next(); )
				{
					if ( explodesI is qb2I_RigidObject )
					{
						var rigid:qb2I_RigidObject = explodesI as qb2I_RigidObject;
						
						if ( preserveVelocities && !container.getAncestorBody() != null )
						{
							qb2U_Kinematics.calcLinearVelocityAtLocalPoint(parentBody, rigid.getPosition(), rigid.getLinearVelocity());
						}
						else
						{
							rigid.getLinearVelocity().zeroOut();
							rigid.setAngularVelocity(0);
						}
						
						rigid.getPosition().add(parentBody.getPosition());
						qb2U_Geom.rotate(rigid, parentBody.getRotation(), parentBody.getPosition());
						
					}
					else if( explodesI is qb2Group )
					{
						var group:qb2Group = explodesI as qb2Group;
						qb2U_Geom.translate(group, parentBody.getPosition().convertTo(qb2GeoVector) as qb2GeoVector);
						qb2U_Geom.rotate(group, parentBody.getRotation(), parentBody.getPosition());
						
						if ( preserveVelocities && !container.getAncestorBody() != null )
						{
							// do get vel at thing and set velocity of whole group
						}
						else
						{
							qb2U_Kinematics.setAvgLinearVelocity(group, new qb2GeoVector());
							qb2U_Kinematics.setAvgAngularVelocity(group, 0);
						}
					}
					
					parentBody.removeChild(explodesI);
					explodes.push(explodesI);
					
					if ( container.m_parent )
					{
						if( addToParent )  container.m_parent.addChild(explodesI);
					}
				}
			}
			else if ( (container is qb2Group) && !preserveVelocities && !container.m_ancestorBody ) // have to cancel out velocities
			{
				for (explodesI; explodesI = iterator.next(); )
				{
					if ( explodesI is qb2I_RigidObject )
					{
						(explodesI as qb2I_RigidObject).getLinearVelocity().set(0, 0);
						(explodesI as qb2I_RigidObject).setAngularVelocity(0);
					}
					else if ( explodesI is qb2Group )
					{
						qb2U_Physics.setAvgLinearVelocity((explodesI as qb2Group), new qb2GeoVector());
						qb2U_Physics.setAvgAngularVelocity((explodesI as qb2Group), 0);
					}
				
					container.removeChild(explodesI);
					explodes.push(explodesI);
					
					if ( container.getParent() != null )
					{
						if( addToParent )  container.getParent().addChild(explodesI);
					}
				}
			}
			
			if ( container.getParent() != null )
			{
				container.getParent().removeChild(container);
			}
			
			return explodes;*/
			
			return null;
		}
		
		/**
		 * Returns the first ancestor of this object that is of a certain class.
		 */
		public static function findAncestorOfType(thisObject:qb2A_PhysicsObject, T:Class):qb2A_PhysicsObjectContainer
		{
			var object:qb2A_PhysicsObjectContainer = thisObject.getParent();
			
			while ( object != null )
			{
				if ( object as T )  return object;
				
				object = object.getParent();
			}
			
			return null;
		}
		
		public static function findObjectById(container:qb2A_PhysicsObjectContainer, id:String):qb2A_PhysicsObject
		{
			if ( id == null )  return null;
			
			s_treeIterator.initialize(container as qb2A_PhysicsObjectContainer);
			for ( var object:qb2A_PhysicsObject = null; (object = s_treeIterator.next()) != null; )
			{
				if ( qb2U_String.areEqual(id, object.getId()) )
				{
					return object;
				}
			}
			
			return null;
		}
		
		public static function findDescendantOfType(thisObject:qb2A_PhysicsObjectContainer, T:Class):qb2A_PhysicsObject
		{
			s_treeIterator.initialize(thisObject as qb2A_PhysicsObjectContainer, T);
			for ( var object:qb2A_PhysicsObject = null; object = s_treeIterator.next(); )
			{
				return object;
			}
			
			return null;
		}
		
		public static function findDescendantShape(container:qb2A_PhysicsObjectContainer, T__extends__qb2A_GeoEntity:Class):qb2Shape
		{
			s_treeIterator.initialize(container, qb2Shape);
			for ( var object:qb2Shape; object = s_treeIterator.next(); )
			{
				//TODO: Pass geometry down along the tree traversal.
				var geometry:qb2A_GeoEntity = object.getEffectiveProp(qb2S_PhysicsProps.GEOMETRY);
				if ( qb2U_Type.isKindOf(geometry, T__extends__qb2A_GeoEntity) )
				{
					return object;
				}
			}
			
			return null;
		}
		
		public static function findChildShape(thisObject:qb2A_PhysicsObjectContainer, T__extends__qb2A_GeoEntity:Class):qb2Shape
		{
			s_childIterator.initialize(thisObject as qb2A_PhysicsObjectContainer, qb2Shape);
			for ( var object:qb2Shape; object = s_childIterator.next(); )
			{
				var geometry:qb2A_GeoEntity = object.getEffectiveProp(qb2S_PhysicsProps.GEOMETRY);
				if ( qb2U_Type.isKindOf(geometry, T__extends__qb2A_GeoEntity) )
				{
					return object;
				}
			}
			
			return null;
		}
		
		public static function findChildOfType(thisObject:qb2A_PhysicsObjectContainer, T__extends__qb2A_PhysicsObject:Class):qb2A_PhysicsObject
		{
			s_childIterator.initialize(thisObject as qb2A_PhysicsObjectContainer, T__extends__qb2A_PhysicsObject);
			for ( var object:qb2A_PhysicsObject; object = s_childIterator.next(); )
			{
				return object;
			}
			
			return null;
		}
		
		/**
		 * Determines if this object is a descendant of the given ancestor.
		 */
		public static function isDescendantOf(thisObject:qb2A_PhysicsObject, possibleAncestor:qb2A_PhysicsObjectContainer):Boolean
		{
			var object:qb2A_PhysicsObjectContainer = thisObject.getParent();
			while ( object )
			{
				if ( object == possibleAncestor )  return true;
				
				object = object.getParent();
			}
			return false;
		}
		
		public static function isAncestorOf(thisContainer:qb2A_PhysicsObjectContainer, possibleDescendant:qb2A_PhysicsObject):Boolean
		{
			return isDescendantOf(possibleDescendant, thisContainer);
		}
		
		public static function isBelow(thisObject:qb2A_PhysicsObject, otherObject:qb2A_PhysicsObject):Boolean
		{
			return !isAbove(thisObject, otherObject);
		}
		
		/// Determines if this object is "above" otherObject.  If it returns true, it means for example
		/// that this object will be drawn on top of otherObject for debug drawing.
		public static function isAbove(thisObject:qb2A_PhysicsObject, otherObject:qb2A_PhysicsObject):Boolean
		{
			setAncestorPair(thisObject, otherObject);
			
			var currentLocalObject:qb2A_PhysicsObject = setAncestorPair_local;
			var currentOtherObject:qb2A_PhysicsObject = setAncestorPair_other;
			
			setAncestorPair_local = null;
			setAncestorPair_other = null;
			
			var common:qb2A_PhysicsObjectContainer = currentLocalObject.getParent();
			
			if ( !common )
			{
				qb2U_Error.throwError(new Error("No common ancestor"));
			}
			
			var currObject:qb2A_PhysicsObject = common.getFirstChild();
			while ( currObject != null )
			{
				if ( currObject == currentLocalObject )
				{
					return false;
				}
				else if ( currObject == currentOtherObject )
				{
					return true;
				}
			}
			
			return false;
		}
		
		//--- These three members act in place of "passing by reference".
		private static function setAncestorPair(local:qb2A_PhysicsObject, other:qb2A_PhysicsObject, useLastParents:Boolean = false):void
		{
			if ( local.getParent() != other.getParent() )
			{
				var localParentPath:Dictionary = new Dictionary(true);
				
				if ( !useLastParents )
				{
					while ( local.getParent() )
					{
						localParentPath[local.getParent()] = local;
						local = local.getParent();
					}
					
					while ( other.getParent() )
					{
						if ( localParentPath[other.getParent()] )
						{
							local = localParentPath[other.getParent()];
							break;
						}
						
						other = other.getParent();
					}
				}
				else
				{
					while ( local.getParent() )
					{
						localParentPath[local.getParent()] = local;
						local = local.getParent();
					}
					
					while ( other.getParent() )
					{
						if ( localParentPath[other.getParent()] )
						{
							local = localParentPath[other.getParent()];
							break;
						}
						
						other = other.getParent();
					}
				}
			}
			
			setAncestorPair_local = local;
			setAncestorPair_other = other;
		}
		
		private static var setAncestorPair_local:qb2A_PhysicsObject = null;
		private static var setAncestorPair_other:qb2A_PhysicsObject = null;
	}
}