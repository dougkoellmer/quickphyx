package quickb2.physics.core.tangibles 
{
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.retained.qb2I_Actor;
	import quickb2.event.qb2EventMultiType;
	import quickb2.event.qb2EventType;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.utils.primitives.qb2Boolean;
	import quickb2.lang.operators.qb2_assert;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.*;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2MathEvent;
	import quickb2.math.qb2TransformStack;
	import quickb2.math.qb2U_Math;
	import quickb2.math.qb2U_Units;
	import quickb2.physics.core.backend.*;
	import quickb2.physics.core.bridge.qb2P_Flusher;
	import quickb2.physics.core.bridge.qb2P_RigidComponent;
	import quickb2.physics.core.bridge.qb2PU_MassSubRoutines;
	import quickb2.physics.core.prop.qb2PU_PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.utils.qb2U_Tang;
	import quickb2.utils.primitives.qb2Float;
	import quickb2.utils.prop.qb2Prop;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	import quickb2.utils.prop.qb2PropMapStack;
	
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.bridge.qb2PF_SimulatedObjectFlag;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.qb2A_SimulatedPhysicsObject;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.qb2PU_PhysicsObjectBackDoor;
	import quickb2.physics.utils.qb2U_Geom;
	
	/**
	 * ...
	 * @author 
	 */
	[qb2_abstract] public class qb2A_TangibleObject extends qb2A_SimulatedPhysicsObject
	{
		private static const s_utilPropertyFlags2:qb2MutablePropFlags = new qb2MutablePropFlags();
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_matrix:qb2AffineMatrix = new qb2AffineMatrix();
		private static const s_utilBool:qb2Boolean = new qb2Boolean();
		
		private var m_actualMass:Number = 0.0;
		private var m_lagMass:Number = 0.0;
		internal var m_actualSurfaceArea:Number = 0.0;
		
		internal var m_jointList:qb2Joint = null;
		
		private const m_position:qb2GeoPoint = new qb2GeoPoint();
		private var m_rotation:Number = 0;
		
		internal var m_desiredSleepState:Boolean = false;
		
		//TODO: If ever contact "holes" get implemented, such that in the bridged contact listener you can selectively ignore a contact if it goes through a hole,
		//		then it would be best if some caching scheme were in place for performance.
		//private var m_cachedContactFilter:qb2ContactFilter;
		
		public function qb2A_TangibleObject()
		{
			include "../../../lang/macros/QB2_ABSTRACT_CLASS";
			
			init();
		}
		
		private function init():void
		{
			m_position.getEventDispatcher().addEventListener(onPositionChanged);
		}
		
		private function onPositionChanged():void
		{
			onTransformUpdated();
			
			qb2PU_TangBackDoor.dispatchPropChangeEvent(this, qb2S_PhysicsProps.POSITION);
		}
		
		protected override function setProp_protected(prop:qb2Prop, value:*):void
		{
			if ( prop == qb2S_PhysicsProps.POSITION )
			{
				var position:qb2GeoPoint = value;
				
				if ( position != null )
				{
					m_position.copy(position);
				}
			}
			else if ( prop == qb2S_PhysicsProps.ROTATION )
			{
				this.setRotation(value);
			}
			else if ( prop == qb2S_PhysicsProps.GEOMETRY )
			{
				this.setGeometry(value); 
			}
			else if ( prop == qb2S_PhysicsProps.MASS )
			{
				var currentMass:* = this.getSelfComputedProp(qb2S_PhysicsProps.MASS);
				
				m_lagMass = currentMass != null ? currentMass : 0.0;
				
				value = value == 0.0 ? null : value;
				super.setProp_protected(prop, value);
			}
			else if ( prop == qb2S_PhysicsProps.IS_SLEEPING )
			{
				if ( this.getAncestorBody() != null || this.getWorld() == null )  return;
				
				var asBool:Boolean = value as Boolean;
			
				if ( asBool != m_desiredSleepState )
				{
					m_desiredSleepState = asBool;
				}
				
				qb2PU_PhysicsObjectBackDoor.invalidate(this, qb2PF_DirtyFlag.SLEEP_STATE_CHANGED);
				
				//--- DRK > Immediately validating here because this may affect velocites, and we want that immediately reflected.
				qb2P_Flusher.getInstance().flush();
			}
			else if ( prop == qb2S_PhysicsProps.CONTACT_FILTER )
			{
				if ( value != null && !qb2U_Type.isKindOf(value, qb2ContactFilter) )
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected a qb2ContactFilter");
				}
				
				var oldFilter:qb2ContactFilter = this.getProp(qb2S_PhysicsProps.CONTACT_FILTER);
				var newFilter:qb2ContactFilter = value as qb2ContactFilter;
				
				qb2_assert(oldFilter.getOwner() == this);
				
				if ( oldFilter != null )
				{
					oldFilter.onDetached();
				}
				
				if ( newFilter != null && newFilter.getOwner() != null )
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ALREADY_IN_USE, "Filter is already in use by another tangible object.");
				}
				
				if ( newFilter != null )
				{
					newFilter.onAttached(this);
				}
				
				super.setProp_protected(prop, value);
			}
			else
			{
				super.setProp_protected(prop, value);
			}
		}
		
		internal function onContactFilterChanged():void
		{
		}
		
		internal function incActualMass(delta:Number):void
		{
			var massWas:Number = m_actualMass;
			
			m_actualMass += delta;
			correctMass();
			
			if ( massWas == 0.0 && m_actualMass > 0.0 || massWas > 0.0 && m_actualMass == 0.0 )
			{
				this.recomputeStyleProps();
			}
		}
		
		private function correctMass():void
		{
			m_actualMass = m_actualMass < 0.0 ? 0.0 : m_actualMass;
		}
		
		internal function getLagMass():Number
		{
			return m_lagMass;
		}
		
		protected override function getComputedProp_protected(property:qb2Prop, value_out_nullable:* = null):*
		{
			if ( property == qb2S_PhysicsProps.MASS )
			{
				return this.getSelfComputedProp(qb2S_PhysicsProps.MASS, value_out_nullable);
			}
			
			return super.getComputedProp_protected(property, value_out_nullable);
		}
		
		protected override function getProp_protected(property:qb2Prop, value_out_nullable:* = null):*
		{
			if ( property == qb2S_PhysicsProps.POSITION )
			{
				if ( qb2PU_PhysicsProp.copyCoordToValue(m_position, value_out_nullable) )
				{
					return value_out_nullable;
				}
				
				return m_position;
			}
			else if ( property == qb2S_PhysicsProps.ROTATION )
			{
				return m_rotation;
			}
			else if ( property == qb2S_PhysicsProps.IS_SLEEPING )
			{
				return isSleeping();
			}
			else
			{
				return super.getProp_protected(property, value_out_nullable);
			}
		}
		
		private function onGeometryChanged():void
		{
			s_utilPropertyFlags2.clear();
			s_utilPropertyFlags2.setBit(qb2S_PhysicsProps.GEOMETRY, true);
			
			qb2PU_PhysicsObjectBackDoor.invalidate(this, qb2PF_DirtyFlag.OBJECT_PROPERTY_CHANGED, s_utilPropertyFlags2);
		}
		
		private function setGeometry(value:*):void
		{
			var currentGeometry:qb2A_GeoEntity = this.getProp(qb2S_PhysicsProps.GEOMETRY);
			
			if ( currentGeometry != null )
			{
				currentGeometry.getEventDispatcher().removeEventListener(onGeometryChanged);
			}
			
			var newGeometry:qb2A_GeoEntity = value;
			
			if ( newGeometry != null )
			{
				newGeometry.getEventDispatcher().addEventListener(onGeometryChanged);
			}
			
			super.setProp_protected(qb2S_PhysicsProps.GEOMETRY, value);
		}
		
		private function isSleeping():Boolean
		{
			if ( this.getWorld() == null )
			{
				return true;
			}
			
			var dirtyFlags:int = qb2P_Flusher.getInstance().getDirtyFlags(this);
			
			if ( this.getAncestorBody() != null )
			{
				return this.getAncestorBody().isSleeping();
			}
			else
			{
				if ( (dirtyFlags & qb2PF_DirtyFlag.SLEEP_STATE_CHANGED) != 0 )
				{
					return m_desiredSleepState;
				}
				else
				{
					if ( this.getBackEndRepresentation() != null )
					{
						return this.getBackEndRepresentation().getBoolean(qb2E_BackEndProp.IS_SLEEPING);
					}
					else
					{
						//TODO: I think this case means it's a group, so have to iterate through all children and see if they're all sleeping i guess.
						return false;
					}
				}
			}
			
			return m_desiredSleepState;
		}
		
		internal function onStepComplete_internal(stylePropStack_nullable:qb2PropMapStack):void
		{
			qb2PU_PhysicsObjectBackDoor.onStepComplete_internal(this); //effectively calling super.onStepComplete_internal() here.
			
			var backEndRep:qb2I_BackEndRepresentation = this.getBackEndRepresentation();
			
			if ( this.getAncestorBody() == null && backEndRep != null )
			{
				if ( qb2U_Type.isKindOf(this, qb2I_RigidObject) )
				{
					//--- Sync position and angle.
					m_position.getEventDispatcher().removeEventListener(onPositionChanged);
					{
						//TODO: Pass pixelsPerMeter down along with onStepComplete, or something.
						var pixelsPerMeter:Number = this.getEffectiveProp(qb2S_PhysicsProps.PIXELS_PER_METER);
						backEndRep.syncPoint(qb2E_BackEndProp.ABSOLUTE_POSITION, m_position, pixelsPerMeter);
						
						var transform:qb2AffineMatrix = getWorld().getTransformStack().get();
						
						transform.calcInverse(s_matrix);
						m_position.transformBy(s_matrix);
						
						syncActor();
					}
					m_position.getEventDispatcher().addEventListener(onPositionChanged);
					
					var rotationTransform:Number = this.getWorld().getRotationStack().value;
					var backEndRotation:Number = backEndRep.getFloat(qb2E_BackEndProp.ABSOLUTE_ROTATION);
					var newRotation:Number = backEndRotation - rotationTransform;
					setRotation_private(newRotation, false);
				}
			}
		}
		
		private function syncActor():void
		{
			var actor:qb2I_Actor = this.getEffectiveProp(qb2S_PhysicsProps.ACTOR);
			
			if ( actor != null )
			{
				actor.setX(m_position.getX());
				actor.setY(m_position.getY());
				actor.setRotation(m_rotation);
			}
		}
		
		protected override function copy_protected(source:*):void
		{
			/*if ( massPropsToo ) // clones will have this true by default, while convertTo*()'s will have it false.
			{
				this.m_surfaceArea = source.getSurfaceArea();
				this.m_mass        = source.getComputedProp(qb2S_PhysicsProps.MASS);
			}*/
			
			var sourceAsTang:qb2A_TangibleObject = (source as qb2A_TangibleObject);
			var sourceAsRigid:qb2I_RigidObject = source as qb2I_RigidObject;
			var thisAsRigid:qb2I_RigidObject = this as qb2I_RigidObject;
			
			if ( sourceAsTang != null )
			{
				this.m_position.copy(sourceAsTang.m_position);
				this.setRotation(sourceAsTang.m_rotation);
			}
			
			if ( thisAsRigid != null && sourceAsRigid != null )
			{
				thisAsRigid.getLinearVelocity().copy(sourceAsRigid.getLinearVelocity());
				thisAsRigid.setAngularVelocity(sourceAsRigid.getAngularVelocity());
			}
		}
		
		private function onTransformUpdated():void
		{
			this.syncActor();
			
			if ( this.getAncestorBody() != null ) // (if this object is a child of some body whose only other ancestors are qb2Groups...)
			{
				qb2PU_PhysicsObjectBackDoor.invalidate(this, qb2PF_DirtyFlag.RIGID_TRANSFORM_CHANGED);
			}
			else
			{
				qb2PU_PhysicsObjectBackDoor.invalidate(this, qb2PF_DirtyFlag.WORLD_TRANSFORM_CHANGED);
			}
		}
		
		public function applyAngularImpulse(impulse:Number):void
		{
			
		}
		
		public function applyLinearImpulse(atPoint:qb2GeoPoint, impulseVector:qb2GeoVector):void
		{
			/*if ( !m_world )
			{
				var delayedApply:qb2InternalDelayedApply = new qb2InternalDelayedApply();
				delayedApply.point = atPoint.clone() as qb2GeoPoint;
				delayedApply.vector = impulseVector.clone() as qb2GeoVector;
				delayedApply.isForce = false;
				addDelayedApply(this, delayedApply);
				
				return;
			}
			
			if ( qb2InternalBox2dTracker.isVisiting() )
			{
				qb2InternalBox2dTracker.addDelayedCall(this, applyLinearImpulse, atPoint.clone(), impulseVector.clone());
				return;
			}
			
			if ( _bodyB2 )
			{
				_bodyB2.applyLinearImpulse(new V2(impulseVector.getX(), impulseVector.getY()), new V2(atPoint.getX() / getWorldPixelsPerMeter(), atPoint.getY() / getWorldPixelsPerMeter()));
				m_rigidImp.m_linearVelocity.setX(_bodyB2.m_linearVelocity.x);
				m_rigidImp.m_linearVelocity.setY(_bodyB2.m_linearVelocity.y);
			}
			else if ( m_ancestorBody && m_ancestorBody._bodyB2 )
				m_ancestorBody.applyLinearImpulse(qb2U_Geom.calcWorldPoint(m_parent, atPoint), qb2U_Geom.calcWorldVector(getParent(), impulseVector));*/
		}
		
		public function applyForce(atPoint:qb2GeoPoint, forceVector:qb2GeoVector):void
		{
			/*if ( !m_world )
			{
				var delayedApply:qb2InternalDelayedApply = new qb2InternalDelayedApply();
				delayedApply.point = atPoint.clone() as qb2GeoPoint;
				delayedApply.vector = forceVector.clone() as qb2GeoVector;
				delayedApply.isForce = true;
				addDelayedApply(this, delayedApply);
				
				return;
			}
			
			if ( qb2InternalBox2dTracker.isVisiting() )
			{
				qb2InternalBox2dTracker.addDelayedCall(this, applyForce, atPoint.clone(), forceVector.clone());
				return;
			}
			
			if ( _bodyB2 )
				_bodyB2.ApplyForce(new V2(forceVector.getX(), forceVector.getY()), new V2(atPoint.getX() / getWorldPixelsPerMeter(), atPoint.getY() / getWorldPixelsPerMeter()));
			else if ( m_ancestorBody && m_ancestorBody._bodyB2 )
				m_ancestorBody.applyForce(qb2U_Geom.calcWorldPoint(m_parent, atPoint), qb2U_Geom.calcWorldVector(m_parent, forceVector));*/
		}
		
		public function applyTorque(torque:Number):void
		{
			/*if ( !m_world )
			{
				var delayedApply:qb2InternalDelayedApply = new qb2InternalDelayedApply();
				delayedApply.torque = torque;
				addDelayedApply(this, delayedApply);
				
				return;
			}
			
			if ( qb2InternalBox2dTracker.isVisiting() )
			{
				qb2InternalBox2dTracker.addDelayedCall(this, applyTorque, torque);
				return;
			}
			
			if ( _bodyB2 )
			{
				_bodyB2.ApplyTorque(torque);
			}*/
		}
		
		protected override function getEffectiveProp_protected(prop:qb2Prop, value_out_nullable:* = null):*
		{
			if ( qb2PU_PhysicsProp.isCoordProp(prop, qb2S_PhysicsProps.CENTER_OF_MASS) )
			{
				if ( prop == qb2S_PhysicsProps.CENTER_OF_MASS.Z )
				{
					//TODO: For 3d, this has to be calculated just like X and Y, which means we need to know if the backend is 3d or not i suppose.
					return this.getComputedProp_protected(qb2S_PhysicsProps.CENTER_OF_MASS.Z);
				}
				
				qb2U_Tang.calcCenterOfMass(this, s_utilPoint); // TODO: Is it safe to use static point recursively here?
				
				if ( prop == qb2S_PhysicsProps.CENTER_OF_MASS.X )
				{
					return s_utilPoint.getX();
				}
				else if ( prop == qb2S_PhysicsProps.CENTER_OF_MASS.Y )
				{
					return s_utilPoint.getY();
				}
				else
				{
					if ( qb2PU_PhysicsProp.copyCoordToValue(s_utilPoint, value_out_nullable) )
					{
						return value_out_nullable;
					}
					else
					{
						return s_utilPoint.clone();
					}
				}
			}
			else if ( prop == qb2S_PhysicsProps.MASS )
			{				
				return m_actualMass;
			}
			else if ( prop == qb2S_PhysicsProps.DENSITY )
			{
				return m_actualMass / m_actualSurfaceArea;
			}
			else
			{
				return super.getEffectiveProp_protected(prop, value_out_nullable);
			}
		}
		
		public function getPosition():qb2GeoPoint
		{
			return m_position;
		}
		
		/**
		 * Shortcut for getPosition().set().
		 *
		 * @return
		 */
		public function setPosition(x:Number, y:Number = 0, z:Number = 0):void
		{
			m_position.set(x, y, z);
		}

		public function getRotation():Number
		{
			return m_rotation;
		}

		public function setRotation(value:Number):void
		{
			setRotation_private(value, true);
			
			qb2PU_TangBackDoor.dispatchPropChangeEvent(this, qb2S_PhysicsProps.ROTATION);
		}
		
		private function setRotation_private(value:Number, callOnTransformUpdated:Boolean):void
		{
			m_rotation = qb2U_Math.normalizeAngle(value);
			
			if ( callOnTransformUpdated )
			{
				onTransformUpdated();
			}
		}
		
		internal function draw_internal(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap, propertyMapStack:qb2PropMapStack):void
		{
			
		}
		

		
		
		
		/*qb2_friend var _effectFields:Vector.<qb2A_EffectField>;
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var cloned:qb2A_PhysicsObject = super.clone(deep) as qb2A_PhysicsObject;
			
			cloned.copyTangibleProps(this, false);
			
			return cloned;
		}
			
	
		
		qb2_friend static const delayedAppliesDict:Dictionary = new Dictionary(true);
		
		private static function addDelayedApply(tang:qb2A_PhysicsObject, delayedApply:qb2InternalDelayedApply):void
		{
			var vec:Vector.<qb2InternalDelayedApply> = delayedAppliesDict[tang] ? delayedAppliesDict[tang] : new Vector.<qb2InternalDelayedApply>();
			delayedAppliesDict[tang] = vec;
			vec.push(delayedApply);
		}
		
		
		
		qb2_friend function populateTerrainsBelowThisTang():void
		{
			var globalList:Vector.<qb2Terrain> = m_world._globalTerrainList;
			
			_terrainsBelowThisTang = null;
			
			if ( globalList )
			{
				var numGlobalTerrains:int = globalList.length;
			
				for (var i:int = numGlobalTerrains-1; i >= 0; i-- ) 
				{
					var ithTerrain:qb2Terrain = globalList[i];
					
					if ( this == ithTerrain || qb2U_Family.isDescendantOf(this, ithTerrain) )  continue;
					
					if ( qb2U_Family.isAbove(this, ithTerrain) )
					{
						if ( !_terrainsBelowThisTang )
						{
							_terrainsBelowThisTang = new Vector.<qb2Terrain>();
						}
						
						_terrainsBelowThisTang.unshift(ithTerrain);
						
						if ( ithTerrain.ubiquitous )
						{
							break; // ubiquitous terrains cover up all other terrains beneath them, so we can move on.
						}
					}
					else
					{
						break; // all subsequent terrains will be over this shape, so we can move on.
					}
				}
			}
			
			m_world._terrainRevisionDict[this] = m_world._globalTerrainRevision;
		}
		qb2_friend var _terrainsBelowThisTang:Vector.<qb2Terrain>;
		
		protected override function update():void
		{
			var asRigid:qb2I_RigidObject = this as qb2I_RigidObject;  // assuming a little, but the only classes to call this super function are qb2Body and qb2Shape anyway...
			var isShape:Boolean = this is qb2Shape;
			
			for ( var i:int = 0; i < m_world._effectFieldStack.length; i++ )
			{
				var field:qb2A_EffectField = m_world._effectFieldStack[i];
				
				if ( field.applyPerShape && isShape || !field.applyPerShape && this._bodyB2 )
				{
					if ( !field.isDisabledFor(this, true) )
					{
						field.applyToRigid(asRigid);
					}
				}
			}
		}
		
		qb2_friend function drawDebugExtras(graphics:qb2I_Graphics2d):void
		{
			//--- Draw positions for rigid objects.
			if ( (this is qb2I_RigidObject) && (qb2S_DebugDraw.flags & qb2F_DebugDrawOption.POSITIONS) )
			{
				var rigid:qb2I_RigidObject = this as qb2I_RigidObject;
				var point:qb2GeoPoint = m_parent ? qb2U_Geom.calcWorldPoint(m_parent, rigid.getPosition()) : rigid.getPosition();
				
				graphics.pushFillColor(qb2S_DebugDraw.positionColor | qb2S_DebugDraw.positionAlpha);
				{
					graphics.drawCircle(point, qb2S_DebugDraw.pointRadius);
				}
				graphics.popFillColor();
			}
		
			var flags:uint = qb2S_DebugDraw.flags;
			var depth:uint = 0;
			
			var currParent:qb2A_PhysicsObject = this;
			while ( currParent != this.m_world )
			{
				depth++;
				currParent = currParent.getParent();
			}
			
			if ( flags & qb2F_DebugDrawOption.BOUND_BOXES )
			{
				if ( qb2U_Math.isWithin(depth, qb2S_DebugDraw.boundBoxStartDepth, qb2S_DebugDraw.boundBoxEndDepth) )
				{
					graphics.pushLineStyle(qb2S_DebugDraw.lineThickness, qb2S_DebugDraw.boundBoxColor | qb2S_DebugDraw.boundBoxAlpha);
					{
						18;//getBoundBox().draw(graphics);
					}
					graphics.popLineStyle();
				}
			}
			
			if ( flags & qb2F_DebugDrawOption.BOUND_CIRCLES )
			{
				if ( qb2U_Math.isWithin(depth, qb2S_DebugDraw.boundCircleStartDepth, qb2S_DebugDraw.boundCircleEndDepth) )
				{
					graphics.pushLineStyle(qb2S_DebugDraw.lineThickness, qb2S_DebugDraw.boundCircleColor | qb2S_DebugDraw.boundCircleAlpha);
					{
						18;//getBoundCircle().draw(graphics);
					}
					graphics.popLineStyle();
				}
			}
			
			if ( flags & qb2F_DebugDrawOption.CENTROIDS )
			{
				if ( qb2U_Math.isWithin(depth, qb2S_DebugDraw.centroidStartDepth, qb2S_DebugDraw.centroidEndDepth) )
				{
					var centroid:qb2GeoPoint = calcCenterOfMass();
					if ( centroid )
					{
						graphics.pushFillColor(qb2S_DebugDraw.centroidColor | qb2S_DebugDraw.centroidAlpha);
						{
							graphics.drawCircle(centroid, qb2S_DebugDraw.pointRadius);
						}
						graphics.popFillColor();
					}
				}
			}
		}
		
		qb2_friend function getDebugOutlineColor(graphics:qb2I_Graphics2d):uint
		{
			if ( !graphics.hasLineStyle() )
			{
				if ( this.getSharedFlag(qb2S_PhysicsProps.IS_KINEMATIC) )
				{
					return qb2S_DebugDraw.kinematicOutlineColor;
				}
				else
				{
					return m_mass == 0 ? qb2S_DebugDraw.staticOutlineColor : qb2S_DebugDraw.dynamicOutlineColor;
				}
			}
			else
			{
				return graphics.getCurrentLineColor();
			}
		}
		
		qb2_friend function getDebugFillColor(graphics:qb2I_Graphics2d):uint
		{
			if ( graphics.hasFillColor() )
			{
				return graphics.getCurrentFillColor();
			}
			else
			{
				if ( this.getSharedFlag(qb2S_PhysicsProps.IS_KINEMATIC) )
				{
					return qb2S_DebugDraw.kinematicFillColor;
				}
				else
				{
					return m_mass == 0 ? qb2S_DebugDraw.staticFillColor : qb2S_DebugDraw.dynamicFillColor;
				}
			}
		}
		
		qb2_friend function pushToEffectsStack():int
		{
			var numPushed:int = 0;
			
			if ( m_world  )
			{
				if ( _effectFields )
				{
					//--- Push all of this object's fields to the effects stack.
					for (var i:int = 0; i < _effectFields.length; i++) 
					{
						var ithField:qb2A_EffectField = _effectFields[i];
						
						m_world._effectFieldStack.push(ithField);
						numPushed++;
					}
				}
			}
			
			return numPushed;
		}
		
		qb2_friend function popFromEffectsStack(numToPop:int):void
		{
			for (var i:int = 0; i < numToPop; i++) 
			{
				var field:qb2A_EffectField = m_world._effectFieldStack.pop();
			}
		}*/
		
		[qb2_abstract] internal function getRigidComponent():qb2P_RigidComponent
		{
			return null;
		}
		
		public function getJointList():qb2Joint
		{
			return m_jointList;
		}
		
		internal function setJointList(joint:qb2Joint):void
		{
			m_jointList = joint;
		}
		
		public function getSurfaceArea():Number
		{
			qb2P_Flusher.getInstance().flush();
			
			return m_actualSurfaceArea;
		}
	}
}