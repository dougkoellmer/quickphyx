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

package quickb2.physics.driving
{
	import quickb2.internals.qb2InternalCarKinematics;
	import quickb2.physics.core.events.qb2ContainerEvent;
	import quickb2.physics.core.events.qb2MassEvent;
	
	import quickb2.physics.core.tangibles.qb2Body;
	
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.general.*;
	import quickb2.math.geo.*;
	import flash.utils.*;
	import quickb2.lang.*
	import quickb2.event.*;
	import quickb2.objects.driving.qb2CarTire;
	import quickb2.utils.iterators.qb2TreeIterator;
	
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	import quickb2.objects.driving.configs.qb2CarBodyConfig;
	import quickb2.objects.extras.qb2Terrain;
	import quickb2.utils.qb2TreeIterator;
	import TopDown.*;
	import TopDown.ai.*;
	import TopDown.carparts.*;
	import TopDown.internals.*;
	
	
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarBody extends qb2Body implements qb2I_SmartObject
	{
		private static var MINIMUM_LINEAR_VELOCITY:Number = .01;
		private static var SKID_SLOP:Number = .00000001; // fixes floating point round-off errors that cause a tire to not set isSkidding to true when it sometimes should.
		private static var STOPPED_SLOP:Number = .0000001; // car speed below this just sets the car's velocities to zero...

		private const tires:Vector.<qb2CarTire> = new Vector.<qb2CarTire>();
		
		private var numDrivenTires:uint = 0;
		
		private var _currTurnAngle:Number = 0;
		
		private const m_kinematics:qb2CarKinematics = new qb2CarKinematics();
		
		private var freezeTireCalc:Boolean = false;
		
		private const m_axleLayout:qb2InternalAxleLayout = null;
		
		private var m_config:qb2CarBodyConfig = null;
		

		public function qb2CarBody(config_nullable:qb2CarBodyConfig = null)
		{
			super();
			
			init(config_nullable);
		}
		
		private function init(config:qb2CarBodyConfig):void
		{
			addEventListener(qb2ContainerEvent.ADDED_TO_WORLD,     addedOrRemoved,    null, true);
			addEventListener(qb2ContainerEvent.REMOVED_FROM_WORLD, addedOrRemoved,    null, true);
			addEventListener(qb2ContainerEvent.INDEX_CHANGED,      indexChanged,      null, true);
			addEventListener(qb2ContainerEvent.ADDED_OBJECT,       justAddedObject,   null, true);
			addEventListener(qb2ContainerEvent.REMOVED_OBJECT,     justRemovedObject, null, true);
			addEventListener(qb2MassEvent.MASS_PROPS_CHANGED,      massPropsUpdated,  null, true);
			
			setConfig(config ? config : (qb2CarBodyConfig.useSharedInstanceByDefault ? qb2CarBodyConfig.getInstance() : new qb2CarBodyConfig()));
		}
		
		public function getConfig():qb2CarBodyConfig
		{
			return m_config;
		}
		
		public function setConfig(config:qb2CarBodyConfig):void
		{
			m_config = config;
		}
		
		private function addedOrRemoved(evt:qb2ContainerEvent):void
		{
			invalidateTireMetrics();
			
			if ( evt.type == qb2ContainerEvent.ADDED_TO_WORLD )
			{
				_map = getAncestorOfType(qb2Map) as qb2Map;
			}
			else
			{
				_map = null;
			}
		}
		
		private function indexChanged(evt:qb2ContainerEvent):void
		{
			m_world._terrainRevisionDict[this] = -1; // let this car know that it needs to update its terrain list on the next pass.
		}
		
		private function invalidateTireMetrics():void
		{
			for ( var i:int = 0; i < tires.length; i++ )
			{
				tires[i].invalidateMetrics();
			}
		}
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var cloned:qb2CarBody = super.clone(deep) as qb2CarBody;
			
			cloned.m_config.copy(this.m_config);
			
			return cloned;
		}
			
		public function isReversing():Boolean
		{
			return kinematics.longSpeed < 0;
		}
	
		public function getCurrentTurnAngle():Number
			{  return _currTurnAngle;  }
			
		private function justAddedObject(evt:qb2ContainerEvent):void
		{
			var object:qb2A_PhysicsObject = evt.child;
			
			if ( object is qb2CarTire )
			{
				var tire:qb2CarTire = object as qb2CarTire;
				tire._carBody = this;
				
				if ( tire.isDriven )  numDrivenTires++;
				
				tire.invalidateMetrics();
				
				tires.push(tire);
				
				calcTireShares();
			}
			else if ( object is qb2CarEngine )
			{
				_engine = object as qb2CarEngine;
				_engine._carBody = this;
			}
			else if ( object is qb2CarTransmission )
			{
				_tranny = object as qb2CarTransmission;
				_tranny._carBody = this;
			}
		}
		
		private function justRemovedObject(evt:qb2ContainerEvent):void
		{
			var object:qb2A_PhysicsObject = evt.child;
			
			if ( object is qb2CarTire )
			{
				var tire:qb2CarTire = object as qb2CarTire;
				
				tire._carBody = null;
				
				tire.invalidateMetrics();
				
				tires.splice(tires.indexOf(tire), 1);
				
				calcTireShares();
			}
			else if ( object is qb2CarEngine )
			{
				_engine._carBody = null;
				_engine = null;
			}
			else if ( object is qb2CarTransmission )
			{
				_tranny._carBody = null;
				_tranny = null;
			}
		}
		
		qb2_friend function calcTireShares():void
		{
			if ( freezeTireCalc )  return;
			
			if ( !tires.length )
			{
				axle = null;
				return;
			}
			
			var centroid:qb2GeoPoint = this.calcLocalPoint(this.centerOfMass, this.parent);
			//trace("calcling tires");
	
			axle = axle ? axle : new qb2InternalAxleLayout();
			var totMass:Number = this.mass;
			axle.avgLeft = axle.avgRight = 0;// centroid.x;
			axle.avgTop = axle.avgBot = 0;// centroid.y;
			
			var avgTurnAxis:Number = 0;
			var numTurningTires:int = 0;
			
			axle.numLeft = axle.numRight = axle.numTop = axle.numBot = 0;
			
			for ( var i:int = 0; i < tires.length; i++ )
			{
				var iTire:qb2CarTire = tires[i];
				
				if ( iTire.canTurn )
				{
					avgTurnAxis += iTire.position.y
					numTurningTires++;
				}
				
				iTire.quadrant = 0;
			
				if ( iTire._position.y <= centroid.y )
				{
					iTire.quadrant |= qb2CarTire.QUAD_TOP;
					axle.avgTop += iTire._position.y;
					axle.numTop++;
				}
				else
				{
					iTire.quadrant |= qb2CarTire.QUAD_BOT;
					axle.avgBot += iTire._position.y;
					axle.numBot++;
				}
				
				if ( iTire._position.x >= centroid.x )
				{
					iTire.quadrant |= qb2CarTire.QUAD_RIGHT;
					axle.avgRight += iTire._position.x;
					axle.numRight++;
				}
				else
				{
					iTire.quadrant |= qb2CarTire.QUAD_LEFT;
					axle.avgLeft += iTire._position.x;
					axle.numLeft++;
				}
			}
			
			turnAxis = autoSetTurnAxis ? avgTurnAxis / numTurningTires : turnAxis;
			
			axle.avgTop   /= axle.numTop;
			axle.avgBot   /= axle.numBot;
			axle.avgLeft  /= axle.numLeft;
			axle.avgRight /= axle.numRight;
			
			if ( !axle.numTop )
			{
				axle.numTop = 1;
				axle.avgTop = centroid.y - (axle.avgBot - centroid.y);
			}
			
			if ( !axle.numBot )
			{
				axle.numBot = 1;
				axle.avgBot = centroid.y - (axle.avgTop - centroid.y);
			}
			
			if ( !axle.numLeft )
			{
				axle.numLeft = 1;
				axle.avgLeft = centroid.x - (axle.avgRight - centroid.x);
			}
			
			if ( !axle.numRight )
			{
				axle.numRight = 1;
				axle.avgRight = centroid.x - (axle.avgLeft - centroid.x);
			}
			
			turnAxis = axle.avgTop;
			
			
			
			//--- calc mass share. The mass share of a tire times the world's
			//--- z gravity determines the at-rest load on a tire.
			var baseHeight:Number = axle.avgBot - axle.avgTop;
			var baseWidth:Number = axle.avgRight - axle.avgLeft;
			for ( i = 0; i < tires.length; i++ )
			{
				iTire = tires[i];
				
				var upDownMass:Number = 0;
				
				if ( iTire.quadrant & qb2CarTire.QUAD_TOP )
				{
					var ratio:Number = (Math.abs(centroid.y - axle.avgBot) / baseHeight);
					upDownMass = (ratio ? ratio : 1) * totMass;
					upDownMass /= axle.numTop;
				}
				else
				{
					ratio = (Math.abs(centroid.y - axle.avgTop) / baseHeight);
					upDownMass = (ratio ? ratio : 1) * totMass;
					upDownMass /= axle.numBot;
				}
				
				var leftRightMass:Number = 0;
				
				if ( iTire.quadrant & qb2CarTire.QUAD_RIGHT )
				{
					ratio = (Math.abs(centroid.x - axle.avgLeft) / baseWidth);
					leftRightMass = (ratio ? ratio : 1) * totMass;
					leftRightMass /= axle.numRight;
				}
				else
				{
					ratio = (Math.abs(centroid.x - axle.avgRight) / baseWidth);
					leftRightMass = (ratio ? ratio : 1) * totMass;
					leftRightMass /= axle.numLeft;
				}
				
				iTire.m_massShare = leftRightMass / 2 + upDownMass / 2;
			}
		}
		
		private static var reusableTerrainList:Vector.<qb2Terrain> = new Vector.<qb2Terrain>();
		private static var terrainIterator:qb2TreeIterator = new qb2TreeIterator();
		
		protected override function update():void
		{
			super.update();
			
			if ( !axle )  return;
			
			if( m_world._terrainRevisionDict[this] != m_world._globalTerrainRevision )
			{
				populateTerrainsBelowThisTang();
			}
			
			var pedal:Number = brainPort.NUMBER_PORT_1;
			var turn:Number  = brainPort.NUMBER_PORT_2;
			var brake:Number = brainPort.NUMBER_PORT_3;
			
			var lengthSquared:Number = linearVelocity.lengthSquared;
			if ( lengthSquared && angularVelocity && lengthSquared < STOPPED_SLOP && angularVelocity < STOPPED_SLOP )
			{
				this.getLinearVelocity().zeroOut();
				this.setAngularVelocity(0);
			}
			
			_currTurnAngle = turn;

			var driveTorquePerTire:Number = 0;
			if ( _engine && _tranny )
			{
				_tranny.relay_update();
				_engine.throttle(Math.abs(pedal));
				driveTorquePerTire = tranny.calcTireTorque(engine.torque) / numDrivenTires;
				driveTorquePerTire = tranny.inReverse ? -driveTorquePerTire : driveTorquePerTire;
			}
			
			var avgRadsPerSec:Number = 0;
			
			if ( parked )  brake = 1;  // Override braking for if the car is parked...like as if it had its parking brake on.
			
			//--- Get some vectors for orientation/speed.
			var carVec:qb2GeoVector = this.getNormal();
			var turnVec:qb2GeoVector = new qb2GeoVector();
			var sideVec:qb2GeoVector = carVec.calcPerpVector(1);
			var carLinVel:qb2GeoVector = this.getLinearVelocity.clone();
			
			//--- Figure out the accelerations/velocities of this body by comparing things from last frame.
			_kinematics._overallSpeed = carLinVel.length;
			carLinVel.normalize();
			var longDot:Number = carLinVel.dotProduct(carVec);
			var latDot:Number = carLinVel.dotProduct(sideVec);
			var tempLongSpeed:Number = _kinematics._overallSpeed * longDot;
			var tempLatSpeed:Number = _kinematics._overallSpeed * latDot;
			_kinematics._longAccel = tempLongSpeed - _kinematics._longSpeed;
			_kinematics._latAccel = tempLatSpeed - _kinematics._latSpeed;
			_kinematics._longAccel /= m_world.lastTimeStep;
			if ( isNaN(_kinematics._longAccel) )  _kinematics._longAccel = 0;
			_kinematics._latAccel /= m_world.lastTimeStep;
			if ( isNaN(_kinematics._latAccel) )  _kinematics._latAccel = 0;
			_kinematics._longSpeed = tempLongSpeed;
			_kinematics._latSpeed = tempLatSpeed;
			
			//--- calc weight transfer and center of mass. This is later factored into each tire's load.
			//--- Tires like on a motorcycle will have 0 lateral weight transfer applied, because in real
			//--- life the driver is responsible for adjusting center of mass to keep lateral tranfer zeroed out.
			var totMass:Number = this.mass;
			var vertDiff:Number = axle.avgBot   - axle.avgTop,
				horDiff:Number  = axle.avgRight - axle.avgLeft;
			var longTransfer:Number = vertDiff ? (zCenterOfMass / vertDiff) * totMass * _kinematics._longAccel : 0;
			var latTransfer:Number  = horDiff  ? (zCenterOfMass / horDiff)  * totMass * _kinematics._latAccel  : 0;
			
			reusableTerrainList.length = 0;
			if ( _terrainsBelowThisTang )
			{
				var globalTerrains:Vector.<qb2Terrain> = _terrainsBelowThisTang;
				for (var j:int = globalTerrains.length-1; j >= 0; j--) 
				{
					var jthTerrain:qb2Terrain = globalTerrains[j];
					if ( jthTerrain.ubiquitous )
					{
						reusableTerrainList.unshift(jthTerrain);
					}
					else if( _contactTerrainDict && _contactTerrainDict[jthTerrain] )
					{
						reusableTerrainList.unshift(jthTerrain);
					}
				}
			}

			//--- Iterate through the tires, applying various forces to the body at the tires' locations.
			var actualNumDrivenTires:int = numDrivenTires;
			for ( var i:uint = 0; i < tires.length; i++ )
			{			
				var tire:qb2CarTire = tires[i];
				
				tire._currTurnAngle = tire.canTurn ? _currTurnAngle : 0;
				tire._currTurnAngle = tire.flippedTurning ? -tire._currTurnAngle : tire._currTurnAngle;
				if ( tire.actor )  tire.actor.setRotation(tire._currTurnAngle * TO_DEG);
				tire._wasSkidding = tire._isSkidding;
				tire._isSkidding = false;
				
				var worldTirePos:qb2GeoPoint = tire.getWorldPosition();
				
				//--- Figure out the load on this tire based on its mass share and the body's acceleration/weight transfer.
				tire._load = tire.m_massShare * m_world.gravityZ;
				if ( tire.quadrant & qb2CarTire.QUAD_TOP )
					tire._load -= longTransfer / axle.numTop;
				else
					tire._load += longTransfer / axle.numBot;
				if ( tire.quadrant & qb2CarTire.QUAD_RIGHT )
					tire._load -= latTransfer / axle.numRight;
				else
					tire._load += latTransfer / axle.numLeft;

					
				const tireLoad:Number = tire._load < 0 ? 0 : tire._load; // A tire can have a negative load (e.g. if it would be up in the air in a 3d simulation), so load in this case must be manually set to 0.

				//--- If the load on the tire is <= zero, it means it's actually up in the air, and thus incapable of delivering forces to the car's chassis.
				//--- In real life, this means that the car would be doing a wheelie or rolling or something. This is just a 2d simulation though, unfortunately :)
				//if ( tire._load <= 0 )  continue;

				//--- Get the tire's overall speed and direction of movement.
				var worldTireLinVel:qb2GeoVector = this.getLinearVelocityAtPoint(worldTirePos);
				var tireSpeed:Number = worldTireLinVel.length;
				tire._linearVelocity.copy(worldTireLinVel);
				var tireMovementDirection:qb2GeoVector = worldTireLinVel.normalize();
				
				//--- Get the vectors describing the tire's orientation.
				turnVec.copy(carVec).rotate(tire._currTurnAngle);
				var tireOrientation:qb2GeoVector = tire.canTurn ? turnVec.clone() : carVec.clone();
				var tireSideways:qb2GeoVector    = tireOrientation.perpVector();
				tireSideways = Math.abs(tireSideways.angleTo(tireMovementDirection)) < Math.PI / 2 ? tireSideways.negate() : tireSideways;
				
				var dot:Number = tireMovementDirection.dotProduct(tireOrientation);
				if ( isNaN(dot) )  dot = 0;
				var tireSpeedLong:Number = (tireSpeed * dot);
				tire._baseRadsPerSec = tireSpeedLong / tire.metricRadius;
				
				if ( this.isSleeping && !pedal && !tire._extraRadsPerSec )  continue;  // skip sleeping bodies to boost performance.
				
				var highestTerrain:qb2Terrain = null;
				
				var frictionMultiplier:Number = 1, rollingFrictionMultiplier:Number = 1;
				if ( reusableTerrainList.length )
				{
					for ( j = reusableTerrainList.length-1; j >= 0; j-- )
					{
						jthTerrain = reusableTerrainList[j];
						
						if ( jthTerrain.ubiquitous || !testTiresIndividuallyAgainstTerrains )
						{
							highestTerrain = jthTerrain;
							break;
						}
						else if( jthTerrain.testPoint(worldTirePos) )
						{
							highestTerrain = jthTerrain;
							break;
						}
					}
				}
				
				if ( highestTerrain )
				{
					frictionMultiplier *= highestTerrain.frictionZMultiplier;
					
					if ( highestTerrain is qb2Terrain )
					{
						rollingFrictionMultiplier *= (highestTerrain as qb2Terrain).rollingFrictionZMultiplier;
					}
				}
				
				//--- Some helpers...
				var force:Number = 0;
				const tireFric:Number = tire.friction * frictionMultiplier;
				var fricForce:Number = tireFric * tireLoad;
				const tireSpinDirection:Number = qb2U_Math.sign(tire.radsPerSec);
				
				var totalTorque:Number = 0;
				
				if ( tire._extraRadsPerSec )
				{
					var torqueFromExtraSpin:Number = fricForce * tire.metricRadius * qb2U_Math.sign(tire._extraRadsPerSec);
					
					totalTorque += torqueFromExtraSpin;
					
					const negatingAccel:Number = torqueFromExtraSpin / tire.metricInertia;
				
					const radsPerSecDiff:Number = negatingAccel * world.lastTimeStep;
				
					var was:Number = tire._extraRadsPerSec;
					tire._extraRadsPerSec -= radsPerSecDiff;
					
					if ( was < 0 && tire._extraRadsPerSec > 0 || was > 0 && tire._extraRadsPerSec < 0 )
					{
						tire._extraRadsPerSec = 0;
					}
				}
				
				//--- Apply engine power to the tire if appropriate.
				if( tire.isDriven && tranny )
				{
					totalTorque += driveTorquePerTire;
				}
				
				force = totalTorque / tire.metricRadius;
				
				var absForce:Number = Math.abs(force);
				if ( absForce >= fricForce - SKID_SLOP )
				{
					tire._isSkidding = !tractionControl;
					force = fricForce * qb2U_Math.sign(force);
					
					if ( !tractionControl && absForce > fricForce )
					{
						const leftOverTorque:Number = (absForce - fricForce) * tire.metricRadius;
						const leftOverAccel:Number = leftOverTorque / tire.metricInertia;
						tire._extraRadsPerSec += qb2U_Math.sign(force) * leftOverAccel * world.lastTimeStep;
					}
				}

				if( force )
					this.applyForce(worldTirePos, tireOrientation.scaledBy(force));
					
				if ( tire.canBrake && brake )
				{
					var negater:Number = tireSpeedLong * tireLoad;
					var brakeForce:Number = negater > fricForce ? fricForce * -tireSpinDirection : -negater;
					if( brakeForce )
						this.applyForce(worldTirePos, tireOrientation.scaledBy(brakeForce));
					tire._isSkidding = true;
					tire._baseRadsPerSec = tire._extraRadsPerSec = 0;
					
					if ( tire.isDriven )
					{
						actualNumDrivenTires--;
					}
				}
				else
				{
					tire.rotation += (tire.radsPerSec * m_world.lastTimeStep);
				}
				
				//--- Figure out which rolling friction property of the tire to use.
				var tireRollingFriction:Number = 0;
				if ( pedal && brake)
				{
					tireRollingFriction = tire.getConfig().rollingFrictionWithBrakes * tire.getConfig().rollingFrictionWithThrottle;
				}
				else if ( pedal )
				{
					tireRollingFriction = tire.getConfig().rollingFrictionWithThrottle;
				}
				else if ( brake )
				{
					tireRollingFriction = tire.getConfig().rollingFrictionWithBrakes;
				}
				else
				{
					tireRollingFriction = tire.getConfig().rollingFrictionWhenCoasting;
				}
				
				//--- Apply the rolling friction with terrain modifier.
				tireRollingFriction = tireRollingFriction * rollingFrictionMultiplier;
				var rollingFrictionForce:Number = tire.massShare * (rollingFriction * -tireSpeedLong);
				rollingFrictionForce *= 1 - qb2U_Math.constrain(turn / maxTurnAngle, 0, 1);
				if ( rollingFrictionForce )
				{
					this.applyForce(worldTirePos, tireOrientation.scaledBy(rollingFrictionForce));
				}
				}
					
				if ( tire.isDriven && tranny )
				{
					avgRadsPerSec += tranny.calcRadsPerSecInv(tire.radsPerSec);
				}
				

				//--- Get the lateral component of the tire's speed and calc a force that negates it.
				dot = Math.abs(tireMovementDirection.dotProduct(tireSideways));
				dot = isNaN(dot) ? 1 : dot;  // just to be safe
				force = (tireSpeed * dot) * tireLoad;

				//--- If the force is greater than the friction opposition force, start skidding.
				if ( force > fricForce)
				{
					tire._isSkidding = true;
					force = fricForce;
				}
	
				//--- Apply lateral friction force.
				if ( force )
				{
					this.applyForce(worldTirePos, tireSideways.scaleByNumber(force * 1));
				}
				
				if ( highestTerrain && (highestTerrain is qb2Terrain) )
				{
					var highestTdTerrain:qb2Terrain = highestTerrain as qb2Terrain;
					
					var drawSliding:Boolean = highestTdTerrain.drawSlidingSkids && tire._isSkidding;
					var drawRolling:Boolean = highestTdTerrain.drawRollingSkids;
					
					if ( drawSliding || drawRolling )
					{
						var start:qb2GeoPoint = null, end:qb2GeoPoint = worldTirePos;
						
						if ( tire.lastWorldPos )
						{
							start = tire.lastWorldPos;
						}
						else
						{
							var translater:qb2GeoVector = linearVelocity.normal.scale( -worldPixelsPerMeter * world.lastTimeStep);
							
							if ( !translater.isNaNVec() )
								start = worldTirePos.translatedBy(linearVelocity.normal.scale( -worldPixelsPerMeter * world.lastTimeStep));
							else
								start = worldTirePos;
						}
						
						highestTdTerrain.addSkid(start, end, tire._width, drawSliding ? qb2Terrain.SKID_TYPE_SLIDING : qb2Terrain.SKID_TYPE_ROLLING);
					}
				}
				
				tire.lastWorldPos = worldTirePos;
			}
			
			//--- Feed average driven tire speed back into the engine, because it's all connected.
			if ( _engine)
			{
				_engine.setRadsPerSec(actualNumDrivenTires ? Math.abs(avgRadsPerSec / actualNumDrivenTires) : 0);
			}
		}
		
		/*public override function scale(xValue:Number, yValue:Number, origin:qb2GeoPoint = null, scaleMass:Boolean = true, scaleJointAnchors:Boolean = true, scaleActor:Boolean = true):qb2A_PhysicsObject
		{
			for (var i:int = 0; i < tires.length; i++) 
			{
				var tire:qb2CarTire = tires[i];
				tire.scale(xValue, yValue);
			}
			
			return super.scale(xValue, yValue, origin, scaleMass, scaleJointAnchors);
		}*/
		
		qb2_friend function registerContactTerrain(terrain:qb2Terrain):void
		{
			if ( !_contactTerrainDict )
			{
				_contactTerrainDict = new Dictionary(false);
				_contactTerrainDict[NUM_TERRAINS] = 0;
			}
			
			_contactTerrainDict[terrain] = true;
			_contactTerrainDict[NUM_TERRAINS]++;
		}
		
		qb2_friend function unregisterContactTerrain(terrain:qb2Terrain):void
		{
			delete _contactTerrainDict[terrain];
			_contactTerrainDict[NUM_TERRAINS]--;
			
			if ( _contactTerrainDict[NUM_TERRAINS] == 0 )
			{
				_contactTerrainDict = null;
			}
		}
		
		private static const NUM_TERRAINS:String = "numTerrains";
		
		private var _contactTerrainDict:Dictionary = null;

		public override function convertTo(T:Class):*
		{
			return "[qb2CarBody()]";
		}
		
		private function massPropsUpdated(evt:qb2MassEvent):void
		{
			calcTireShares();
		}
	}
}

class qb2InternalAxleLayout
{
	qb2_friend var avgLeft:Number = 0, avgRight:Number = 0, avgTop:Number = 0, avgBot:Number = 0;
	qb2_friend var numLeft:uint = 0, numRight:uint = 0, numTop:uint = 0, numBot:uint = 0;
}