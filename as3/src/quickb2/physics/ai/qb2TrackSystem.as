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
	import quickb2.math.geo.*;
	import flash.display.*;
	import flash.utils.*;
	import quickb2.event.qb2ContainerEvent;
	
	import quickb2.objects.ai.qb2Track;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Group;
	
	import quickb2.drawing.qb2I_Graphics2d;
	import quickb2.qb2_friend;
	import TopDown.*;
	import TopDown.ai.*;
	import TopDown.internals.*;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2TrackSystem extends qb2Group
	{
		private const trackDict:Dictionary = new Dictionary(true);
		
		public function qb2TrackSystem():void
		{
			addEventListener(qb2ContainerEvent.ADDED_OBJECT,   justAddedObject, null, true);
			addEventListener(qb2ContainerEvent.REMOVED_OBJECT, justRemovedObject, null, true);
		}
		
		/*public function get trafficManager():qb2TrafficManager
			{  return _trafficManager;  }
		public function set trafficManager(manager:qb2TrafficManager):void
		{
			if ( _trafficManager )  _trafficManager.setMap(null);
			_trafficManager = manager;
			_trafficManager.setMap(this);
		}
		private var _trafficManager:qb2TrafficManager;*/
		
		protected override function update():void
		{
			super.update();
			
			if ( _trafficManager )  _trafficManager.relay_update();
		}
		
		private function justAddedObject(evt:qb2ContainerEvent):void
		{
			var object:qb2A_PhysicsObject = evt.child;
			
			if ( object is qb2Track )
			{
				var track:qb2Track = object as qb2Track;
				track._map = this;
				
				trackDict[track] = true;
				
				updateTrackBranches(track);
			}
		}
		
		private function justRemovedObject(evt:qb2ContainerEvent):void
		{
			var object:qb2A_PhysicsObject = evt.child;
			
			if ( object is qb2Track )
			{
				var track:qb2Track = object as qb2Track;
				track.clearBranches();
				track._map = null;
				
				delete trackDict[track];
			}
		}
		
		qb2_friend function updateTrackBranches(track:qb2Track):void
		{
			if ( !trackDict[track] )  return;
			
			track.clearBranches();
			
			for ( var key:* in trackDict ) 
			{
				var ithTrack:qb2Track = key as qb2Track;
				
				var trackLine:qb2GeoLine = track.lineRep;
				var ithTrackLine:qb2GeoLine = ithTrack.lineRep;
				
				var intPoint:qb2GeoPoint = new qb2GeoPoint();
				if ( trackLine.intersectsLine(ithTrackLine, intPoint) )
				{
					//--- Add the ith track to the input track's branches.
					var trackBranch:qb2InternalTrackBranch = new qb2InternalTrackBranch();
					trackBranch.track = ithTrack;
					trackBranch.distance = trackLine.getDistAtPoint(intPoint);
					track.addBranch(trackBranch);
					
					//--- Add the input track to the ith track's branches.
					trackBranch = new qb2InternalTrackBranch();
					trackBranch.track = track;
					trackBranch.distance = ithTrackLine.getDistAtPoint(intPoint);
					ithTrack.addBranch(trackBranch);
				}
			}
		}
	}
}