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

package quickb2.physics.ai.brains
{
	
	import quickb2.math.general.*;
	import quickb2.math.geo.*;
	import flash.display.*;
	import flash.utils.*;
	import quickb2.debugging.*;
	import quickb2.debugging.drawing.qb2S_DebugDraw;
	import quickb2.event.*;
	import quickb2.math.utils.qb2U_Math;
	import quickb2.display.immediate.style.qb2PSEUDOTYPE;
	import quickb2.display.immediate.style.qb2StyleOption;
	
	
	import quickb2.objects.ai.brains.configs.qb2TrackBrainConfig;
	import QuickB2.objects.ai.brains.qb2A_Brain;
	import quickb2.objects.ai.qb2Track;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	import quickb2.objects.extras.qb2U_Stock;
	
	import quickb2.drawing.qb2I_Graphics2d;
	import TopDown.*;
	import TopDown.ai.*;
	import TopDown.debugging.*;
	import TopDown.events.*;
	import TopDown.internals.*;
	import TopDown.objects.*;
	
	

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2TrackBrain extends qb2A_Brain
	{
		public static const PSEUDOTYPE_ANTENNA:qb2PSEUDOTYPE = new qb2PSEUDOTYPE();
		public static const PSEUDOTYPE_TETHER:qb2PSEUDOTYPE = new qb2PSEUDOTYPE();
		
		public function qb2TrackBrain(config:qb2TrackBrainConfig = null)
		{
			super();
			init(config);
		}
		
		private function init(config:qb2TrackBrainConfig):void
		{			
			setConfig(config ? config : (qb2TrackBrainConfig.useSharedInstanceByDefault ? qb2TrackBrainConfig.getInstance() : new qb2TrackBrainConfig()));
		}
		
		public function getConfig():qb2TrackBrainConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2TrackBrainConfig):void
		{
			m_config = config;
		}
		private var m_config:qb2TrackBrainConfig = null;
		
		public function getAggression():Number
			{  return m_aggression;  }
		public function setAggression(value:Number):void
			{  m_aggression = qb2U_Math.constrain(value, 0, 1);  }
		private var m_aggression:Number = 0;
		
		public function getTemper():Number
			{  return m_temper;  }
		public function setTemper(value:Number):void
			{  m_temper = qb2U_Math.constrain(value, 0, 1);  }
		private var m_temper:Number = .5;
		
		public function getCooldownRate():Number
			{  return m_cooldownRate;  }
		public function setCooldownRate(value:Number):void
			{  m_cooldownRate = value;  }
		private var m_cooldownRate:Number = .02;		
		
		private var history:Vector.<qb2Track> = new Vector.<qb2Track>();
		
		private var justGotHit:Boolean = false;
		
		public function getCurrentTrack():qb2Track
		{
			return _currTrack;
		}
		public function setCurrentTrack(track:qb2Track):void
		{
			clearHistory();
			_currTrack = track;
			unshiftHistory(_currTrack);
		}
		private var _currTrack:qb2Track = null;
		
		public var currDistance:Number = 0;
		private var _currPoint:qb2GeoPoint;
		
		private var _hasHost:Boolean = false;
		
		private static const antennaDict:Dictionary = new Dictionary(true);
		
		public override function clone(deep:Boolean = true):qb2A_PhysicsObject
		{
			var clone:qb2TrackBrain = super.clone(deep) as qb2TrackBrain;
			
			clone.m_temper = this.m_temper;
		
			clone.m_cooldownRate = this.m_cooldownRate;
			clone.m_aggression = this.m_aggression;
				
			clone.m_config.copy(this.m_config);
			
			clone.useAntenna = this.useAntenna;
			clone.antennaLength = this.antennaLength;
			
			return clone;
		}
		
		protected override function addedToHost():void
		{
			if ( !(host as qb2CarBody) )  return;
			
			host.addEventListener(qb2MassEvent.MASS_PROPS_CHANGED, geomChanged, null, true);
			host.addEventListener(qb2ContactEvent.CONTACT_STARTED, hostHit, null, true);
			_hasHost = true;
			
			refreshAntenna();
		}
		
		protected override function removedFromHost():void
		{
			if ( !(host is qb2CarBody) )  return;
			
			host.removeEventListener(qb2MassEvent.MASS_PROPS_CHANGED, geomChanged);
			host.removeEventListener(qb2ContactEvent.CONTACT_STARTED, hostHit);
			
			_hasHost = false;
			
			refreshAntenna();
		}
		
		protected override function addedToWorld():void
		{
			var currParent:qb2A_PhysicsObject = host;
			_map = null;
			
			while ( currParent )
			{
				if ( currParent is qb2Map )
				{
					_map = currParent as qb2Map;
					
					return;
				}
				
				currParent = currParent.parent;
			}
			
			clearHistory();
		}
		
		protected override function removedFromWorld():void
		{
			_map = null;
			_currTrack = null;
			_currPoint = null;
			clearHistory();
		}
		
		private var _map:qb2Map;
		
		
		private function hostHit(evt:qb2ContactEvent):void
		{
			if ( evt.localShape == _antenna || (_antenna is qb2A_PhysicsObjectContainer) && evt.localShape.isDescendantOf((_antenna as qb2A_PhysicsObjectContainer)) )
			{
				return;
			}
			var force:Number = 0;
			
			if ( evt.contactPoint )
			{
				var localPoint:qb2GeoPoint = host.calcLocalPoint(evt.contactPoint);
				force = evt.otherShape.getLinearVelocityAtPoint(localPoint).length;
			}
			
			var modForce:Number = qb2U_Math.constrain(force, minHitSpeed, maxHitSpeed);
			var ratio:Number = (modForce - minHitSpeed) / (maxHitSpeed - minHitSpeed);
			ratio *= _temper;
			
			_aggression += ratio;
		}
		
		protected override function update():void
		{
			if ( !_map )  return;
			
			var theHost:qb2A_SmartBody = host;
			var carPos:qb2GeoPoint = host.position;
			var asCar:qb2CarBody = host as qb2CarBody;
			
			if ( !asCar )  return;
			
			if ( !_currTrack || !_currTrack.map || _currTrack.map != _map )
			{
				clearHistory();
				
				_currTrack = autoSearchForTrack ? findClosestTrack() : null; // right now just a linear search...might be optimized in some way.
				
				if ( !_currTrack )  return;
				
				unshiftHistory(_currTrack);
				
				currDistance = this.distance;
			}
			
			_currPoint = _currPoint ? _currPoint : _currTrack.lineRep.getPointAtDist(currDistance);
			
			var carNorm:qb2GeoVector = theHost.getNormal();
			var axlePos:qb2GeoPoint  = turnAxis;
			var maxTurnAngle:Number = asCar.maxTurnAngle;
			
			var tetherVec:qb2GeoVector = _currPoint.minus(axlePos);
			var tetherLen:Number = tetherVec.length;
			
			var angle:Number;
			var count:uint = 0;
			
			movePoint();
			
			if ( _aggression )
			{
				aggression = _aggression - _cooldownRate * theHost.world.lastTimeStep;
			}
			
			//--- Adjust pedal based on aggression and the road's speed limit.
			var speedLimit:Number = _currTrack.speedLimit;
			var pedalRatio:Number = speedLimit ? qb2U_Math.constrain(asCar.kinematics.overallSpeed / (speedLimit + speedLimit * aggression), 0, 1) : 0;
			var pedal:Number = Math.sqrt(1 - pedalRatio);
			pedal += aggression;
			pedal = qb2U_Math.constrain(pedal, 0, 1);
			
			//--- Find angle ratio and adjust pedal based on turn angle...i.e. sharp turns have less pedal applied to them.
			angle = carNorm.signedAngleTo(tetherVec);
			angle = qb2U_Math.constrain(angle, -maxTurnAngle, maxTurnAngle);
			var angleRatio:Number = qb2U_Math.sign(angle) * Math.abs(angle) / maxTurnAngle;
			var pedalModifier:Number = angleRatio - _aggression;
			pedalModifier = qb2U_Math.constrain(pedalModifier, 0, 1);
			pedalModifier -= .5;
		//	pedalModifier = 1 - angleRatio;
			pedalModifier = qb2U_Math.constrain(pedalModifier, 0, 1);
			//pedal *= pedalModifier;
			
			//--- Find brake value.
			var stop:Boolean = false;
			var brakes:Number = contactCount ? 1 : 0;
			if ( _aggression > 1 - _temper )
			{
				brakes = 0;
			}
			
			pedal = brakes ? 0 : pedal;
			
			var brake:Number = 0;// qb2Car(theHost).getLatSpeed() / (qb2Car(theHost).getLatSpeed() + qb2Car(theHost).getLongSpeed());

			host.brainPort.NUMBER_PORT_1 = pedal;
			host.brainPort.NUMBER_PORT_2 = angleRatio * maxTurnAngle;
			host.brainPort.NUMBER_PORT_3 = brakes; 
			
			//trace(_aggression, angleRatio);
		}
		
		protected function getDistance():Number
		{
			var axlePos:qb2GeoPoint = turnAxis;
			var asLine:qb2GeoLine = _currTrack.lineRep;
			var closestPoint:qb2GeoPoint = asLine.closestPointTo(axlePos);
			var distToTrack:Number = closestPoint.distanceTo(axlePos);
			var tetherMax:Number = Math.min(tetherMaximum, tetherOffset);
			var availableDistance:Number = tetherMax - distToTrack;
			//trace("Avail", availableDistance);
			
			var distance:Number = asLine.point1.distanceTo(closestPoint);
			distance += availableDistance > 0 ? availableDistance : 0;
			distance = qb2U_Math.constrain(distance, 0, asLine.length);
			
			return distance;
		}
		
		protected function getTetherOffset():Number
		{
			var defaultValue:Number = (host as qb2CarBody).kinematics.longSpeed * tetherMultiplier;
			return qb2U_Math.constrain(defaultValue, tetherMinimum, tetherMaximum);
		}
		
		private function movePoint():void
		{
			var _currTrackLength:Number = _currTrack.length;
			
			//--- See if any branches are available for the next step.
			var branches:Vector.<qb2InternalTrackBranch> = _currTrack.branches;
			var nextDistance:Number = this.distance;
			
			var potentialBranches:Vector.<qb2InternalTrackBranch>;
			var freshBranches:Vector.<qb2InternalTrackBranch>;
			var lastBranchReached:Boolean = false;
			for (var k:int = 0; k < branches.length; k++) 
			{
				var branch:qb2InternalTrackBranch = branches[k];
				
				if ( branch.distance > currDistance && branch.distance <= nextDistance )
				{
					if ( !potentialBranches )
					{
						potentialBranches = new Vector.<qb2InternalTrackBranch>();
					}
					potentialBranches.push(branch);
					
					if ( history.indexOf(branch.track) < 0 )
					{
						if ( !freshBranches )
						{
							freshBranches = new Vector.<qb2InternalTrackBranch>();
						}
						freshBranches.push(branch);
					}
					
					if ( k == branches.length - 1 )
					{
						lastBranchReached = true;
					}
					else if ( avoidUTurns && k == branches.length - 2 )
					{
						if ( getIndexOnTrack(_currTrack, branch.track) == branch.track.numBranches-1 )
						{
							continue;
						}
						
						var possibleBranchBeforeU:qb2Track = branches[branches.length - 1].track
						var indexOn:int = getIndexOnTrack(_currTrack, possibleBranchBeforeU);
						
						if ( indexOn+1 == possibleBranchBeforeU.numBranches - 1 )
						{
							var possibleU:qb2Track = possibleBranchBeforeU.getBranchAt(indexOn+1);
							
							if ( possibleU.lineRep.isAntidirectionalTo(_currTrack.lineRep, parallelTolerance) )
							{
								lastBranchReached = true;
							}
						}
					}
				}
			}
			
			currDistance = nextDistance;
			
			if ( !potentialBranches )
			{
				//--- If there are no branches, just continue on our merry way.
				keepOnKeepinOn();
			}
			else
			{
				if ( lastBranchReached || freshBranches && Math.random() <= turnChance )
				{
					if ( lastBranchReached && !freshBranches )
					{
						freshBranches = potentialBranches;
					}
					
					//--- Here we're just taking a turn because fate decreed it to happen.  It might happen that every possible turn here is illegal
					//--- in which case we'll just ignore it and go on straight anyway.
					if ( avoidUTurns )
					{
						//--- Here we weed out any fresh branches that happen to be parallel, anti-directional,
						//--- and within a certain distance to a past track traversed.  This is done to prevent U-turns.
						var nonUTurnBranches:Vector.<qb2InternalTrackBranch>;
						for (var i:int = 0; i < freshBranches.length; i++) 
						{
							var freshBranch:qb2InternalTrackBranch = freshBranches[i];
							
							if ( !checkBranchAgainstHistory(freshBranch) )  continue;
							
							var freshTrackNumBranches:int = freshBranch.track.branches.length;
							var freshTrackIntPoint:qb2GeoPoint = new qb2GeoPoint();
							_currTrack.lineRep.intersectsLine(freshBranch.track.lineRep, freshTrackIntPoint);
							
							var wayOut:Boolean = true;
							
							var index:int = getIndexOnTrack(_currTrack, freshBranch.track);
							if ( index == freshBranch.track.numBranches - 1 )
							{
								wayOut = false; // track is a dead end.
							}
							else if( index == freshBranch.track.numBranches-2 )
							{
								possibleU = freshBranch.track.getBranchAt(index + 1);
								
								if ( possibleU.lineRep.isAntidirectionalTo(_currTrack.lineRep, parallelTolerance) )
								{
									wayOut = false;
								}
							}
							
							if ( wayOut )
							{
								if ( !nonUTurnBranches )
								{
									nonUTurnBranches = new Vector.<qb2InternalTrackBranch>();
								}
								
								nonUTurnBranches.push(freshBranch);
							}
						}
						
						//--- If all fresh branches were found to be u-turns, then we just keep going straight.
						if ( nonUTurnBranches )
						{
							changeTracks(nonUTurnBranches);
						}
						else
						{
							if ( lastBranchReached )
							{
								changeTracks(potentialBranches);
							}
							else
							{
								keepOnKeepinOn();
							}
						}
					}
					else
					{
						changeTracks(freshBranches);
					}
				}
				else
				{
					keepOnKeepinOn();
				}
			}
		}
		
		private function checkBranchAgainstHistory(branch:qb2InternalTrackBranch):Boolean
		{
			var nextTrack:qb2Track = branch.track;
			var nextTrackLineRep:qb2GeoLine = nextTrack.lineRep;
			
			var branchIntersection:qb2GeoPoint = null;
			
			for (var j:int = 1; j < history.length; j++)
			{
				var jthLineRep:qb2GeoLine = history[j].lineRep;
				
				var anti:Boolean = jthLineRep.isAntidirectionalTo(nextTrackLineRep, parallelTolerance);
				
				if ( anti  )
				{
					var jthMinusOneLineRep:qb2GeoLine = history[j - 1].lineRep;
					
					var historyIntersection:qb2GeoPoint = new qb2GeoPoint();
					if ( !jthLineRep.intersectsLine(jthMinusOneLineRep, historyIntersection) )
					{
						continue;
					}
					
					if ( !branchIntersection )
					{
						branchIntersection = new qb2GeoPoint();
						if ( !nextTrackLineRep.intersectsLine(_currTrack.lineRep, branchIntersection) )
						{
							continue;
						}
					}
					
					if ( historyIntersection.distanceTo(branchIntersection) <= uTurnDistance )
					{
						return false; // branch is not good because it forms a u-turn with a track in history.
					}
				}
			}
			
			return true;
		}
		
		private function keepOnKeepinOn():void
		{
			_currPoint = _currTrack.lineRep.getPointAtDist(currDistance);
		}
		
		private function changeTracks(availableBranches:Vector.<qb2InternalTrackBranch>):void
		{
			var nextIndex:int = qb2U_Math.getRandInt(0, availableBranches.length - 1);
			var nextBranch:qb2InternalTrackBranch = availableBranches[nextIndex];
			//var nextDistance:Number = currDistance + tetherInc;
			
			
			_currTrack = nextBranch.track;
			currDistance = this.distance;
			_currPoint = _currTrack.lineRep.getPointAtDist(currDistance);
			
			unshiftHistory(_currTrack);
		}
		
		private function unshiftHistory(track:qb2Track):void
		{
			history.unshift(track);
			
			track.addEventListener(qb2TrackEvent.TRACK_MOVED, trackChanged, null, true);
			track.addEventListener(qb2ContainerEvent.REMOVED_FROM_WORLD, trackChanged, null, true);
			
			if ( history.length > historyDepth )
			{
				var popped:qb2Track = history.pop();
				
				stopListening(popped);
			}
		}
		
		private function clearHistory():void
		{
			for (var i:int = 0; i < history.length; i++) 
			{
				stopListening(history[i]);
			}
			history.length = 0;
		}
		
		private function stopListening(track:qb2Track):void
		{
			track.removeEventListener(qb2TrackEvent.TRACK_MOVED, trackChanged);
			track.removeEventListener(qb2ContainerEvent.REMOVED_FROM_WORLD, trackChanged);
		}
		
		private function trackChanged(evt:qb2ContainerEvent):void
		{
			var track:qb2Track = evt.child as qb2Track;
			
			if ( !track )  return;
			
			stopListening(track);
			
			var index:int = history.indexOf(track);
			if ( index >= 0 )
			{
				history.splice(index, 1);
			}
		}
		
		private static function getDistanceOnTrack(testTrack:qb2Track, otherTrack:qb2Track):Number
		{
			var branches:Vector.<qb2InternalTrackBranch> = otherTrack.branches;
			for (var i:int = 0; i < branches.length; i++) 
			{
				if ( branches[i].track == testTrack )
				{
					return branches[i].distance;
				}
			}
			
			return 0;
		}
		
		private static function getIndexOnTrack(testTrack:qb2Track, otherTrack:qb2Track):int
		{
			var branches:Vector.<qb2InternalTrackBranch> = otherTrack.branches;
			for (var i:int = 0; i < branches.length; i++) 
			{
				if ( branches[i].track == testTrack )
				{
					return i;
				}
			}
			
			return -1;
		}
		
		public function get useAntenna():Boolean
			{  return _useAntenna;  }
		public function set useAntenna(bool:Boolean):void
		{
			_useAntenna = bool;
			
			refreshAntenna();
		}
		private var _useAntenna:Boolean = true;
		
		public function getAntennaLength():Number
			{  return m_antennaLength;  }
		public function setAntennaLength(value:Number):void
		{
			m_antennaLength = value;
			
			refreshAntenna();
		}
		private var m_antennaLength:Number = 50;
		
		public function getMinAntennaWidth():Number
			{  return _minAntennaWidth;  }
		public function setMinAntennaWidth(value:Number):void
		{
			_minAntennaWidth = value;
			
			refreshAntenna();
		}
		private var _minAntennaWidth:Number;
		
		public function getAntenna():qb2A_PhysicsObject
			{  return _antenna;  }
		private var _antenna:qb2A_PhysicsObject;
		
		protected function makeAntenna():qb2A_PhysicsObject
		{
			var bb:qb2GeoBoundingBox = host.getBoundBox(host);
			var bbWid:Number = bb.width;
			var wid:Number = bbWid < _minAntennaWidth ? _minAntennaWidth : bbWid;
			
			var tri:qb2Shape = qb2U_Stock.newIsoTriShape(bb.topCenter, wid, m_antennaLength, 0, 0);
			tri.turnFlagOff(qb2S_PhysicsProps.JOINS_IN_DEBUG_DRAWING | qb2S_PhysicsProps.IS_DEBUG_DRAGGABLE );
			
			return tri;
		}
		
		private function geomChanged(evt:qb2MassEvent):void
		{
			if ( !addingOrRemovingAntenna )
			{
				refreshAntenna();
			}
		}
		
		protected final function refreshAntenna():void
		{
			if ( _antenna && _antenna.parent == host )
			{
				addingOrRemovingAntenna = true;
				{
					delete antennaDict[_antenna];
					_antenna.removeFromParent();
				}
				addingOrRemovingAntenna = false;
				
				_antenna.removeEventListener(qb2ContactEvent.CONTACT_STARTED, antennaHit);
				_antenna.removeEventListener(qb2ContactEvent.CONTACT_ENDED, antennaHit);
				
				contactCount = 0;
				
				_antenna = null;
			}
			
			if ( _useAntenna && _hasHost )
			{
				addingOrRemovingAntenna = true;
				{
					_antenna = makeAntenna();
					antennaDict[_antenna] = true;
					_antenna.mass = 0;
					host.addObject(_antenna);
				}
				addingOrRemovingAntenna = false;
				
				_antenna.addEventListener(qb2ContactEvent.CONTACT_STARTED, antennaHit, null, true);
				_antenna.addEventListener(qb2ContactEvent.CONTACT_ENDED,   antennaHit, null, true);
				
				_antenna.isGhost = true;
			}
		}
		
		private var contactCount:int = 0;
		
		private function antennaHit(evt:qb2ContactEvent):void
		{
			if ( isAntenna(evt.otherShape) || evt.otherShape.mass == 0 )  return;
			
			if ( evt.type == qb2ContactEvent.CONTACT_STARTED )
			{
				contactCount++;
			}
			else
			{
				contactCount--;
			}
		}
		
		private function isAntenna(shape:qb2Shape):Boolean
		{
			if ( antennaDict[shape] )  return true;
			
			for ( var key:* in antennaDict )
			{
				var antenna:qb2A_PhysicsObject = key as qb2A_PhysicsObject;
				
				if ( !(antenna is qb2A_PhysicsObjectContainer) )  continue;
				
				if ( shape.isDescendantOf(antenna as qb2A_PhysicsObjectContainer) )
				{
					return true;
				}
			}
			
			return false;
		}
		
		private var addingOrRemovingAntenna:Boolean = false;
		
		//--- Right now just a linear algorithm...might be optimized in some way if you have an insane amount of roads.
		protected function findClosestTrack():qb2Track
		{
			var numObjects:int = _map.numObjects;
			var closestTrack:qb2Track = null;
			var closestDistance:Number = Number.MAX_VALUE;
			
			var carPos:qb2GeoPoint = host.position;
			
			for (var i:int = 0; i < numObjects; i++) 
			{
				var ithObject:qb2A_PhysicsObject = _map.getObjectAt(i);
				
				if ( !(ithObject is qb2Track) )  continue;
				
				var ithTrack:qb2Track = ithObject as qb2Track;
				var asLine:qb2GeoLine = ithTrack.lineRep;
				var distToTrack:Number = asLine.distanceToPoint(carPos);
				
				if ( distToTrack < closestDistance )
				{
					closestTrack    = ithTrack;
					closestDistance = distToTrack;
				}
			}
			
			return closestTrack;
		}
		
		protected function get turnAxis():qb2GeoPoint
		{
			var carNorm:qb2GeoVector = host.getNormal();
			var axlePos:qb2GeoPoint  = host.position.translatedBy(carNorm.scale( -(host as qb2CarBody).turnAxis));
			return axlePos;
		}
		
		public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			if ( _antenna && (qb2S_DebugDraw.flags & qb2F_DebugDrawOption.ANTENNAS) )
			{
				graphics.pushLineStyle();
				{
					graphics.pushFillColor(qb2S_DebugDraw.antennaColor | qb2S_DebugDraw.fillAlpha);
					{
						_antenna.draw(graphics);
					}
					graphics.popFillColor();
				}
				graphics.popLineStyle();
			}
			
			if ( qb2S_DebugDraw.flags & qb2F_DebugDrawOption.TRACK_TETHERS )
			{
				if ( !_currTrack || !_currPoint )  return;
			
				var carPos:qb2GeoPoint = host.position;
				var asCar:qb2CarBody = host as qb2CarBody;
				
				if ( !asCar )  return;
			
				
				var axlePos:qb2GeoPoint = turnAxis;
				var tetherVec:qb2GeoVector = _currPoint.minus(axlePos);
				graphics.pushLineStyle(qb2S_DebugDraw.tetherThickness, qb2S_DebugDraw.tetherColor & qb2S_DebugDraw.tetherAlpha);
				{
					tetherVec.draw(graphics, axlePos, 0, 0, 1);
				}
				graphics.popLineStyle();
			}
		}
	}
}