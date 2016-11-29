package quickb2.physics.utils 
{
	import quickb2.math.geo.*;
	import flash.utils.*;
	import quickb2.lang.*
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2GeoLine;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2InternalLineIntersectionFinder
	{
		private static var utilPoint:qb2GeoPoint = new qb2GeoPoint();
		private static var utilLine:qb2GeoLine = new qb2GeoLine();
		private static var utilArray:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>();
		
		private static const INT_TOLERANCE:Number  = .00000001;
		private static const DIST_TOLERANCE:Number = .001;
		private static const INFINITE:Number = 1000000;
		
		qb2_friend static function intersectsLine(rootTang:qb2A_PhysicsObject, sliceLine:qb2GeoLine, outputPoints:Vector.<qb2GeoPoint> = null, orderPoints:Boolean = true):Boolean
		{
			/*var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(rootTang as qb2A_PhysicsObjectContainer);
			
			utilArray.length = 0;
			var infiniteBeg:qb2GeoPoint = sliceLine.lineType == qb2GeoLine.INFINITE ?
					sliceLine.point1.translatedBy(sliceLine.direction.negate().scale(INFINITE)) :
					sliceLine.point1;
					
			var distanceDict:Dictionary = outputPoints ? new Dictionary(true) : null;
			
			while ( traverser.hasNext )
			{
				var currObject:qb2A_PhysicsObject = traverser.next();
				
				if ( !(currObject is qb2Shape) )  continue;
				
				var localSliceLine:qb2GeoLine = currObject.m_parent && currObject != rootTang ?
						new qb2GeoLine(currObject.m_parent.calcLocalPoint(sliceLine.point1, rootTang), currObject.m_parent.calcLocalPoint(sliceLine.point2, rootTang), sliceLine.lineType) :
						sliceLine;
						
				utilArray.length = 0;
				
				if ( currObject as qb2PolygonShape )
				{
					//--- Compare slice line against each polygon edge to determine intersection.
					var asPoly:qb2PolygonShape = currObject as qb2PolygonShape;
					if ( asPoly.polygon.intersectsLine(localSliceLine, outputPoints ? utilArray : null, INT_TOLERANCE, DIST_TOLERANCE ) )
					{
						if ( !outputPoints )
						{
							return true;
						}
					}
				}
				else
				{
					var asCircle:qb2CircleShape = currObject as qb2CircleShape;
					var geoCircle:qb2GeoCircle = asCircle.asGeoCircle();
					if ( localSliceLine.intersectsCircle(geoCircle, outputPoints ? utilArray : null, INT_TOLERANCE) )
					{
						if ( !outputPoints )
						{
							return true;
						}
					}
				}
				
				for (var i:int = 0; i < utilArray.length; i++ )
				{
					var worldPoint:qb2GeoPoint = currObject.m_parent ? currObject.m_parent.calcWorldPoint(utilArray[i], rootTang.m_parent) : utilArray[i];
					worldPoint.userData = utilArray[i].userData;
					
					if ( orderPoints )
					{
						insertPointInOrder(worldPoint, outputPoints, distanceDict, infiniteBeg);
					}
					else
					{
						outputPoints.push(worldPoint);
					}
				}
			}
			
			if ( outputPoints && outputPoints.length )
			{
				return true;
			}
			else
			{
				return false;
			}*/
			
			return false;
		}
		
		qb2_friend static function insertPointInOrder(point:qb2GeoPoint, otherPoints:Vector.<qb2GeoPoint>, distanceDict:Dictionary, basePoint:qb2GeoPoint):qb2GeoPoint
		{
			var distance:Number = 0;
			if ( !distanceDict[point] )
			{
				distance = point.calcDistanceTo(basePoint);
				distanceDict[point] = distance;
			}
			else
			{
				distance = distanceDict[point] as Number;
			}
			
			var inserted:Boolean = false;
			for (var i:int = 0; i < otherPoints.length; i++) 
			{
				if ( distance < distanceDict[otherPoints[i]] )
				{
					otherPoints.splice(i, 0, point);
					inserted = true;
					break;
				}
			}
			
			if ( !inserted )
			{
				otherPoints.push(point);
			}
			
			return point;
		}
	}
}