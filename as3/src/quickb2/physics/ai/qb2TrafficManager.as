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

package quickb2.physics.ai 
{
	import quickb2.math.general.*;
	import quickb2.math.geo.*;
	import flash.system.*;
	import flash.utils.*;
	import quickb2.event.*;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	import revent.MAKE_REVENT_MULTI_TYPE;
	import quickb2.event.qb2EventDispatcher;
	import quickb2.event.qb2EventMultiType;
	import TopDown.*;
	import TopDown.ai.brains.*;
	import TopDown.loaders.*;
	import TopDown.loaders.proxies.*;
	import TopDown.objects.*;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2TrafficManager extends qb2EventDispatcher
	{
		public const horizon:qb2GeoBoundingBox = new qb2GeoBoundingBox();
		
		public var killBuffer:Number = 100;
		
		public var maxNumCars:uint = 0;
		public var carSpawnChance:Number = .3;
		public var spawnInterval:Number = 1;
		
		public var startCarsAtSpeedLimit:Boolean = true;
		
		public var carSeeds:Array = null;
		public var brainSeeds:Array = null;
		
		public var flashLoader:qb2FlashLoader = null;
		
		public var removeBrainlessCars:Boolean = true;
		
		public var applicationDomain:ApplicationDomain = null;
		
		public var alternateContainer:qb2Group = null;
		
		private var cars:Dictionary = null;
		
		public function qb2TrafficManager()
		{
			
		}
		
		qb2_friend function setMap(aMap:qb2Map):void
		{
			cars = null;
			
			var multiType:qb2EventMultiType = MAKE_REVENT_MULTI_TYPE
			(
				qb2ContainerEvent.ADDED_OBJECT, qb2ContainerEvent.REMOVED_OBJECT, qb2ContainerEvent.DESCENDANT_ADDED_OBJECT, qb2ContainerEvent.DESCENDANT_REMOVED_OBJECT
			);
			
			if ( _map )
			{
				_map.removeEventListener(multiType, mapAddedOrRemovedSomething);
			}
			
			_map = aMap;
			
			if ( _map )
			{
				cars = new Dictionary(true);
				
				loadUpCarDict(_map);
				
				_map.addEventListener(multiType, mapAddedOrRemovedSomething, null, true);
			}
		}
		
		private function loadUpCarDict(container:qb2Group):void
		{
			cars = new Dictionary(true);
			
			var queue:Vector.<qb2A_PhysicsObject> = new Vector.<qb2A_PhysicsObject>();
			queue.unshift(container);
			
			while ( queue.length )
			{
				var object:qb2A_PhysicsObject = queue.shift();
				
				if ( !(object is qb2A_PhysicsObject) )  continue;
				
				var tang:qb2A_PhysicsObject = object as qb2A_PhysicsObject;
				
				if ( tang is qb2Group )
				{
					var container:qb2Group = tang as qb2Group;
					for ( var i:int = 0; i < container.numObjects; i++ )
					{
						queue.push(container.getObjectAt(i));
					}
				}
				else if ( tang is qb2CarBody )
				{
					cars[tang] = true;
				}
			}
		}
		
		public function get map():qb2Map
			{  return _map;  }
		qb2_friend var _map:qb2Map;
		
		private function mapAddedOrRemovedSomething(evt:qb2ContainerEvent):void
		{
			var object:qb2A_PhysicsObject = evt.child;
			if ( object is qb2CarBody )
			{
				if( evt.type == qb2ContainerEvent.ADDED_OBJECT || evt.type == qb2ContainerEvent.DESCENDANT_ADDED_OBJECT )
					cars[object] = true;
				else
					delete cars[object];
			}
			else if ( object is qb2Group )
			{
				loadUpCarDict(object as qb2Group);
			}
		}
		
		protected function makeRandomCar():qb2CarBody
		{
			if ( !carSeeds || !carSeeds.length )  return null;
			
			var seed:* = carSeeds[qb2U_Math.getRandInt(0, carSeeds.length - 1)];
			
			if ( seed is Class )
			{
				return makeCarFromInstance(new (seed as Class));
			}
			else if ( seed is String )
			{
				var classDef:Class = (applicationDomain ? applicationDomain.getDefinition(seed as String) : getDefinitionByName(seed as String)) as Class;
				return makeCarFromInstance(new classDef);
			}
			else if ( seed is qb2CarBody )
			{
				var clone:qb2CarBody = (seed as qb2CarBody).clone() as qb2CarBody;
				clone.linearVelocity.set();
				clone.angularVelocity = 0;
				
				return clone;
			}
			
			return null;
		}
		
		protected function makeCarFromInstance(instance:Object):qb2CarBody
		{
			if ( instance is qb2ProxyCarBody )
			{
				if ( flashLoader )
				{
					return flashLoader.loadObject(instance) as qb2CarBody;
				}
			}
			else if ( instance is qb2CarBody )
			{
				return instance as qb2CarBody;
			}
			
			return null;
		}
		
		protected function getCrossingTracks():Vector.<qb2Track>
		{
			var crossings:Vector.<qb2Track>;
			var viewCenter:qb2GeoPoint = horizon.center;
			var viewRadius:Number = Math.sqrt( horizon.width * horizon.width + horizon.height * horizon.height);

			var numObjects:int = map.numObjects;
			for (var i:int = 0; i < numObjects; i++) 
			{
				var ithTrack:qb2Track = map.getObjectAt(i) as qb2Track;
				
				if ( !ithTrack )  continue;
				
				//trace(ithTrack.lineRep.distanceToPoint(viewCenter), viewRadius);
				
				if ( ithTrack.lineRep.distanceToPoint(viewCenter) <= viewRadius )
				{
					if ( !crossings )
					{
						crossings = new Vector.<qb2Track>();
					}
					crossings.push(ithTrack);
				}
			}
			
			return crossings;
		}
		
		protected function isLocationFree(location:qb2GeoPoint):Boolean
		{
			for ( var key:* in cars )
			{
				var car:qb2CarBody = key as qb2CarBody;
				
				if ( !car )  continue;
				
				var boundBox:qb2GeoBoundingBox = car.getBoundBox(car.parent);
				
				if ( boundBox.containsPoint(location) )
				{
					return false;
				}
			}
			
			return true;
		}
		
		protected function makeTrackBrain():qb2TrackBrain
		{
			if ( brainSeeds && brainSeeds.length )
			{
				var index:int = qb2U_Math.getRandInt(0, brainSeeds.length - 1);
				
				var prototype:Object = brainSeeds[index];
				
				if ( prototype is Class )
				{
					return new (prototype as Class);
				}
				else if( prototype is qb2A_Brain )
				{
					return (prototype as qb2A_Brain).clone() as qb2TrackBrain;
				}
			}
			else
			{
				return makeDefaultTrackBrain();
			}
			
			return null;
		}
		
		protected function makeDefaultTrackBrain():qb2TrackBrain
		{
			var brain:qb2TrackBrain = new qb2TrackBrain();
			brain.aggression = 0;
			return brain;
		}
		
		qb2_friend function relay_update():void
			{  update();  }
		
		protected function update():void
		{
			var currCenter:qb2GeoPoint = horizon.center;
	
			var numTrackCars:uint = 0;
			for ( var key:* in cars )
			{
				var car:qb2CarBody = key as qb2CarBody;
				
				if ( !car )
				{
					trace("Huh?");
					continue;
				}
	
				if ( !car.brain && removeBrainlessCars || car.brain && (car.brain is qb2TrackBrain) && (car.brain as qb2TrackBrain).ignoreGod == false )
				{
					if ( !horizon.containsPoint(car.position, killBuffer) )
					{
						car.removeFromParent();
						continue;
					}
					
					numTrackCars++;
				}
			}//trace(numTrackCars);
			
			//--- Attempt to spawn a new car if we're below the max and chance favors it.
			if ( numTrackCars < maxNumCars && Math.random() <= carSpawnChance )
			{
				//--- Go through the tracks that cross the boundary of our view rect.
				var tracks:Vector.<qb2Track> = getCrossingTracks();
				
				if ( !tracks )  return;
				
				var track:qb2Track = tracks[qb2U_Math.getRandInt(0, tracks.length - 1)];
	
				//--- Skip this track if it spawned a car too recently.
				if ( map.world.clock - track.lastSpawnTime < spawnInterval )  return;

				var pos1:uint = horizon.getContainment(track.start);
				var pos2:uint = horizon.getContainment(track.end);
				
				if ( pos1 == qb2GeoBoundingBox.INSIDE && pos2 == qb2GeoBoundingBox.INSIDE )  return;

				var intPnts:Vector.<qb2GeoPoint>;
				var lines:Vector.<qb2GeoLine> = horizon.asLines();
				for ( var j:uint = 0; j < lines.length; j++ )
				{
					var intPoint:qb2GeoPoint = new qb2GeoPoint();
					
					if ( lines[j].intersectsLine(track.lineRep, intPoint, 0) )
					{
						if ( !intPnts )
						{
							intPnts = new Vector.<qb2GeoPoint>();
						}
						intPnts.push(intPoint);
					}
				}
			
				if ( !intPnts )  return;

				intPoint = intPnts[qb2U_Math.getRandInt(0, intPnts.length - 1)];
				
				//--- Avoid spawning a car on a dead-end.
				if ( !track.numBranches )  return;
				var distanceToStart:Number = track.start.distanceTo(intPoint);
				if ( distanceToStart > track.getDistanceToBranchAt(track.numBranches - 1) )  return;
				if ( distanceToStart < track.getDistanceToBranchAt(0) )
				{
					//trace("ererer");
					return;
				}
	
				//--- Avoid spawning cars on top of each other.
				if ( !isLocationFree(intPoint) )  return;

				var newCar:qb2CarBody = makeRandomCar();
				
				if ( !newCar )  return;
				
				var trackBrain:qb2TrackBrain = makeTrackBrain();
				trackBrain.currTrack = track;
				var trackDir:qb2GeoVector = track.lineRep.direction;
				
				var currDistanceOnTrack:Number = track.lineRep.getDistAtPoint(intPoint);
				//currDistanceOnTrack = qb2U_Math.constrain(currDistanceOnTrack, 0, track.length);
				
				trackBrain.currDistance = currDistanceOnTrack;
				newCar.addObject(trackBrain);
				
				newCar.position = intPoint;
				newCar.rotation = trackDir.angle;
				if( alternateContainer )
					alternateContainer.addObject(newCar);
				else
					_map.addObject(newCar);
					
				if ( startCarsAtSpeedLimit )
				{
					newCar.linearVelocity.copy(trackDir).scale(track.speedLimit);
				}

				track.lastSpawnTime = _map.world.clock;
			}
		}
	}
}