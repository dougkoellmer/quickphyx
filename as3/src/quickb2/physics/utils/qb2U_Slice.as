package quickb2.physics.utils 
{	
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2I_TangibleObject;
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2U_Slice extends qb2Util
	{
		private static var intPoints:Vector.<qb2GeoPoint>;
		private static const INFINITE:Number = 1000000;
		
		private static var utilPoint:qb2GeoPoint;
		private static var utilLine:qb2GeoLine;
		
		private static const INCOMING:String = "incoming";
		private static const OUTGOING:String = "outgoing";
		private static const INT_TOLERANCE:Number = .00000001;
		private static const DIST_TOLERANCE:Number = .001;
		
		private static var initialized:Boolean = false;
		
		private static function initialize():void
		{
			intPoints = new Vector.<qb2GeoPoint>();
			utilPoint = new qb2GeoPoint();
			utilLine  = new qb2GeoLine();
			
			initialized = true;
		}
		
		public static function slice(rootTang:qb2A_TangibleObject, sliceLine:qb2GeoLine, options:qb2F_SliceOption, outputPoints:Vector.<qb2GeoPoint>):Vector.<qb2I_TangibleObject>
		{
			/*if ( !initialized )
			{
				initialize();
			}
			
			var infiniteBeg:qb2GeoPoint = sliceLine.point1.translatedBy(sliceLine.direction.negate().scale(INFINITE));
			var distanceDict:Dictionary = new Dictionary(true); // stores point->point's distance from infiniteBeg
			var intDict:Dictionary = new Dictionary(true);  // stores point->point's intersection status, i.e. if it intersects an edge or a vertex.
			var toReturn:Vector.<qb2A_PhysicsObject> = new Vector.<qb2A_PhysicsObject>();
			
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(rootTang as qb2A_PhysicsObjectContainer, qb2A_PhysicsObject);
			
			var numBegPointIntersections:int = 0;
			for ( var currObject:qb2A_PhysicsObject; currObject = iterator.next(); )
			{
				//--- Proceed down tree and continue until we find a sliceable shape.
				//--- Ancestor containers of shapes that have IS_SLICEABLE turned off will cause the traverser to skip that branch.
				//--- This means that even if a shape itself at a leaf having IS_SLICEABLE on still won't be sliced.
				var asTang:qb2A_PhysicsObject = currObject as qb2A_PhysicsObject;
				if( !(asTang.getSliceFlags() & qb2E_SliceFlags.IS_SLICEABLE) )
				{
					iterator.skipNextBranch();
					iterator.next();
					continue;
				}
				if ( !(currObject as qb2Shape) )
				{
					continue;
				}
				
				//--- Find intersection points with the slice line.  Here we extend the beginning of the line by "infinite"
				//--- in order to know whether partial slices are entrances or exits.
				intPoints.length = 0;
				var localSliceLine:qb2GeoLine = currObject.m_parent ?
						new qb2GeoLine(currObject.m_parent.calcLocalPoint(sliceLine.point1, rootTang), currObject.m_parent.calcLocalPoint(sliceLine.point2, rootTang), sliceLine.lineType) :
						new qb2GeoLine(sliceLine.point1.clone(), sliceLine.point2.clone());
				var localSliceLineBeg:qb2GeoPoint = localSliceLine.point1.translatedBy(localSliceLine.direction.negate().scale(INFINITE));
				var localSliceLineInf:qb2GeoLine = new qb2GeoLine(localSliceLineBeg, localSliceLine.point2.clone(), localSliceLine.lineType);
				qb2InternalLineIntersectionFinder.intersectsLine(currObject as qb2A_PhysicsObject, localSliceLineInf, intPoints, true);
				
				//--- Search for doubled points and either remove them or correct their indeces.  This usually happens when a slice line encounters
				//--- an internal seqb2Geo of a polygon.  The seqb2Geo, in turn, is generally caused by a partial slice into a circle or polygon.
				if ( intPoints.length > 1 && (currObject as qb2PolygonShape) )
				{
					var verts:Vector.<qb2GeoPoint> = (currObject as qb2PolygonShape).polygon.verts;
					
					for (var m:int = 0; m < intPoints.length-1; m++) 
					{
						var mthPoint:qb2GeoPoint        = intPoints[m]
						var mthPlusOnePoint:qb2GeoPoint = intPoints[m + 1];
						
						//--- If the intersection points overlap...
						if ( mthPoint.equals(mthPlusOnePoint, DIST_TOLERANCE) )
						{
							//--- If the intersection points are both intersecting the same vertex, then remove the pair.
							if ( mthPoint.userData & qb2E_GeoIntersectionFlags.CURVE_TO_POINT && mthPlusOnePoint.userData & qb2E_GeoIntersectionFlags.CURVE_TO_POINT )
							{
								intPoints.splice(m, 2);
								m -= 2;
							}
							
							//--- Otherwise, make sure their "handedness" is correct...
							else
							{
								var polyIndex1:uint = mthPoint.userData >> 16;
								var polyIndex2:uint = mthPlusOnePoint.userData >> 16;
								var vert1:qb2GeoPoint = verts[polyIndex1];
								var vert2:qb2GeoPoint = verts[polyIndex2];
								var vector:qb2GeoVector = vert2.minus(vert1);
								var sliceLineVec:qb2GeoVector = localSliceLine.asVector();
								var angle:Number = vector.clockwiseAngleTo(sliceLineVec);
								
								if ( angle >= 0 && angle <= qb2S_Math.PI )
								{
									//--- Faster just to swap data rather than swapping places in the array...probably
									var tempUserData:uint = mthPoint.userData;
									mthPoint.userData = mthPlusOnePoint.userData;
									mthPlusOnePoint.userData = tempUserData;
								}
							}
						}
					}
				}
				
				//--- Set up some things for the following loop.
				var numPreviousPointsOffSliceLine:int = 0;
				var encounteredPointOnSliceLine:Boolean = false;
				var flagDict:Dictionary = new Dictionary(true);
				var newPoly:qb2PolygonShape = null;
				//var asPoly:qb2PolygonShape = currObject as qb2PolygonShape;
				
				for (var l:int = 0; l < intPoints.length; l++) 
				{
					var lthIntPoint:qb2GeoPoint = intPoints[l];
					var numIntPoints:int = 0;
					
					var lthIntFlags:uint = lthIntPoint.userData;
					var lthPlusOneIntFlags:uint = 0;
					
					flagDict[lthIntPoint] = lthIntFlags;
					
					//--- See if this int point is on the actual slice line (and not the infinite version), and then if it's an incoming or outgoing point.
					//--- Also see whether this slice will be a partial slice (numIntPoints==1) or a full slice (numIntPoints==2).
					if ( localSliceLine.isOn(lthIntPoint, DIST_TOLERANCE) )
					{
						if ( numPreviousPointsOffSliceLine % 2 == 0 || encounteredPointOnSliceLine || (lthIntFlags & qb2E_GeoIntersectionFlags.CURVE_TO_POINT) )
						{
							if ( l == intPoints.length - 1 )
							{
								numIntPoints = 1;
								lthIntPoint.userData = INCOMING;
							}
							else
							{
								numIntPoints = 2;
								lthPlusOneIntFlags = intPoints[l + 1].userData;
								flagDict[intPoints[l + 1]] = intPoints[l + 1].userData;
								lthIntPoint.userData    = INCOMING;
								intPoints[++l].userData = OUTGOING;
							}
						}
						else
						{
							numIntPoints = 1;
							lthIntPoint.userData = OUTGOING;
							numBegPointIntersections++;
						}
						
						encounteredPointOnSliceLine = true;
					}
					else
					{
						numPreviousPointsOffSliceLine++;
					}
					
					//--- If this is a partial slice (and this shape allows partial slices)...
					if ( numIntPoints == 1 && asTang.isSliceFlagOn(qb2E_SliceFlags.IS_PARTIALLY_SLICEABLE) )
					{
						//--- Add the entrance or exit intersection point to the output array (in order) if the caller so desires.
						if ( outputPoints )
						{
							var outputPoint:qb2GeoPoint = currObject.m_parent ? currObject.m_parent.calcWorldPoint(lthIntPoint, rootTang.m_parent) : lthIntPoint;
							outputPoint.userData = lthIntPoint.userData;
							qb2InternalLineIntersectionFinder.insertPointInOrder(outputPoint, outputPoints, distanceDict, infiniteBeg);
						}
						
						//--- Find the point that represents the penetration of this shape, either the beginning or end of the slice line in the shape's parent's coordinate space.
						var penetrationPoint:qb2GeoPoint = null;
						if ( lthIntPoint.userData == OUTGOING )
						{
							penetrationPoint = currObject.m_parent ? currObject.m_parent.calcLocalPoint(sliceLine.point1, rootTang.m_parent) : sliceLine.point1.clone();
						}
						else
						{
							penetrationPoint = currObject.m_parent ? currObject.m_parent.calcLocalPoint(sliceLine.point2, rootTang.m_parent) : sliceLine.point2.clone();
						}
						
						//--- Get a polygon representation, either by casting or by converting a circle to a polygon based on where the slice line hit the circle.
						if ( currObject as qb2CircleShape )
						{
							newPoly = newPoly ? newPoly : (currObject as qb2CircleShape).convertToPoly(false, true, -1, lthIntPoint);
						}
						else
						{
							newPoly = newPoly ? newPoly : currObject.clone() as qb2PolygonShape;
						}
						
						//--- If the slice line intersected a vertex of a polygon, or if currObject is a decomposed circle...
						if ( (currObject as qb2CircleShape) || (lthIntFlags & qb2E_GeoIntersectionFlags.CURVE_TO_POINT) )
						{
							var cornerIndex:int = lthIntFlags >> 16;
							var afterIndex:int  = cornerIndex == newPoly.numVertices - 1 ? 0 : cornerIndex + 1;
							var pinch:qb2GeoPoint = newPoly.getVertexAt(cornerIndex).clone();
							
							newPoly.insertVertexAt(afterIndex, penetrationPoint, pinch);
						}
						
						//--- Otherwise currObject is a polygon and the slice line intersected an edge (probably the most common case)...
						else
						{
							var edgeIndex:uint = lthIntFlags >> 16;
							newPoly.insertVertexAt(edgeIndex + 1, lthIntPoint.clone(), penetrationPoint, lthIntPoint.clone());
						}
						
						//--- Give the qb2PolygonShape::makeShapeB2() function a hint that there are pinches to clean up.
						newPoly._propertyMap[qb2S_PhysicsProps.SLICE_FLAGS] |= qb2E_SliceFlags.MIGHT_HAVE_PINCHES;
					}
					
					//--- This is a slice that goes all the way through a discrete portion of the shape (or the whole shape).
					else if( numIntPoints == 2 )
					{
						var localIntPoint1:qb2GeoPoint = lthIntPoint;
						var localIntPoint2:qb2GeoPoint = intPoints[l];
						
						//--- Add the intersection points in order to the coordinate space of the original slice line if user wants output.
						if ( outputPoints )
						{
							var outputPoint1:qb2GeoPoint = currObject.m_parent ? currObject.m_parent.calcWorldPoint(localIntPoint1, rootTang.m_parent) : localIntPoint1;
							var outputPoint2:qb2GeoPoint = currObject.m_parent ? currObject.m_parent.calcWorldPoint(localIntPoint2, rootTang.m_parent) : localIntPoint2;
							outputPoint1.userData = localIntPoint1.userData;
							outputPoint2.userData = localIntPoint2.userData;
							qb2InternalLineIntersectionFinder.insertPointInOrder(outputPoint1, outputPoints, distanceDict, infiniteBeg);
							qb2InternalLineIntersectionFinder.insertPointInOrder(outputPoint2, outputPoints, distanceDict, infiniteBeg);
						}
						
						//--- Circle case for two intersections is easy...just split a circle into two polygonized halves
						//--- based on where the slice line intersects the circle.
						if ( currObject as qb2CircleShape )
						{
							var asCircle:qb2CircleShape = currObject as qb2CircleShape;
							
							var vec1:qb2GeoVector = localIntPoint1.minus(asCircle.position);
							var vec2:qb2GeoVector = localIntPoint2.minus(asCircle.position);
							var vec1ToVec2:Number = vec1.clockwiseAngleTo(vec2);
							var vec2ToVec1:Number = (qb2S_Math.PI * 2) - vec1ToVec2;
							
							var poly1:qb2PolygonShape = polygonizeArc(asCircle, localIntPoint1, vec1ToVec2);
							var poly2:qb2PolygonShape = polygonizeArc(asCircle, localIntPoint2, vec2ToVec1);
							
							toReturn.push(poly1, poly2);
						}
						
						//--- Polygon case sucks because we have to keep track of all kinds of crap.
						else if ( currObject as qb2PolygonShape )
						{
							newPoly = newPoly ? newPoly : currObject.clone() as qb2PolygonShape;
							var utilArray:Vector.<qb2GeoPoint> = newPoly.asPoints();
							
							var index1:uint = lthIntFlags        >> 16;
							var index2:uint = lthPlusOneIntFlags >> 16;
							
							var index1IsVertexInt:Boolean = lthIntFlags        & qb2E_GeoIntersectionFlags.CURVE_TO_POINT ? true : false;
							var index2IsVertexInt:Boolean = lthPlusOneIntFlags & qb2E_GeoIntersectionFlags.CURVE_TO_POINT ? true : false;
							
							var newPolySlice:qb2PolygonShape = new qb2PolygonShape();
							newPolySlice.copyPropertiesAndFlags(newPoly);
							newPolySlice.userData = currObject;
							newPolySlice.position = newPoly.position.clone();
							toReturn.push(newPolySlice);
							
							var modIndex1:int = index1;
							var modIndex2:int = index2;
							
							var numVertsForNewPoly:int = utilArray.length;
							
							var flipPoints:Boolean = false;
							var numSteps:int = 0;
							
							//--- Iterate over the polygon's points, starting from the index of the first intersection point, until getting
							//--- to the index of the second intersection point.  If we encounter another intersection point (not these two),
							//--- then we have to flip the indeces of the intersection points.
							for (var i:int = modIndex1; i != modIndex2; i = (i+1) % numVertsForNewPoly ) 
							{
								for (var j:int = l+2; j < intPoints.length; j++) 
								{
									var jthIndex:uint = flagDict[intPoints[j]] ? flagDict[intPoints[j]] >> 16 : intPoints[j].userData >> 16;
									
									if ( jthIndex == i )
									{
										flipPoints = true;
										break;
									}
								}
								
								if ( flipPoints )
								{
									break;
								}
								
								numSteps++;
							}
							
							if ( !flipPoints && l == intPoints.length-2 )
							{
								if ( modIndex1 > modIndex2 )
								{
									flipPoints = true;
								}
							}
							
							if ( flipPoints )
							{
								var temp:int = modIndex1;
								modIndex1 = modIndex2;
								modIndex2 = temp;
								
								var tempPoint:qb2GeoPoint = localIntPoint1;
								localIntPoint1 = localIntPoint2;
								localIntPoint2 = tempPoint;
								
								var tempBool:Boolean = index1IsVertexInt;
								index1IsVertexInt = index2IsVertexInt;
								index2IsVertexInt = tempBool;
							}
		
							var count:int = (modIndex1 + 1) % numVertsForNewPoly;
							var offset:int = 0;
							
							if ( index1IsVertexInt )
							{
								newPolySlice.addVertex(utilArray[modIndex1].clone());
							}
							else
							{
								newPolySlice.addVertex(localIntPoint1.clone());
								newPoly.insertVertexAt((modIndex1 + 1) % numVertsForNewPoly, localIntPoint1.clone());
								offset++;
								//registerPolyEdit(asPoly, polyEdits, localIntPoint1.clone(),  );
							}
							
							while ( count != (modIndex2+1) % numVertsForNewPoly )
							{
								newPolySlice.addVertex(utilArray[count].clone());
								
								var removeIndex:int = (modIndex1 + 1 + offset) % newPoly.numVertices;
								newPoly.removeVertexAt(removeIndex);
								offset--;
								//registerPolyEdit(asPoly, polyEdits, null, count );
								
								count = (count+1) % numVertsForNewPoly;
							}
							
							if ( index2IsVertexInt )
							{
								newPoly.insertVertexAt((modIndex2+1+offset) % newPoly.numVertices, newPolySlice.getVertexAt(newPolySlice.numVertices-1).clone());
								//registerPolyEdit(asPoly, polyEdits, asPoly.getVertexAt(modIndex2), (modIndex2+1) % mod);
							}
							else
							{
								newPolySlice.addVertex(localIntPoint2.clone());
								newPoly.insertVertexAt((modIndex2+1+offset) % newPoly.numVertices, localIntPoint2.clone());
								//registerPolyEdit(asPoly, polyEdits, localIntPoint2.clone(), count );
							}
							
							newPolySlice.position = currObject.m_parent ? currObject.m_parent.calcWorldPoint((currObject as qb2I_RigidObject).position, rootTang.m_parent) : (currObject as qb2I_RigidObject).position.clone();
						
						}
					}
				}
				
				if ( intPoints.length )
				{
					if ( newPoly )
					{
						newPoly.userData = currObject;
						newPoly.position = currObject.m_parent ? currObject.m_parent.calcWorldPoint((currObject as qb2I_RigidObject).position, rootTang.m_parent) : (currObject as qb2I_RigidObject).position.clone();
						toReturn.push(newPoly);
					}
					
					if ( rootTang.m_parent && (currObject as qb2A_PhysicsObject).isSliceFlagOn(qb2E_SliceFlags.REPLACE_OBJECT_WITH_SLICES) )
					{
						currObject.removeFromParent();
					}
				}*/
				
				//--- Edits to the original polygon are accumlated throughtout the above loop and only processed here.
				//--- Polygons with CHANGES_OWN_GEOMETRY off won't have any changes accumulated in polyEdits.
				/*if ( polyEdits.length )
				{
					asPoly.pushEditSession();
					var offset:int = 0;
					for (var k:int = 0; k < polyEdits.length; k++) 
					{
						if ( polyEdits[k] is int )
						{
							asPoly.removeVertexAt(polyEdits[k] + offset);
							offset--;
						}
						else
						{
							asPoly.insertVertexAt(polyEdits[k].userData + offset, polyEdits[k]);
							polyEdits[k].userData = null;
							offset++;
						}
					}
					asPoly.popEditSession();
				}*/
				
				/*traverser.next();
			}
			
			//--- Add caps to the intersection points for the beg/end of the slice line, if needed.
			if ( outputPoints )
			{
				if ( sliceLine.lineType != qb2GeoLine.INFINITE )
				{
					var lineBeg:qb2GeoPoint = sliceLine.point1.clone();
					lineBeg.userData = numBegPointIntersections;
					outputPoints.unshift(lineBeg);
				}
				
				if ( sliceLine.lineType == qb2GeoLine.LINE_TYPE_SEGMENT )
				{
					outputPoints.push(sliceLine.point2.clone());
				}
			}
			
			if ( rootTang.m_parent && (currObject as qb2A_PhysicsObject).isSliceFlagOn(qb2E_SliceFlags.REPLACE_OBJECT_WITH_SLICES) )
			{
				rootTang.m_parent.pushEditSession();
				{
					for (var k:int = 0; k < toReturn.length; k++) 
					{
						rootTang.m_parent.addObject(toReturn[k]);
					}
				}
				rootTang.m_parent.popEditSession();
			}
			
			return toReturn;*/
			
			return null;
		}
		
		/*private static function registerPolyEdit(poly:qb2PolygonShape, editArray:Array, point:qb2GeoPoint, index:int):void
		{
			if ( !(poly.sliceFlags & qb2E_SliceFlags.CHANGES_OWN_GEOMETRY) )  return;
			
			var inserted:Boolean = false;
			if ( point )
			{
				point.userData = index;
			}
			
			for (var i:int = 0; i < editArray.length; i++) 
			{
				var ithIndex:int = editArray[i] is int ? editArray[i] as int : (editArray[i] as qb2GeoPoint).userData as int;
				
				if ( index < ithIndex )
				{
					editArray.splice(i, 0, point ? point : index);
					inserted = true;
					break;
				}
			}
			
			if ( !inserted )
			{
				editArray.push(point ? point : index);
			}
		}*/
		
		/*private static function polygonizeArc(circleShape:qb2CircleShape, startPoint:qb2GeoPoint, sweepAngle:Number):qb2PolygonShape
		{
			var circum:Number = circleShape.perimeter;
			var ratio:Number = sweepAngle / (qb2S_Math.PI * 2);
			var arcLength:Number = ratio * circum;
			
			const min:int = 2;
			var approx:Number = circleShape.arcApproximation;
			var numSegs:int = Math.max(arcLength / approx, min);
			var angInc:Number = (qb2S_Math.PI * 2) * ((arcLength / (numSegs as Number)) / circum);
			
			var poly:qb2PolygonShape = new qb2PolygonShape();
			poly.addVertex(startPoint.clone() );
			var rotPoint:qb2GeoPoint = startPoint.clone();
			for (var i:int = 0; i < numSegs; i++) 
			{
				poly.addVertex(rotPoint.rotate(angInc, circleShape.position).clone());
			}
			
			poly.copyTangibleProps(circleShape, false);
			poly.density = circleShape.density;
			poly.copyPropertiesAndFlags(circleShape);
			poly.position = circleShape.m_parent ? circleShape.m_parent.calcWorldPoint(circleShape.position, traverser.getRoot() as qb2A_PhysicsObject) : circleShape.position.clone();
			poly.userData = circleShape;
			
			return poly;
		}*/
	}
}