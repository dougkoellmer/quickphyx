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

package quickb2.physics.core.events 
{
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventType;
	
	import quickb2.physics.core.tangibles.qb2Contact;
	import quickb2.math.geo.*;
	import quickb2.lang.*
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.event.qb2I_EventDispatcher;
	
	/**
	 * Base class for contact events.  This class cannot be used directly.
	 * 
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_ContactEvent extends qb2Event
	{
		/*qb2_friend static const CONTACT_STARTED:qb2EventType	   = new qb2EventType("CONTACT_STARTED");
		qb2_friend static const CONTACT_ENDED:qb2EventType       = new qb2EventType("CONTACT_ENDED";
		qb2_friend static const PRE_SOLVE:qb2EventType           = new qb2EventType("PRE_SOLVE");
		qb2_friend static const POST_SOLVE:qb2EventType          = new qb2EventType("POST_SOLVE");
		qb2_friend static const SUB_CONTACT_STARTED:qb2EventType = new qb2EventType("SUB_CONTACT_STARTED");
		qb2_friend static const SUB_CONTACT_ENDED:qb2EventType   = new qb2EventType("SUB_CONTACT_ENDED");
		qb2_friend static const SUB_PRE_SOLVE:qb2EventType       = new qb2EventType("SUB_PRE_SOLVE");
		qb2_friend static const SUB_POST_SOLVE:qb2EventType      = new qb2EventType("SUB_POST_SOLVE");

		public static const ALL_EVENT_TYPES:qb2EventMultiType	   = new qb2EventMultiType
		(
			PRE_SOLVE,     POST_SOLVE,     CONTACT_STARTED,     CONTACT_ENDED,
			SUB_PRE_SOLVE, SUB_POST_SOLVE, SUB_CONTACT_STARTED, SUB_CONTACT_ENDED
		);
		
		public static const STARTED_TYPES:qb2EventMultiType      = new qb2EventMultiType( CONTACT_STARTED, SUB_CONTACT_STARTED );
		public static const ENDED_TYPES:qb2EventMultiType        = new qb2EventMultiType( CONTACT_ENDED,   SUB_CONTACT_ENDED   );
		public static const PRE_SOLVE_TYPES:qb2EventMultiType    = new qb2EventMultiType( PRE_SOLVE,       SUB_PRE_SOLVE       );
		public static const POST_SOLVE_TYPES:qb2EventMultiType   = new qb2EventMultiType( POST_SOLVE,      SUB_POST_SOLVE      );
		
		qb2_friend static const DOUBLED_ARRAY:Vector.<Array> = Vector.<Array>([STARTED_TYPES, ENDED_TYPES, PRE_SOLVE_TYPES, POST_SOLVE_TYPES]);
		*/
		
		private var m_contact:qb2Contact;
		
		public function qb2A_ContactEvent(type_nullable:qb2EventType = null)
		{
			super(type_nullable);
			
			include "../../../lang/macros/QB2_ABSTRACT_CLASS";
		}
		
		public function initialize(contact:qb2Contact):void
		{
			m_contact = contact;
		}
		
		
		
		/*public function getContactPoint():qb2GeoPoint
			{  refreshContactInfo();  return _contactPoint;  }
		qb2_friend var _contactPoint:qb2GeoPoint;
		
		public function getContactNormal():qb2GeoVector
			{  refreshContactInfo();  return _contactNormal;  }
		qb2_friend var _contactNormal:qb2GeoVector;
		
		public function getContactWidth():Number
			{  refreshContactInfo();  return _contactWidth;  }
		qb2_friend var _contactWidth:Number = 0;
		
		qb2_friend var m_world:qb2World = null;
		
		//private static const worldMani:b2WorldManifold = new b2WorldManifold();
		
		private function refreshContactInfo():void
		{
			//--- Get contact points and normals.
			/*var pixelsPerMeter:Number = m_world.getConfig().pixelsPerMeter;
			worldMani.points.length = 0;
			worldMani.normal = null;
			m_contactB2.GetWorldManifold(worldMani);
			var pnt:V2 = worldMani.GetPoint();
			var point:qb2GeoPoint = pnt && !isNaN(pnt.x) && !isNaN(pnt.y) ? new qb2GeoPoint(pnt.x * pixelsPerMeter, pnt.y * pixelsPerMeter) : null;
			var normal:qb2GeoVector = worldMani.normal && !isNaN(worldMani.normal.x) && !isNaN(worldMani.normal.y)? new qb2GeoVector(worldMani.normal.x, worldMani.normal.y) : null;
			var numPoints:int = m_contactB2.m_manifold.pointCount;
			var width:Number = 0;
			if ( numPoints > 1 )
			{
				var diffX:Number = worldMani.points[0].x - worldMani.points[1].x;
				var diffY:Number = worldMani.points[0].y - worldMani.points[1].y;
				width = Math.sqrt(diffX * diffX + diffY * diffY) * pixelsPerMeter;
			}
			
			_contactPoint  = point;
			_contactNormal = normal;
			_contactWidth  = width;
		}
		
		public function getNormalImpulse():Number
		{
			/*var mani:b2Manifold = m_contact.m_manifold;
			var manifoldPoints:Array = mani.points;
			
			if ( mani.pointCount == 1 )
			{
				return manifoldPoints[0].normalImpulse;
			}
			else if ( mani.pointCount == 2 )
			{
				return manifoldPoints[0].normalImpulse + manifoldPoints[1].normalImpulse;
			}
			else return 0;
		}
		
		public function get tangentImpulse():Number
		{
			/*var mani:b2Manifold = m_contactB2.m_manifold;
			var manifoldPoints:Array = mani.points;
			
			if ( mani.pointCount == 1 )
			{
				return manifoldPoints[0].tangentImpulse;
			}
			else if ( mani.pointCount == 2 )
			{
				return manifoldPoints[0].tangentImpulse + manifoldPoints[1].tangentImpulse;
			}
			else return 0;
		}
		
		public function disableContact():void
		{
			//checkForError();
			//m_contactB2.Disable();
		}
		public function enableContact():void
		{
			//checkForError();
			//m_contactB2.SetEnabled(true);
		}
		
		private function checkForError():void
		{
			if ( getType() != qb2ContactEvent.PRE_SOLVE && getType() != qb2SubContactEvent.SUB_PRE_SOLVE )
			{
				throw new Error();
			}
		}
			
		public function isEnabled():Boolean
		{
			return false;
			//return m_contactB2.IsEnabled();
		}
			
		public function isSolid():Boolean
		{
			return false;
			//return m_contactB2.IsSolid();
		}
			
		public function isTouching():Boolean
		{
			return false;
			//return m_contactB2.IsTouching();
		}
			
		public function isFrictionEnabled():Boolean
		{
			return false;
			//return !m_contactB2.frictionDisabled;
		}
			
		public function setIsFrictionEnabled(bool:Boolean):void
		{
			//m_contactB2.frictionDisabled = !bool;
		}*/
			
		protected override function clean():void
		{
			m_contact = null;
		}
	}
}