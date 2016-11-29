package quickb2.physics.core 
{
	import quickb2.display.immediate.graphics.*;
	import quickb2.display.immediate.style.*;
	import quickb2.display.retained.*;
	import quickb2.event.*;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.physics.core.bridge.qb2P_Flusher;
	import quickb2.physics.core.bridge.qb2PF_SimulatedObjectFlag;
	import quickb2.physics.core.iterators.qb2AncestorIterator;
	import quickb2.physics.core.joints.qb2PU_JointBackDoor;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2P_PhysicsPropMap;
	import quickb2.physics.core.prop.qb2PS_PhysicsProp;
	import quickb2.physics.core.prop.qb2PU_PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.utils.bits.qb2E_BitwiseOp;
	import quickb2.utils.primitives.qb2Boolean;
	import quickb2.utils.prop.qb2E_PropConcatType;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2I_UsesPropSheet;
	import quickb2.utils.prop.qb2MutablePropMap;
	import quickb2.utils.prop.qb2Prop;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropFlags;
	import quickb2.utils.prop.qb2PropMapStack;
	import quickb2.utils.prop.qb2PropSheet;
	import quickb2.utils.prop.qb2U_Prop;
	
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	
	import quickb2.lang.operators.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.*;
	import quickb2.physics.core.events.*;
	import quickb2.physics.core.backend.*;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.tangibles.*;
	
	/**
	 * ...
	 * @author
	 */
	public class qb2A_PhysicsObject extends qb2EventDispatcher implements qb2I_UsesPropSheet
	{
		private static const s_utilPropertyMap:qb2MutablePropMap = new qb2MutablePropMap();
		private static const s_utilPropertyFlags1:qb2MutablePropFlags = new qb2MutablePropFlags();
		private static const s_utilPropertyFlags2:qb2MutablePropFlags = new qb2MutablePropFlags();
		private static const s_ancestorIterator:qb2AncestorIterator = new qb2AncestorIterator();
		
		private static const EVENT_TYPE_ARRAY:Vector.<qb2EventType> = Vector.<qb2EventType>
		([
			qb2StepEvent.PRE_STEP,
			qb2StepEvent.POST_STEP,
			new qb2EventMultiType( qb2ContactEvent.CONTACT_STARTED, qb2SubContactEvent.SUB_CONTACT_STARTED ),
			new qb2EventMultiType( qb2ContactEvent.CONTACT_ENDED,   qb2SubContactEvent.SUB_CONTACT_ENDED   ),
			new qb2EventMultiType( qb2ContactEvent.PRE_SOLVE,       qb2SubContactEvent.SUB_PRE_SOLVE       ),
			new qb2EventMultiType( qb2ContactEvent.POST_SOLVE,      qb2SubContactEvent.SUB_POST_SOLVE      )
		]);
		
		private static const PRE_STEP_CASE:int 				= 0;
		private static const POST_STEP_CASE:int 			= 1;
		private static const CONTACT_STARTED_CASE:int 		= 2;
		private static const CONTACT_ENDED_CASE:int 		= 3;
		private static const PRE_SOLVE_CASE:int 			= 4;
		private static const POST_SOLVE_CASE:int 			= 5;
		
		private static const ADD_LISTENER_CASE:int			= 0;
		private static const REMOVE_LISTENER_CASE:int		= 1;
		
		private static const REPORTING_BITS:Vector.<int> = Vector.<int>
		([
			qb2PF_SimulatedObjectFlag.REPORTS_CONTACT_STARTED, qb2PF_SimulatedObjectFlag.REPORTS_CONTACT_ENDED,
			qb2PF_SimulatedObjectFlag.REPORTS_PRE_SOLVE, qb2PF_SimulatedObjectFlag.REPORTS_POST_SOLVE
		]);
		
		internal var m_propertyMap:qb2P_PhysicsPropMap = null;
		private var m_computedPropertyMap:qb2PropMap = null;
		
		private var m_styleMap:qb2MutablePropMap = null;
		private var m_computedStyleMap:qb2PropMap = null;
		
		private var m_flushId:int = 0;
		
		private var m_world:qb2World = null;
		internal var m_previousSibling:qb2A_PhysicsObject = null;
		internal var m_nextSibling:qb2A_PhysicsObject = null;
		internal var m_parent:qb2A_PhysicsObjectContainer = null;
		private var m_actor:qb2I_Actor = null;
		internal var m_ancestorBody:qb2Body = null;
		
		private var m_group:String;
		private var m_id:String;
		
		public function qb2A_PhysicsObject()
		{
			include "../../lang/macros/QB2_ABSTRACT_CLASS";
		}
		
		internal function isBackEndRepresentable():Boolean
		{
			//--- DRK > Not very clean...should let the given subclasses override this method instead,
			//---		but I don't think it's that grevious a hack in this situation. Doing protected override
			//---		would then leak this method down to any user-derived classes.
			return qb2U_Type.isKindOf(this, qb2Shape) || qb2U_Type.isKindOf(this, qb2Joint) && qb2PU_JointBackDoor.isRepresentable(this as qb2Joint)
					|| qb2U_Type.isKindOf(this, qb2Body) && this.getAncestorBody() == null;
		}
		
		protected function copy_protected(source:*):void
		{
			var sourceAsPhysicsObject:qb2A_PhysicsObject = source as qb2A_PhysicsObject;
			
			if ( sourceAsPhysicsObject != null )
			{
				this.setGroup(sourceAsPhysicsObject.m_group);
				this.setId(sourceAsPhysicsObject.m_id);
			}
		}
		
		internal function getFlushId():int
		{
			return m_flushId;
		}
		
		internal function setFlushId(value:int):void
		{
			m_flushId = value;
		}
		
		public function getGroup():String
		{
			return m_group;
		}
		
		public function setGroup(value:String):void
		{
			var oldGroup:String = m_group;
			
			m_group = value;
			
			if ( m_group != oldGroup)
			{
				onGroupOrIdChange();
			}
		}
		
		public function getId():String
		{
			return m_id;
		}
		
		public function setId(value:String):void
		{
			var oldId:String = m_id;
			m_id = value;
			
			if ( m_id != oldId )
			{
				onGroupOrIdChange();
			}
		}
		
		private function onGroupOrIdChange():void
		{
			if ( m_world == null )  return;
			
			recomputeStyleProps();
			recomputePhysicsProps();
		}
		
		internal function recomputeStyleProps_relay():void
		{
			this.recomputeStyleProps();
		}
		
		protected function recomputeStyleProps():void
		{
			this.recomputeStyleProps_private();
		}
		
		internal function recomputePhysicsProps_relay():void
		{
			this.recomputePhysicsProps();
		}
		
		protected function recomputePhysicsProps():void
		{
			this.recomputePhysicsProps_private(s_utilPropertyFlags1);
			
			if ( !s_utilPropertyFlags1.isEmpty() )
			{
				this.invalidate(qb2PF_DirtyFlag.PROPERTY_CHANGED, s_utilPropertyFlags1);
			}
		}
		
		internal function appendOwnershipAsAncestor(flags_out:qb2MutablePropFlags):void
		{
			flags_out.bitwise(qb2E_BitwiseOp.OR, m_propertyMap != null ? m_propertyMap.getOwnership() : null, flags_out);
			flags_out.bitwise(qb2E_BitwiseOp.OR, m_computedPropertyMap != null ? m_computedPropertyMap.getOwnership() : null, flags_out);
		}
		
		internal function appendPropertiesAsAncestor(map_out:qb2MutablePropMap, type_nullable:qb2E_PropType):void
		{
			map_out.concat(m_propertyMap, map_out, qb2E_PropConcatType.X_OR, type_nullable);
			map_out.concat(m_computedPropertyMap, map_out, qb2E_PropConcatType.X_OR, type_nullable);
		}
		
		private static function subtractFromInheritedChangeFlags_private(propertyMap_nullable:qb2PropMap, changedProperties:qb2PropFlags, flags_out:qb2MutablePropFlags, type_nullable:qb2E_PropType):void
		{
			if ( propertyMap_nullable == null )  return;
			
			var ownership:qb2PropFlags = propertyMap_nullable.getOwnership();
			changedProperties.bitwise(qb2E_BitwiseOp.AND_NOT, ownership, flags_out, type_nullable);
		}
		
		internal function subtractFromInheritedChangeFlags(changedProperties:qb2PropFlags, flags_out:qb2MutablePropFlags, type_nullable:qb2E_PropType):void
		{
			subtractFromInheritedChangeFlags_private(m_propertyMap, changedProperties, flags_out, type_nullable);
			subtractFromInheritedChangeFlags_private(m_computedPropertyMap, changedProperties, flags_out, type_nullable);
		}
		
		internal function populatePropertyMapAsDescendant(mapOfParent:qb2PropMap, map_out:qb2MutablePropMap, type_nullable:qb2E_PropType):void
		{
			if ( m_propertyMap == null && m_computedPropertyMap == null )
			{
				map_out.concat(mapOfParent, map_out, qb2E_PropConcatType.OR, type_nullable);
				
				return;
			}
			
			if ( m_computedPropertyMap != null )
			{
				mapOfParent.concat(m_computedPropertyMap, map_out, qb2E_PropConcatType.OR, type_nullable);
			}
			
			if ( m_propertyMap != null )
			{
				mapOfParent.concat(m_propertyMap, map_out, qb2E_PropConcatType.OR, type_nullable);
			}
		}
		
		public final function setProp(prop:*, value:*):void
		{
			var actualProp:qb2Prop = qb2U_Prop.getPropReference(prop);
			
			if ( actualProp != null )
			{
				this.setProp_protected(actualProp, value);
			}
		}
		
		protected function setProp_protected(property:qb2Prop, value:*):void
		{
			if ( property == qb2S_PhysicsProps.ACTOR )
			{
				setActor(value);
				
				// TODO: Send property change event for actor.
			}
			else
			{
				if ( qb2U_Type.isKindOf(property, qb2PhysicsProp) )
				{
					setPhysicsProp_internal(property as qb2PhysicsProp, value, true);
				}
				else if ( qb2U_Type.isKindOf(property, qb2StyleProp) )
				{
					setStyleProp_internal(property as qb2StyleProp, value);
				}
			}
		}
		
		private function setStyleProp_internal(prop:qb2StyleProp, value:*):void
		{
			if ( m_styleMap == null )
			{
				if ( value == null )  return;
				
				m_styleMap = new qb2MutablePropMap();
			}
			
			m_styleMap.setProperty(prop, value);
		}
		
		internal function setPhysicsProp_internal(prop:qb2PhysicsProp, value:*, invalidate:Boolean):void
		{
			if ( m_propertyMap == null )
			{
				if ( value == null )  return;
				
				m_propertyMap = new qb2P_PhysicsPropMap();
			}
			
			//--- DRK > Simple early-out here, obviously not checking for equality on complex objects like points, vectors, etc.
			if ( m_propertyMap.getProperty(prop) == value )  return;
			
			m_propertyMap.setProperty(prop, value);
			
			if ( invalidate )
			{
				s_utilPropertyFlags1.clear();
				s_utilPropertyFlags1.setBit(prop, true);
				
				if ( prop.getType() == qb2E_PropType.BOOLEAN )
				{
					this.invalidate(qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED, s_utilPropertyFlags1);
				}
				else if ( prop.getType() == qb2E_PropType.NUMERIC )
				{
					this.invalidate(qb2PF_DirtyFlag.NUMERIC_PROPERTY_CHANGED, s_utilPropertyFlags1);
				}
				else if ( prop.getType() == qb2E_PropType.OBJECT )
				{
					this.invalidate(qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED, s_utilPropertyFlags1);
				}
			}
		}
		
		public final function getProp(prop:*, value_out_nullable:* = null):*
		{
			var actualProp:qb2Prop = qb2U_Prop.getPropReference(prop);
			
			if ( actualProp != null )
			{
				qb2P_Flusher.getInstance().flush();
				
				return this.getProp_protected(actualProp, value_out_nullable);
			}
		}
		
		protected function getProp_protected(prop:qb2Prop, value_out_nullable:* = null):*
		{
			if ( prop == qb2S_PhysicsProps.ACTOR )
			{
				return m_actor; // TODO: Only return actor instance for getEffectiveProp?
			}
			else
			{
				if ( qb2U_Type.isKindOf(prop, qb2PhysicsProp) )
				{
					if ( m_propertyMap == null )  return null;
					
					return m_propertyMap.getProperty(prop); //transformed by map itself.
				}
				else if ( qb2U_Type.isKindOf(prop, qb2StyleProp) )
				{
					if ( m_styleMap == null )  return null;
					
					return m_styleMap.getProperty(prop);
				}
			}
		}
		
		public final function getSelfComputedProp(prop:*, value_out_nullable:* = null):*
		{
			var actualProp:qb2Prop = qb2U_Prop.getPropReference(prop);
			
			if ( actualProp != null )
			{
				qb2P_Flusher.getInstance().flush();
				
				return this.getSelfComputedProp_protected(actualProp, value_out_nullable);
			}
		}
		
		protected function getSelfComputedProp_protected(prop:qb2Prop, value_out_nullable:* = null):*
		{
			var toReturn:* = this.getProp(prop);
			
			if ( toReturn != null )
			{
				return toReturn; // transformed by getProperty().
			}
			
			if ( m_computedPropertyMap != null )
			{
				toReturn = m_computedPropertyMap.getProperty(prop);
			}
			
			return qb2PU_PhysicsProp.transformValue(prop, toReturn);
		}
		
		public final function getComputedProp(prop:*, value_out_nullable:* = null):*
		{
			var actualProp:qb2Prop = qb2U_Prop.getPropReference(prop);
			
			if ( actualProp != null )
			{
				qb2P_Flusher.getInstance().flush();
				
				return this.getComputedProp_protected(actualProp, value_out_nullable);
			}
		}
		
		protected function getComputedProp_protected(prop:qb2Prop, value_out_nullable:* = null):*
		{
			if ( prop == qb2S_PhysicsProps.ACTOR )
			{
				return m_actor;
			}
			else
			{
				var currentAncestor:qb2A_PhysicsObject = this;
					
				while ( currentAncestor != null )
				{
					var toReturn:* = currentAncestor.getSelfComputedProp(prop);
					
					if ( toReturn != null )
					{
						return toReturn; // transformed by getSelfComputedProp().
					}
					
					currentAncestor = currentAncestor.getParent();
				}
				
				return null;
			}
		}
		
		public final function getEffectiveProp(prop:*, value_out_nullable:* = null):*
		{
			var actualProp:qb2Prop = qb2U_Prop.getPropReference(prop);
			
			if ( actualProp != null )
			{
				qb2P_Flusher.getInstance().flush();
				
				return this.getEffectiveProp_protected(actualProp, value_out_nullable);
			}
		}
		
		protected function getEffectiveProp_protected(prop:qb2Prop, value_out_nullable:* = null):*
		{
			var value:* = this.getComputedProp(prop, value_out_nullable);
			return value != null ? value : prop.getDefaultValue();
		}
		
		private function setActor(actor:*):void
		{
			if ( actor != null && !qb2U_Type.isKindOf(actor, qb2I_Actor) )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.INVALID_TYPE, "Expected a qb2I_Actor.");
			}
			
			var oldActor:qb2I_Actor = this.m_actor;
			m_actor = actor;
			
			if ( m_actor != oldActor )
			{
				if ( oldActor != null )
				{
					var oldActorParent:qb2I_ActorContainer = oldActor.getActorParent();
					
					if ( oldActorParent != null )
					{
						oldActorParent.removeActorChild(oldActor);
					}
				}
				
				this.invalidate(qb2PF_DirtyFlag.ACTOR_CHANGED);
				
				qb2P_Flusher.getInstance().flush();
			}
		}
		
		public function getWorld():qb2World
		{
			return m_world;
		}
		
		public function getParent():qb2A_PhysicsObjectContainer
		{
			return m_parent;
		}
		
		public function getNextSibling():qb2A_PhysicsObject
		{
			return m_nextSibling;
		}
		
		public function getPreviousSibling():qb2A_PhysicsObject
		{
			return m_previousSibling;
		}
		
		public function getAncestorBody():qb2Body
		{
			return m_ancestorBody;
		}
		
		internal function invalidate(flags:int, changedProperties_copied_nullable:qb2PropFlags = null):void
		{
			qb2_assert((flags & ~qb2PF_DirtyFlag.DIRTY_FLAGS) == 0x0 );
			
			qb2P_Flusher.getInstance().addDirtyObject(this, flags, changedProperties_copied_nullable);
		}
		
		public override function addEventListener(type:qb2EventType, listener:Function, reserved:Boolean = false):void
		{
			updateEventBasedThings(ADD_LISTENER_CASE, type, listener, reserved);
		}
		
		public override function removeEventListeners(typeOrListener1_nullable:* = null, typeOrListener2_nullable:* = null):void
		{
			var type:qb2EventType = qb2U_Type.isKindOf(typeOrListener1_nullable, qb2EventType) ? typeOrListener1_nullable : null;
			if ( type == null && qb2U_Type.isKindOf(typeOrListener2_nullable, qb2EventType) )
			{
				type = typeOrListener2_nullable;
			}
			
			var listener:Function = qb2U_Type.isKindOf(typeOrListener1_nullable, Function) ? typeOrListener1_nullable : null;
			if ( listener == null && qb2U_Type.isKindOf(typeOrListener2_nullable, Function) )
			{
				listener = typeOrListener2_nullable;
			}
			
			updateEventBasedThings(REMOVE_LISTENER_CASE, type, listener);
		}
		
		private function updateEventBasedThings(superCase:int, type:qb2EventType, listener:Function, reserved:Boolean = false):void
		{
			//--- See what listeners this object has now, for comparison after super call.
			var hadListenerBits:uint = 0;
			var currBit:uint = 0x01;
			var numTypes:int = EVENT_TYPE_ARRAY.length;
			for (var i:int = 0; i < numTypes; i++) 
			{
				if ( hasEventListener(EVENT_TYPE_ARRAY[i]) )
				{
					hadListenerBits |= currBit;
				}
				
				currBit <<= 1;
			}
			
			//--- Call the super function.
			switch(superCase)
			{
				case ADD_LISTENER_CASE:
				{
					super.addEventListener(type, listener, reserved);
					
					break;
				}
				case REMOVE_LISTENER_CASE:
				{
					super.removeEventListeners(type, listener);
					
					break;
				}
			}
			
			//--- Compare the then and now to see what listeners this object received or lost.
			currBit = 0x01;
			var concernsContactListening:Boolean = false;
			s_utilPropertyFlags1.clear();
			
			for ( i = 0; i < numTypes; i++) 
			{
				var hadListener:Boolean = (currBit & hadListenerBits) != 0;
				var hasListener:Boolean = hasEventListener(EVENT_TYPE_ARRAY[i]);
				var contactProperty:qb2PhysicsProp = null;
				
				if ( hasListener != hadListener )
				{
					switch(i)
					{
						case PRE_STEP_CASE:
						{
							if ( m_world != null )
							{
								if ( superCase == ADD_LISTENER_CASE )
								{
									qb2PU_TangBackDoor.addStepDispatcher(m_world, qb2PU_TangBackDoor.PRE_STEP_DISPATCHER, this);
								}
								else
								{
									qb2PU_TangBackDoor.removeStepDispatcher(m_world, qb2PU_TangBackDoor.PRE_STEP_DISPATCHER, this);
								}
							}
							
							break;
						}
						
						case POST_STEP_CASE:
						{
							if ( m_world != null )
							{
								if ( superCase == ADD_LISTENER_CASE )
								{
									qb2PU_TangBackDoor.addStepDispatcher(m_world, qb2PU_TangBackDoor.POST_STEP_DISPATCHER, this);
								}
								else
								{
									qb2PU_TangBackDoor.removeStepDispatcher(m_world, qb2PU_TangBackDoor.POST_STEP_DISPATCHER, this);
								}
							}
							
							break;
						}
						
						case CONTACT_STARTED_CASE:
						{
							contactProperty = qb2PS_PhysicsProp.REPORTS_CONTACT_STARTED;
							
							break;
						}
						case CONTACT_ENDED_CASE:
						{
							contactProperty = qb2PS_PhysicsProp.REPORTS_CONTACT_ENDED;
							break;
						}
						case PRE_SOLVE_CASE:
						{
							contactProperty = qb2PS_PhysicsProp.REPORTS_PRE_SOLVE;
							break;
						}
						case POST_SOLVE_CASE:
						{
							contactProperty = qb2PS_PhysicsProp.REPORTS_POST_SOLVE;
							break;
						}
					}
					
					if ( contactProperty != null )
					{
						s_utilPropertyFlags1.setBit(contactProperty, true);
						setPhysicsProp_internal(contactProperty, hasListener ? true : null, false);
					}
				}
				
				currBit <<= 1;
			}
			
			if ( concernsContactListening )
			{
				invalidate(qb2PF_DirtyFlag.BOOLEAN_PROPERTY_CHANGED, s_utilPropertyFlags1);
				
				if ( this.m_world != null )
				{
					if ( this.m_world.getTelemetry().isSteppingInBackEnd() )
					{
						qb2P_Flusher.getInstance().flush();
					}
				}
			}
		}
		
		public function removeFromParent():void
		{
			m_parent.removeChild(this);
		}
		
		/**
		 * Override this in subclasses to make class-specific updates immediately after the physics time step.
		 * This function is called after the actual physics time step, but before qb2StepEvent.POST_STEP is dispatched.
		 */
		[qb2_virtual] protected function onStepComplete():void {}
		
		internal function onStepComplete_protected_relay():void
		{
			this.onStepComplete();
		}
		
		[qb2_virtual] internal function onStepComplete_internal():void {}
		
		internal function depthFirst_push(graphics_nullable:qb2I_Graphics2d, stylePropStack:qb2PropMapStack, pushedStyles_out:qb2Boolean):void
		{
			pushedStyles_out.value = false;
			
			if ( graphics_nullable != null )
			{
				if ( this.m_styleMap != null && this.m_computedStyleMap != null )
				{
					m_computedStyleMap.concat(m_styleMap, s_utilPropertyMap, qb2E_PropConcatType.OR);
					stylePropStack.push(s_utilPropertyMap);
					pushedStyles_out.value = true;
				}
				else if ( this.m_styleMap != null )
				{
					stylePropStack.push(this.m_styleMap);
					pushedStyles_out.value = true;
				}
				else if ( this.m_computedStyleMap != null )
				{
					stylePropStack.push(this.m_computedStyleMap);
					pushedStyles_out.value = true;
				}
			}
		}
		
		internal function depthFirst_pop(stylePropStack:qb2PropMapStack, popStyles:Boolean):void
		{
			if ( popStyles )
			{
				stylePropStack.pop();
			}
		}
		
		protected function draw_push(graphics:qb2I_Graphics2d):void
		{
			qb2U_Style.populateGraphics(graphics, this.m_computedPropertyMap);
			qb2U_Style.populateGraphics(graphics, this.m_propertyMap);
		}
		
		protected function draw_pop(graphics:qb2I_Graphics2d):void
		{
			qb2U_Style.depopulateGraphics(graphics, this.m_computedPropertyMap);
			qb2U_Style.depopulateGraphics(graphics, this.m_propertyMap);
		}
				
		internal function onAddedToWorld(world:qb2World, changeFlags_out:qb2MutablePropFlags):void
		{
			qb2_assert(m_world == null );
			
			this.m_world = world;
			
			if ( this.hasEventListener(qb2StepEvent.POST_STEP) )
			{
				qb2PU_TangBackDoor.addStepDispatcher(world, qb2PU_TangBackDoor.POST_STEP_DISPATCHER, this);
			}
			if ( this.hasEventListener(qb2StepEvent.PRE_STEP) )
			{
				qb2PU_TangBackDoor.addStepDispatcher(world, qb2PU_TangBackDoor.PRE_STEP_DISPATCHER, this);
			}
			
			recomputePhysicsProps_private(changeFlags_out);
			recomputeStyleProps_private();
		}
		
		internal function onRemovedFromWorld(changeFlags_out:qb2MutablePropFlags):void
		{
			qb2_assert(m_world != null);
			
			if ( this.hasEventListener(qb2StepEvent.POST_STEP) )
			{
				qb2PU_TangBackDoor.removeStepDispatcher(m_world, qb2PU_TangBackDoor.POST_STEP_DISPATCHER, this);
			}
			if ( this.hasEventListener(qb2StepEvent.PRE_STEP) )
			{
				qb2PU_TangBackDoor.removeStepDispatcher(m_world, qb2PU_TangBackDoor.PRE_STEP_DISPATCHER, this);
			}
			
			m_world = null;
			
			recomputePhysicsProps_private(changeFlags_out);
			recomputeStyleProps_private();
		}
		
		private function computePropertyMap(sheet:qb2PropSheet):qb2PropMap
		{
			qb2_assert(getWorld() != null);
			
			if ( sheet == null )
			{
				return null;
			}
			else
			{
				s_ancestorIterator.initialize(this, null, false);
				
				return sheet.computePropertyMap(s_ancestorIterator);
			}
		}
		
		private function recomputeStyleProps_private():void
		{
			if ( m_world == null )
			{
				m_computedStyleMap = null;
			}
			else
			{
				m_computedStyleMap = this.computePropertyMap(m_world.getStylePropSheet());
			}
		}
		
		private function recomputePhysicsProps_private(changeFlags_out:qb2MutablePropFlags):void
		{
			var propertyMapOwnership:qb2PropFlags = m_propertyMap != null ? m_propertyMap.getOwnership() : null;
			
			if ( this.m_world == null )
			{
				if ( m_computedPropertyMap != null )
				{
					m_computedPropertyMap.getOwnership().bitwise(qb2E_BitwiseOp.AND_NOT, propertyMapOwnership, changeFlags_out);					
					m_computedPropertyMap = null;
				}
				else
				{
					changeFlags_out.clear();
				}
			}
			else
			{
				var newMap:qb2PropMap = this.computePropertyMap(m_world.getPhysicsPropSheet());
				
				if ( m_computedPropertyMap != null )
				{
					m_computedPropertyMap.getOwnership().bitwise(qb2E_BitwiseOp.AND_NOT, propertyMapOwnership, changeFlags_out);
					
					if ( newMap != null )
					{
						newMap.getOwnership().bitwise(qb2E_BitwiseOp.AND_NOT, propertyMapOwnership, s_utilPropertyFlags2);
						changeFlags_out.bitwise(qb2E_BitwiseOp.OR, s_utilPropertyFlags2, changeFlags_out);
					}
				}
				else
				{
					if ( newMap != null )
					{
						newMap.getOwnership().bitwise(qb2E_BitwiseOp.AND_NOT, propertyMapOwnership, changeFlags_out);
					}
					else
					{
						changeFlags_out.clear();
					}
				}
				
				m_computedPropertyMap = newMap;
			}
		}

		[qb2_virtual] public function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void {}
		
		internal function spliceFromSiblings():void
		{
			qb2PU_TangBackDoor.spliceFromSiblings(this.getParent(), this);
			
			var prevSibling:qb2A_PhysicsObject = this.getPreviousSibling();
			var nextSibling:qb2A_PhysicsObject = this.getNextSibling();
			
			// NOTE: world is nulled out inside validateWithAncestors().
			m_previousSibling = null;
			m_nextSibling = null;
			m_parent = null;
			qb2_assert(m_world == null);
			m_world = null;
			
			if ( prevSibling != null )
			{
				if ( nextSibling != null )
				{
					prevSibling.m_nextSibling = nextSibling;
					nextSibling.m_previousSibling = nextSibling;
				}
				else
				{
					prevSibling.m_nextSibling = null;
				}
			}
			
			if ( nextSibling != null )
			{
				if ( prevSibling == null)
				{
					nextSibling.m_previousSibling = null;
				}
			}
		}
		
		public function copy(source:*):void
		{
			this.copy_protected(source);
		}
		
		/**
		 * Returns a new instance that is a clone of this object.  Properties, flags, and their ownerships are copied to the new instance.
		 * Subclasses are responsible for overriding this function and ammending whatever they need to the clone.  The clone is always deep.
		 */
		public function clone():*
		{
			var cloned:qb2A_PhysicsObject = null; // TODO: Implement
			
			if ( m_actor != null )
			{
				cloned.setActor(m_actor.clone());
			}
			
			return cloned;
		}
	}
}