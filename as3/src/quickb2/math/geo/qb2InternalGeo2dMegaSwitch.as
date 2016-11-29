package quickb2.math.geo 
{
	import quickb2.lang.*
	
	import quickb2.debugging.logging.*;
	import quickb2.lang.operators.qb2_throw;
	import quickb2.math.enums.*;
	import quickb2.math.general.*;
	import quickb2.math.geo.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2GeoCircle;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.surfaces.*;
	import quickb2.math.utils.qb2U_Math;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2InternalgeoMegaSwitch
	{
		public static const INTERSECTION:int 	= 0;
		public static const DISTANCE:int 		= 1;
		public static const EQUALITY:int 		= 2;
		
		public static function process(entityA:qb2A_GeoEntity, entityB:qb2A_GeoEntity, output:*, tolerance:Number, pointEqualityMode:uint, calculationType:int):*
		{
			/*var idA:int = entityA.getEntityType();
			var idB:int = entityB.getEntityType();
			
			switch(idA)
			{
				//## BEGIN BoundBox
				case qb2E_geoType.BOUND_BOX:
				{
					var boundBoxA:qb2GeoBoundingBox = entityA as qb2GeoBoundingBox;
					
					switch(idB)
					{
						case qb2E_geoType.BOUND_BOX:
						{
							var boundBoxB:qb2GeoBoundingBox = entityB as qb2GeoBoundingBox;
							
							switch(calculationType)
							{
								case INTERSECTION:
								{
									//if ( includeEdges )
										return !(boundBoxA.getMin().getX() > boundBoxB.getMax().getX()+tolerance  || boundBoxA.getMax().getX() < boundBoxB.getMin().getX()-tolerance  || boundBoxA.getMin().getY() > boundBoxB.getMax().getY()+tolerance  || boundBoxA.getMax().getY() < boundBoxB.getMin().getY()-tolerance);
									//else
										//return !(this.m_min.m_x >= otherBox.m_max.m_x + tolerance || this.m_max.m_x <= otherBox.m_min.m_x - tolerance || this.m_min.m_y >= otherBox.m_max.m_y + tolerance || this.m_max.m_y <= otherBox.m_min.m_y - tolerance);
									break;
								}
								case DISTANCE:
								{
									break;
								}
								
								case EQUALITY:
								{
									return
										boundBoxA.getMin().isEqualTo(boundBoxB.getMin(), tolerance, pointEqualityMode) &&
										boundBoxA.getMax().isEqualTo(boundBoxB.getMax(), tolerance, pointEqualityMode);
								}
							}
								
							break;
						}
						
						case qb2E_geoType.BOUND_CIRCLE:
						{
							var boundCircleB:qb2GeoBoundingBall = entityB as qb2GeoBoundingBall;
							
							switch(calculationType)
							{
								case INTERSECTION:
								{
									var centerDist:Number = boundBoxA.calcDistanceTo(boundCircleB.getCenter());
									
									//if ( includeEdges )
										return centerDist <= boundCircleB.getRadius() + tolerance;
									//else
									//	return centerDist < pointRadius + tolerance;
									break;
								}
								
								case DISTANCE:
								{
									
									break;
								}
								
								case EQUALITY:
								{
									return
										boundBoxA.getMax().isEqualTo(boundBoxB.getMin(), tolerance, pointEqualityMode) &&
										qb2U_Math.equals(boundCircleB.getRadius, 0.0, tolerance) &&
										boundCircleB.getCenter().isEqualTo(boundBoxA.getMin(), tolerance, pointEqualityMode);
								}
							}
								
							
							break;
						}
						
						case qb2E_geoType.CIRCLE:
						{
							var circleB:qb2GeoCircle = entityB as qb2GeoCircle;
							
							switch(calculationType)
							{
								case INTERSECTION:
								{
									break;
								}
								
								case DISTANCE:
								{
									break;
								}
								
								case EQUALITY:
								{
									break;
								}
							}
							
							break;
						}
						
						case qb2E_geoType.GRID:
						{
							break;
						}
						
						case qb2E_geoType.LINE:
						{
							break;
						}
						case qb2E_geoType.POINT:
						{
							var pointB:qb2GeoPoint = entityB as qb2GeoPoint;
							
							switch(calculationType)
							{
								case INTERSECTION:
								{
									//return includeEdges ?
										return qb2U_Math.isWithin(pointB.m_x, boundBoxA.getMin().m_x, boundBoxA.getMax().m_x, tolerance)  && qb2U_Math.isWithin(pointB.m_y, boundBoxA.getMin().m_y, boundBoxA.getMax().m_y, tolerance);
										//qb2U_Math.isBetween(point.m_x, m_min.m_x, m_max.m_x, tolerance) && qb2U_Math.isBetween(point.m_y, m_min.m_y, m_max.m_y, tolerance);
								}
								
								case DISTANCE:
								{
									/*if ( containsPoint(point, 0, true) )  return 0;
			
									var smallestDist:Number = Infinity;
									var sides:Vector.<qb2GeoLine> = asLines();
									for ( var i:uint = 0; i < 4; i++ )
									{
										var distance:Number = sides[i].calcDistanceToPoint(point);
										if ( distance < smallestDist )
											smallestDist = distance;
									}
									return smallestDist;*/
									
									/*break;
								}
								
								case EQUALITY:
								{
									return boundBoxA.getMin().isEqualTo(pointB, tolerance, pointEqualityMode) && boundBoxA.getMax().isEqualTo(pointB, tolerance, pointEqualityMode);
								}
							}
							
							break;
						}
						case qb2E_geoType.POLYGON:
						{
							break;
						}
						case qb2E_geoType.POLYLINE:
						{
							break;
						}
						case qb2E_geoType.VECTOR:
						{
							break;
						}
					}
				}
				//## END BoundBox
				
				
				//## BEGIN BOUND CIRCLE
				case qb2E_geoType.BOUND_CIRCLE:
				{
					var boundCircleA:qb2GeoBoundingBall = entityA as qb2GeoBoundingBall;
					
					switch(idB)
					{
						
						default:
						{
							//calcIntersection(entityB, entityA, output, tolerance, pointEqualityMode);
							break;
						}
					}
					break;
				}
				
				case qb2E_geoType.CIRCLE:
				{
					//return calcIntersection(entityA.calcBoundingBall(), entityB, output, tolerance, pointEqualityMode);
					
					break;
				}
				
				case qb2E_geoType.GRID:
				{
					break;
				}
				
				case qb2E_geoType.LINE:
				{
					break;
				}
				case qb2E_geoType.POINT:
				{
					break;
				}
				case qb2E_geoType.POLYGON:
				{
					break;
				}
				case qb2E_geoType.POLYLINE:
				{
					//var numEdges:int = 
					break;
				}
				case qb2E_geoType.VECTOR:
				{
					return process((entityA as qb2GeoVector).convertTo(qb2GeoLine), entityB, output, tolerance, pointEqualityMode, calculationType);
					
					break;
				}
			}
			
			qb2_throw(new qb2Error(qb2E_ErrorCode.NOT_IMPLEMENTED));*/
		}
	}
}

/*
switch(calculationType)
{
	case INTERSECTION:
	{
		break;
	}
	
	case DISTANCE:
	{
		break;
	}
	
	case EQUALITY:
	{
		break;
	}
}

// polyline
public override function calcDistanceToPoint(point:qb2GeoPoint):Number
{
	var lowestDist:Number = Infinity;
	for ( var i:int = 0; i < lines.length; i++ )
	{
		var distance:Number = lines[i].distanceToPoint(point);
		if ( distance < lowestDist )
			lowestDist = distance;
	}
	return lowestDist;
}
if ( otherEntity as qb2GeoPolyline )
{
	var otherPoly:qb2GeoPolyline = otherEntity as qb2GeoPolyline;
	if ( otherPoly.numVertices != this.numVertices )  return false;
	
	for ( var i:int = 0; i < verts.length; i++ )
	{
		if ( !this.verts[i].equals(otherPoly.verts[i], tolerance, pointEqualityMode) )
		{
			return false;
		}
	}
}*/

/*
public function isTouchingPoint(point:qb2GeoPoint, tolerance:Number = 0, pointEqualityMode:uint = qb2E_GeoEqualityType.DISTANCE):Boolean
		{
			var distanceToInfinite:Number = calcDistanceToInfiniteLine(point);
	
			if ( m_lineType ==qb2E_GeoLineType.SEGMENT || m_lineType == RAY )
			{
				if ( m_point1.isEqualTo(point, tolerance, pointEqualityMode) )                                  return true;
				if( m_lineType ==qb2E_GeoLineType.SEGMENT && m_point2.isEqualTo(point, tolerance, pointEqualityMode) )  return true;
			}
			
			return calcDistanceTo(point) <= tolerance;
		}*/
		
		/**
		 * Determines if two lines intersect. Overlapping lines return false.
		 * @param otherLine The other line to check against.
		 * @param outputIntPoint Optional output for the intersection point. If non-null, intPnt's x and y will be modified by the function if the function returns true, otherwise it will be unmodified.
		 * @param distanceTolerance The distance, for example, that the end point of one line segment can be from another line segment and still return true for intersection.
		 * @param radianTolerance In the case of two infinite lines, this is the tolerance that determines whether they are parallel.  If they are not parallel, they intersect.
		 * @return Whether or not there is intersection between the two lines.
		 */
		/*public function isIntersectingOtherCurve(otherCurve:qb2A_GeoCurve, output:*, intersectionTolerance:Number = 0, radianTolerance:Number = 0 ):Boolean
		{
			var otherLine:qb2GeoLine = otherCurve as qb2GeoLine;
			
			if ( otherLine )
			{
				var pair:Object = intersectionHelper(otherLine);
				if ( pair )
				{
					var intersecting:Boolean = false;
					
					if ( m_lineType == qb2E_GeoLineType.SEGMENT && otherLine.m_lineType == qb2E_GeoLineType.SEGMENT && qb2U_Math.isWithin(pair.ua, 0, 1, intersectionTolerance) && qb2U_Math.isWithin(pair.ub, 0, 1, intersectionTolerance) )
						intersecting = true;
					else if ( m_lineType == qb2E_GeoLineType.RAY && otherLine.m_lineType == qb2E_GeoLineType.SEGMENT && pair.ua >= 0-intersectionTolerance && qb2U_Math.isWithin(pair.ub, 0, 1, intersectionTolerance) )
						intersecting = true;
					else if ( m_lineType == qb2E_GeoLineType.SEGMENT && otherLine.m_lineType == qb2E_GeoLineType.RAY && qb2U_Math.isWithin(pair.ua, 0, 1, intersectionTolerance) && pair.ub >= 0-intersectionTolerance )
						intersecting = true;
					else if ( m_lineType == qb2E_GeoLineType.RAY && otherLine.m_lineType == qb2E_GeoLineType.RAY && pair.ua >= 0-intersectionTolerance && pair.ub >= 0-intersectionTolerance )
						intersecting = true;
					else if ( m_lineType == qb2E_GeoLineType.SEGMENT && otherLine.m_lineType == qb2E_GeoLineType.INFINITE && qb2U_Math.isWithin(pair.ua, 0, 1, intersectionTolerance) )
						intersecting = true;
					else if ( m_lineType == qb2E_GeoLineType.INFINITE && otherLine.m_lineType == qb2E_GeoLineType.SEGMENT && qb2U_Math.isWithin(pair.ub, 0, 1, intersectionTolerance) )
						intersecting = true;
					else if ( m_lineType == qb2E_GeoLineType.RAY && otherLine.m_lineType == qb2E_GeoLineType.INFINITE && pair.ua >= 0-intersectionTolerance )
						intersecting = true;
					else if ( m_lineType == qb2E_GeoLineType.INFINITE && otherLine.m_lineType == qb2E_GeoLineType.RAY && pair.ub >= 0-intersectionTolerance )
						intersecting = true;
					else if ( m_lineType == qb2E_GeoLineType.INFINITE && otherLine.m_lineType == qb2E_GeoLineType.INFINITE && !this.isParallelTo(otherLine, radianTolerance) )
						intersecting = true;
					
					if ( intersecting )
					{
						if ( output )
						{
							var outputPoint:qb2GeoPoint = output as qb2GeoPoint;
							var outputArray:Vector.<qb2GeoPoint> = output as Vector.<qb2GeoPoint>();
							if ( outputPoint )
							{
								outputPoint.set(this.m_point1.m_x + pair.ua * (this.m_point2.m_x - this.m_point1.m_x), this.m_point1.m_y + pair.ua * (this.m_point2.m_y - this.m_point1.m_y));
							}
							else if ( outputArray )
							{
								outputArray.push(new qb2GeoPoint(this.m_point1.m_x + pair.ua * (this.m_point2.m_x - this.m_point1.m_x), this.m_point1.m_y + pair.ua * (this.m_point2.m_y - this.m_point1.m_y)));
							}
						}
						
						return true;
					}	
				}
			}
			
			var otherCircle:qb2GeoCircle = otherCurve as qb2GeoCircle;
			if ( otherCircle )
			{
				var lineDir:qb2GeoVector = this.calcDirection();
				var lineOrigin:qb2GeoPoint = this.calcMidpoint();
				
				var data:Object = linetoCircleIntersectionHelper(lineOrigin, lineDir, otherCircle.m_center, otherCircle.m_radius, intersectionTolerance);
				var numIntPoints:int = data.rootCount;
				var intersects:Boolean = numIntPoints > 0 ;
				var t:Array = data.t;
				
				if ( intersects && outputIntersectionPoints)
				{
					if ( m_lineType == qb2E_GeoLineType.INFINITE )
					{
						// nothing to do here.
					}
					else if ( m_lineType == qb2E_GeoLineType.RAY )
					{
						if (numIntPoints == 1)
						{
							if (t[0] < 0.0 )
							{
								numIntPoints = 0;
							}
						}
						else
						{
							if (t[1] < 0.0 )
							{
								numIntPoints = 0;
							}
							else if (t[0] < 0.0 )
							{
								numIntPoints = 1;
								t[0] = t[1];
							}
						}
					}
					else if ( m_lineType == qb2E_GeoLineType.SEGMENT )
					{
						var extent:Number = this.calcLength() / 2;
						
						if (numIntPoints == 1)
						{
							if (Math.abs(t[0]) > extent )
							{
								numIntPoints = 0;
							}
						}
						else
						{
							if (t[1] < -extent || t[0] > extent )
							{
								numIntPoints = 0;
							}
							else
							{
								if (t[1] <= extent )
								{
									if (t[0] < -extent )
									{
										numIntPoints = 1;
										t[0] = t[1];
									}
								}
								else
								{
									numIntPoints = (t[0] >= -extent ? 1 : 0);
								}
							}
						}
					}
					
					if ( outputIntersectionPoints )
					{
						for (var i:int = 0; i < numIntPoints; i++)
						{
							var point:qb2GeoPoint = lineOrigin.translatedBy(lineDir.scaledBy(t[i]));
							point.setUserData(qb2E_GeoIntersectionFlags.CURVE_TO_CURVE);
							outputIntersectionPoints.push(point);
						}
					}
				}
				
				return intersects;
			}
			
			return false;
		}
		
		private function linetoCircleIntersectionHelper(lineOrigin:qb2GeoPoint, lineDir:qb2GeoVector, circleCenter:qb2GeoPoint, circleRadius:Number, tol:Number):Object
		{
			var diff:qb2GeoVector = lineOrigin.minus(circleCenter);
			var a0:Number = diff.calcLengthSquared() - circleRadius * circleRadius;
			var a1:Number = lineDir.calcDotProduct(diff);
			var discr:Number = a1 * a1 - a0;
			
			var returnObj:Object = { };
			if ( discr > tol )
			{
				returnObj.rootCount = 2;
				discr = Math.sqrt(discr);
				returnObj.t = [ -a1 - discr, -a1 + discr];
			}
			else if ( discr < -tol )
			{
				returnObj.rootCount = 0;
			}
			else
			{
				returnObj.rootCount = 1;
				returnObj.t = [ -a1];
			}
			
			return returnObj;
			
			/*template <typename Real>
			bool IntrLine2Circle2<Real>::Find (const Vector2<Real>& origin,
				const Vector2<Real>& direction, const Vector2<Real>& center,
				Real radius, int& rootCount, Real t[2])
			{
				// Intersection of a the line P+t*D and the circle |X-C| = R.  The line
				// direction is unit length. The t value is a root to the quadratic
				// equation:
				//   0 = |t*D+P-C|^2 - R^2
				//     = t^2 + 2*Dot(D,P-C)*t + |P-C|^2-R^2
				//     = t^2 + 2*a1*t + a0
				// If two roots are returned, the order is T[0] < T[1].

				Vector2<Real> diff = origin - center;
				Real a0 = diff.SquaredLength() - radius*radius;
				Real a1 = direction.Dot(diff);
				Real discr = a1*a1 - a0;
				if (discr > Math<Real>::ZERO_TOLERANCE)
				{
					rootCount = 2;
					discr = Math<Real>::Sqrt(discr);
					t[0] = -a1 - discr;
					t[1] = -a1 + discr;
				}
				else if (discr < -Math<Real>::ZERO_TOLERANCE)
				{
					rootCount = 0;
				}
				else  // discr == 0
				{
					rootCount = 1;
					t[0] = -a1;
				}

				return rootCount != 0;
			}
		}
		
		/*public override function calcDistanceTo(entity:qb2GeoPoint, output:qb2GeoDistanceOutput2d = null):Number
		{
			var point1Dist:Number = m_point1.calcDistanceTo(point);
			var endDist:Number = m_point2.calcDistanceTo(point);
			var linDist:Number = calcDistanceToInfiniteLine(point);
			var point1ToPoint:qb2GeoVector = point.minus(m_point1);
			var endToPoint:qb2GeoVector = point.minus(m_point2);
			var lineVec:qb2GeoVector = asVector();
			
			if ( m_lineType == qb2E_GeoLineType.SEGMENT )
			{
				if ( lineVec.calcAngleTo(point1ToPoint) <= Math.PI / 2 && lineVec.negate().calcAngleTo(endToPoint) <= Math.PI / 2 )
					return linDist;
				else return Math.min(point1Dist, endDist);
			}
			else if ( m_lineType == qb2E_GeoLineType.RAY )
			{
				if ( lineVec.calcAngleTo(point1ToPoint) <= Math.PI / 2 )
					return linDist;
				else return point1Dist;
			}
			else if ( m_lineType == qb2E_GeoLineType.INFINITE )
				return linDist;
				
			return NaN;
		}
		
		public function calcClosestPointOnCurveTo(point:qb2GeoPoint):qb2GeoPoint
		{
			var point1Dist:Number = m_point1.calcDistanceTo(point);
			var angleBtwn:Number = asVector().calcAngleTo(point.minus(m_point1));
			
			if ( m_lineType == qb2E_GeoLineType.SEGMENT )
			{
				if ( angleBtwn <= Math.PI / 2 )
				{
					var distanceAlong:Number = Math.cos(angleBtwn) * point1Dist;
					return distanceAlong > calcLength() ? m_point2.clone() : calcPointAtDistance(distanceAlong);
				}
				else return m_point1.clone();
			}
			else if ( m_lineType == qb2E_GeoLineType.RAY )
			{
				if ( angleBtwn <= Math.PI / 2 )
				{
					distanceAlong = Math.cos(angleBtwn) * point1Dist;
					return calcPointAtDistance(distanceAlong);
				}
				else return m_point1.clone();
			}
			else if ( m_lineType == qb2E_GeoLineType.INFINITE )
			{
				if ( angleBtwn <= Math.PI / 2 )
					distanceAlong = Math.cos(angleBtwn) * point1Dist;
				else
					distanceAlong = -Math.cos(Math.PI-angleBtwn)*point1Dist
				return calcPointAtDistance(distanceAlong);
			}
			return null;
		}*/
		
		/*s
		public function calcDistanceToInfiniteLine(point:qb2GeoPoint):Number
		{
			var hyp:Number = point.calcDistanceTo(this.m_point1);
			var theta:Number = point.minus(m_point1).calcAngleTo(this.calcDirection());
			theta = theta > Math.PI / 2 ? Math.PI - theta : theta;
			var toReturn:Number = Math.sin(theta) * hyp;
			return isNaN(toReturn) ? 0 : toReturn;
		}
		*/
		
		/*
		public function intersectsLine(line:qb2GeoLine, outputPoints:Vector.<qb2GeoPoint>, intersectionTolerance:Number = 0, distanceToPointTolerance:Number = 0):Boolean
		{
			var numVerts:int = verts.length;
			for (var j:uint = 0; j < numVerts; j++) 
			{
				var edgeBeg:qb2GeoPoint = verts[j];
				var edgeEnd:qb2GeoPoint = verts[(j + 1) % numVerts];
				utilLine.set(edgeBeg, edgeEnd);
				
				if ( line.intersectsLine(utilLine, utilPoint, intersectionTolerance) )
				{
					if ( !outputPoints )
					{
						return true;
					}
					
					var newIntPoint:qb2GeoPoint = utilPoint.clone();
					outputPoints.push(newIntPoint);
					
					newIntPoint.userData = qb2E_GeoIntersectionFlags.CURVE_TO_CURVE;
					var intIndex:uint = j;
					
					//--- Determine if the slice line goes through a vertex or the "meat" of an edge.
					if ( newIntPoint.distanceTo(edgeBeg) < distanceToPointTolerance )
					{
						newIntPoint.userData |= qb2E_GeoIntersectionFlags.CURVE_TO_POINT;
					}
					else if ( newIntPoint.distanceTo(edgeEnd) < distanceToPointTolerance )
					{
						newIntPoint.userData |= qb2E_GeoIntersectionFlags.CURVE_TO_POINT;
						intIndex = ++j;
					}
					
					newIntPoint.userData |= intIndex << 16;
				}
			}
			
			return outputPoints && outputPoints.length;
		}
		
		public function equals(otherEntity:qb2A_GeoEntity, tolerance:Number = 0, pointEqualityMode:uint = qb2E_GeoEqualityType.DISTANCE):Boolean
		{
			if ( otherEntity is qb2GeoPolygon )
			{
				var otherPoly:qb2GeoPolygon = otherEntity as qb2GeoPolygon;
				if ( otherPoly.numVertices != this.numVertices )  return false;
				
				for ( var i:int = 0; i < verts.length; i++ )
				{
					if ( !this.verts[i].equals(otherPoly.verts[i], tolerance, pointEqualityMode) )
					{
						return false;
					}
				}
			}
			
			return true;
		}
		
		public function isOn(point:qb2GeoPoint, tolerance:Number = 0, pointEqualityMode:uint = qb2E_GeoEqualityType.DISTANCE):Boolean
		{
			
			for (var i:int = 0; i < verts.length; ++i)
			{
				var ithPnt:qb2GeoPoint = verts[i];
				var tX:Number = point.m_x - ithPnt.m_x;
				var tY:Number = point.m_y - ithPnt.m_y;
				var ithNormal:qb2GeoVector = calcNormalAt(i);
				var dot:Number = (-ithNormal.m_x * tX + -ithNormal.m_y * tY);
				if ( dot > 0.0 )
				{
					return false;
				}
			}
			
			return true;
		}*/