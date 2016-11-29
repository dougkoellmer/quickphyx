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
	import adobe.utils.CustomActions;
	import quickb2.event.qb2MathEvent;
	import quickb2.event.qb2TrackEvent;
	import quickb2.internals.qb2InternalTrackBranch;
	
	import quickb2.physics.core.qb2I_PhysicsObject;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.*;
	import flash.display.*;
	import quickb2.debugging.*;
	import quickb2.debugging.drawing.qb2S_DebugDraw;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.display.immediate.style.qb2PSEUDOTYPE;
	import quickb2.display.immediate.style.qb2StyleParam;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	
	import quickb2.event.qb2Event;
	
	

	[Event(name="trackMoved", type="TopDown.events.qb2TrackEvent")]

	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2Track extends qb2A_PhysicsObject
	{
		public static const PSEUDOTYPE_ARROW:qb2PSEUDOTYPE = new qb2PSEUDOTYPE();
		public static const ARROW_ARROWSIZE:qb2StyleParam = qb2GeoVector.ARROWSIZE;
		
		qb2_friend const branches:Vector.<qb2InternalTrackBranch> = new Vector.<qb2InternalTrackBranch>();
		
		//qb2_friend var newMethod();:Number = 0;
		
		private var m_curve:qb2A_GeoCurve = null;
		
		private var m_length:Number = 0;
		
		private var m_config:qb2TrackConfig = null;
		
		public function qb2Track(curve:qb2A_GeoCurve = null, config:qb2TrackConfig = null)
		{
			this.setCurve(curve);
			this.setConfig(config);
		}
		
		public function getCurve():qb2A_GeoCurve
		{
			return m_curve;
		}
		
		public function setCurve(curve:qb2A_GeoCurve):void
		{
			if ( m_curve )
			{
				m_curve.removeEventListener(qb2MathEvent.ENTITY_UPDATED, curveUpdated);
			}
			
			m_curve = curve;
			
			if ( m_curve )
			{
				m_curve.addEventListener(qb2MathEvent.ENTITY_UPDATED, curveUpdated, null, true);
				
				curveUpdated(null);
			}
		}
		
		private function curveUpdated(evt:qb2MathEvent):void
		{
			m_length = m_curve.calcLength();
			
			/*if ( _map )
			{
				_map.updateTrackBranches(this);
			}*/
			
			var event:qb2TrackEvent = qb2GlobalEventPool.checkOut(qb2TrackEvent.TRACK_MOVED) as qb2TrackEvent;
			event.m_track = this;
			this.dispatchEvent(event);
		}
		
		public function getConfig():qb2TrackConfig
		{
			return m_config;
		}
		public function setConfig(config:qb2TrackConfig):void
		{
			m_config = config;
		}
		
		
		public function getBranchCount():uint
			{  return branches.length;  }
			
		public function getBranchAt(index:uint):qb2Track
			{  return branches[index].track;  }
			
		qb2_friend function getDistanceToBranchAt(index:uint):Number
			{  return branches[index].distance;  }
		
		qb2_friend function addBranch(branch:qb2InternalTrackBranch):void
		{
			var inserted:Boolean = false;
			var numBranches:int = branches.length;
			for (var i:int = 0; i < numBranches; i++) 
			{
				if ( branch.distance < branches[i].distance)
				{
					branches.splice(i, 0, branch);
					inserted = true;
					break;
				}
			}
			
			if ( !inserted )
			{
				branches.push(branch);
			}
		}
		
		qb2_friend function clearBranches():void
		{
			//--- Most of the job here is actually clearing this branch from its branches' branch lists.
			var numBranches:int = branches.length;
			for (var i:int = 0; i < numBranches; i++) 
			{
				var branchTrack:qb2Track = branches[i].track;
				
				var otherBranchNumBranches:int = branchTrack.branches.length;
				for (var j:int = 0; j < otherBranchNumBranches; j++) 
				{
					var otherBranchBranch:qb2Track = branchTrack.branches[j].track;
					if ( otherBranchBranch == this )
					{
						branchTrack.branches.splice(j, 1);
						break; // should only be one instance of this track in the other track's branch list.
					}
				}
			}
			
			branches.length = 0;
		}
		
		public override function clone(deep:Boolean = true):qb2I_PhysicsObject
		{
			var newTrack:qb2Track = super.clone(deep) as qb2Track;
			
			newTrack.m_config.copy(this.m_config);
			
			return newTrack;
		}
		
		public override function draw(graphics:qb2I_Graphics2d):void
		{
			if ( m_curve )
			{
				m_curve.draw(graphics);
			}
		}
		
		/*public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			if ( !(qb2S_DebugDraw.flags & qb2F_DebugDrawOption.TRACKS) )
				return;
				
			graphics.pushLineStyle(qb2S_DebugDraw.trackThickness, qb2S_DebugDraw.trackColor | qb2S_DebugDraw.outlineAlpha);
			{
				draw(graphics);
			}
			graphics.popLineStyle();
		}*/
	}
}

internal class qb2InternalTrackBranch
{
	public var track:qb2Track;
	public var distance:Number;
}