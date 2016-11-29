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

package quickb2.physics.core.tangibles
{
	import flash.utils.*;
	import quickb2.debugging.*;
	import quickb2.debugging.logging.*;
	import quickb2.display.immediate.graphics.*;
	import quickb2.event.*;
	import quickb2.lang.*;
	import quickb2.lang.errors.*;
	import quickb2.lang.foundation.*;
	import quickb2.math.*;
	import quickb2.math.geo.*;
	import quickb2.math.geo.coords.*;
	import quickb2.physics.core.*;
	import quickb2.physics.core.backend.*;
	import quickb2.physics.core.bridge.*;
	import quickb2.physics.core.events.*;
	import quickb2.physics.core.joints.*;
	import quickb2.utils.*;
	import quickb2.utils.primitives.qb2Float;
	import quickb2.utils.prop.*;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2World extends qb2Group
	{
		private static const s_utilPropFlags3:qb2MutablePropFlags = new qb2MutablePropFlags();
		
		private var m_backEnd:qb2I_BackEndWorldRepresentation;
		
		private const m_telemetry:qb2WorldTelemetry = new qb2WorldTelemetry();
		
		private var m_lastAutoStepTime:Number = 0;
		
		private var m_clock:qb2I_Clock;
		private var m_timer:qb2I_Timer;
		
		private const m_gravity:qb2GeoVector = new qb2GeoVector();
		private var m_config:qb2WorldConfig = null;
		
		private var m_timerDelegate:qb2TimerClosureListener;
		
		private const m_preStepDispatchers:Vector.<qb2I_EventDispatcher> = new Vector.<qb2I_EventDispatcher>();
		private const m_postStepDispatchers:Vector.<qb2I_EventDispatcher> = new Vector.<qb2I_EventDispatcher>();
		
		private const m_transformStack:qb2TransformStack = new qb2TransformStack();
		private const m_rotationStack:qb2Float = new qb2Float();
		private const m_stylePropStack:qb2PropMapStack = new qb2PropMapStack();
		
		private var m_physicsPropSheet:qb2PropSheet = null;
		private var m_stylePropSheet:qb2PropSheet = null;
		
		/**
		 * Creates a new qb2World instance.
		 */
		public function qb2World(backEnd:qb2I_BackEndWorldRepresentation, config_nullable:qb2WorldConfig = null)
		{
			init(backEnd, config_nullable);
		}
		
		private function init(backEnd:qb2I_BackEndWorldRepresentation, config_nullable:qb2WorldConfig):void
		{
			m_backEnd = backEnd;
			
			qb2PU_PhysicsObjectBackDoor.setBackEndRepresentation(this, m_backEnd);
			
			m_transformStack.get().setToIdentity();

			m_backEnd.startUp(this, new qb2P_BackEndCallbacks());
			
			setConfig(config_nullable != null ? config_nullable : new qb2WorldConfig());
			
			m_timerDelegate = new qb2TimerClosureListener(function():void
			{
				step_auto();
			});
			
			//--- DRK > Current setup doesn't allow style sheet to be set at this point,
			//---		but just in case this changes in the future, like you can pass
			//---		it through the constructor or something, we account for it here.
			qb2PU_PhysicsObjectBackDoor.onAddedToWorld(this, this, s_utilPropFlags3);
			if ( !s_utilPropFlags3.isEmpty() )
			{
				qb2P_Flusher.getInstance().addDirtyObject(this, qb2PF_DirtyFlag.PROPERTY_CHANGED, s_utilPropFlags3);
			}
		}
		
		public function getPhysicsPropSheet():qb2PropSheet
		{
			return m_physicsPropSheet;
		}
		
		public function setPhysicsPropSheet(sheet:qb2PropSheet):void
		{
			var oldSheet:qb2PropSheet = this.m_physicsPropSheet;
			m_physicsPropSheet = sheet;
			
			if ( m_physicsPropSheet != oldSheet )
			{
				onPhysicsPropSheetChange();
			}
		}
		
		private function onPhysicsPropSheetChange():void
		{
			this.recomputePhysicsProps();
		}
		
		public function getStylePropSheet():qb2PropSheet
		{
			return m_stylePropSheet;
		}
		
		public function setStylePropSeet(sheet:qb2PropSheet):void
		{
			var oldSheet:qb2PropSheet = this.m_stylePropSheet;
			m_stylePropSheet = sheet;
			
			if ( m_stylePropSheet != oldSheet )
			{
				onStylePropSheetChange();
			}
		}
		
		private function onStylePropSheetChange():void
		{
			this.recomputeStyleProps();
		}
		
		public function getTelemetry():qb2WorldTelemetry
		{
			return m_telemetry;
		}
		
		internal function addStepDispatcher(type:int, dispatcher:qb2I_EventDispatcher):void
		{
			if ( hasStepDispatcher(type, dispatcher) )
			{
				return;
			}
			
			var list:Vector.<qb2I_EventDispatcher> = type == qb2PU_TangBackDoor.PRE_STEP_DISPATCHER ? m_preStepDispatchers : m_postStepDispatchers;
			
			list.push(dispatcher);
		}
		
		private function hasStepDispatcher(type:int, dispatcher:qb2I_EventDispatcher):Boolean
		{
			var list:Vector.<qb2I_EventDispatcher> = type == qb2PU_TangBackDoor.PRE_STEP_DISPATCHER ? m_preStepDispatchers : m_postStepDispatchers;
			
			return list.indexOf(dispatcher) >= 0;
		}
		
		internal function removeStepDispatcher(type:int, dispatcher:qb2I_EventDispatcher):void
		{
			var list:Vector.<qb2I_EventDispatcher> = type == qb2PU_TangBackDoor.PRE_STEP_DISPATCHER ? m_preStepDispatchers : m_postStepDispatchers;
			
			var index:int = list.indexOf(dispatcher);
			
			if ( index >= 0 )
			{
				list.splice(index, 1);
			}
		}
		
		public function getConfig():qb2WorldConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2WorldConfig):void
		{
			m_config = config;
		}
		
		internal function getTransformStack():qb2TransformStack
		{
			return m_transformStack;
		}
		
		internal function getRotationStack():qb2Float
		{
			return m_rotationStack;
		}
		
		/**
		 * Whether or not startAutoStepping() has been called.
		 * 
		 * @default false
		 * @see #startAutoStepping()
		 */
		public function isAutoStepping():Boolean
		{
			return m_timer != null;
		}
	
		/**
		 * Starts the simulation by calling step every time the given timer ticks.
		 * This is purely a convenience.  You can set up your own event loop and call qb2World::step() yourself if you want.
		 * The timer and clock must both be non-null the first time you call this method.
		 * Subsequent calls can omit these parameters and the world will reuse the original ones.
		 * 
		 * @see #stopAutoStepping()
		 * @see #step()
		 */
		public function startAutoStep(timer_nullable:qb2I_Timer = null, clock_nullable:qb2I_Clock = null):void
		{
			if ( timer_nullable != null )
			{
				m_timer = timer_nullable;
			}
			else if ( m_timer == null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.MISSING_DEPENDENCY, "Must provide a timer at least once.");
			}
			
			if ( clock_nullable != null )
			{
				m_clock = clock_nullable;
			}
			else if ( m_clock == null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.MISSING_DEPENDENCY, "Must provide a clock at least once.");
			}
			
			m_lastAutoStepTime = m_clock.getSecondsSinceAppStart();
			
			m_timer.start(m_timerDelegate);
		}
		
		/**
		 * Stops the automatic stepping of the simulation by stopping the timer given in qb2World::start();
		 * 
		 * @see #startAutoStepping()
		 * @see #step()
		 */
		public function stopAutoStep():void
		{
			if ( m_timer == null )  return;
			
			m_timer.stop();
		}
		
		private function step_auto():void
		{
			var currentTime:Number = m_clock.getSecondsSinceAppStart();
			var timeStep:Number = m_config.autoStepWithRealTimeDelta ?
									qb2U_Math.clamp(currentTime - m_lastAutoStepTime, 0, m_config.autoStepMaximumRealTimeDelta) :
									m_timer.getTickRate();
			
			this.step(timeStep, m_config.autoStepPositionIterations, m_config.autoStepVelocityIterations);
			
			m_lastAutoStepTime = currentTime;
		}
		
		/**
		 * Updates the physics world. This includes processing debug mouse input, drawing debug graphics, updating the clock, firing pre/post events, and updating actor positions (if applicable).
		 * You can call step at any time and as often as you want, it doesn't have to be once per frame.  For example you can call step a dozen or so times in a for-loop in order to simulate something to rest,
		 * before you start stepping once per frame as usual. step() is called automatically once per frame if you're using start()/stop() to manage your game loop.
		 * 
		 * @see #defaultTimeStep
		 * @see #realtimeUpdate
		 * @see #startAutoStepping()
		 * @see #stopAutoStepping()
		 */
		public function step( timeStep:Number = 1.0/30.0, positionIterations:uint = 3, velocityIterations:uint = 8 ):void
		{
			m_telemetry.onStepStart(timeStep);
			
			var i:int;
			
			for ( i = 0; i < m_preStepDispatchers.length; i++ )
			{
				var dispatcher:qb2I_EventDispatcher = m_preStepDispatchers[i];
				var preEvent:qb2StepEvent = qb2GlobalEventPool.checkOut(qb2StepEvent.PRE_STEP) as qb2StepEvent;
				dispatcher.dispatchEvent(preEvent);
			}
			
			qb2P_Flusher.getInstance().flush();
			
			m_telemetry.onBackEndStepStart();
			
			m_backEnd.step(timeStep, velocityIterations, positionIterations);
			
			m_telemetry.onBackEndStepComplete();
			
			if ( m_backEnd.getErrorDuringLastStep() != null )
			{
				qb2U_Error.throwError(m_backEnd.getErrorDuringLastStep());
			}
			
			qb2P_Flusher.getInstance().flush();
			
			var graphics:qb2I_Graphics2d = m_config.graphics;
			
			if ( graphics != null )
			{
				graphics.clearBuffer();
				
				graphics.getTransformStack().pushAndSet(qb2S_Math.IDENTITY_MATRIX);
			}
			
			this.onStepComplete_internal(this.m_stylePropStack);
			
			if ( graphics != null )
			{
				graphics.getTransformStack().pop();
			}
			
			for ( i = 0; i < m_postStepDispatchers.length; i++ )
			{
				dispatcher = m_postStepDispatchers[i];
				var postEvent:qb2StepEvent = qb2GlobalEventPool.checkOut(qb2StepEvent.POST_STEP) as qb2StepEvent;
				dispatcher.dispatchEvent(postEvent);
			}
			
			m_telemetry.onStepComplete();
		}
		
		public override function clone():*
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.BAD_CLONE, "A world cannot be cloned.");
			
			return null;
		}
		
		/*qb2_friend const _effectFieldStack:Vector.<qb2A_EffectField> = new Vector.<qb2A_EffectField>();
		
		qb2_friend function registerGlobalTerrain(terrain:qb2Terrain):void
		{
			terrain.addEventListener(qb2ContainerEvent.INDEX_CHANGED, terrainIndexChanged, null, true);
			
			addTerrainToList(terrain);
		}
		
		private function terrainIndexChanged(evt:qb2ContainerEvent):void
		{
			var terrain:qb2Terrain = evt.getChild() as qb2Terrain;
			
			_globalTerrainList.splice(_globalTerrainList.indexOf(terrain), 1);
			
			addTerrainToList(terrain);
		}
		
		private function addTerrainToList(terrain:qb2Terrain):void
		{
			if ( !_globalTerrainList )
			{
				_globalTerrainList = new Vector.<qb2Terrain>();
				_globalTerrainList.push(terrain);
			}
			else
			{
				var inserted:Boolean = false;
				for (var i:int = 0; i < _globalTerrainList.length; i++) 
				{
					var ithTerrain:qb2Terrain = _globalTerrainList[i];
					
					if ( !qb2U_Family.isAbove(terrain, ithTerrain) )
					{
						inserted = true;
						_globalTerrainList.splice(i, 0, terrain);
						break;
					}
				}
				
				if ( !inserted )
				{
					_globalTerrainList.push(terrain);
				}
			}
			
			_globalTerrainRevision++;
		}
		
		qb2_friend function unregisterGlobalTerrain(terrain:qb2Terrain):void
		{
			_globalTerrainList.splice(_globalTerrainList.indexOf(terrain), 1);
			
			if ( !_globalTerrainList.length )
			{
				_globalTerrainList = null;
			}
			
			terrain.removeEventListener(qb2ContainerEvent.INDEX_CHANGED, terrainIndexChanged);
			
			_globalTerrainRevision++;
		}
		
		qb2_friend var _globalTerrainList:Vector.<qb2Terrain> = null;
		
		qb2_friend var _globalGravityZRevision:int = 0;
		qb2_friend var _globalTerrainRevision:int = 0;
		
		qb2_friend const _terrainRevisionDict:Dictionary = new Dictionary(true);
		qb2_friend const m_gravityZRevisionDict:Dictionary = new Dictionary(true);*/
	}
}