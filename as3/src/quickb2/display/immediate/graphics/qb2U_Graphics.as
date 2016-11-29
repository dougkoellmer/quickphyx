package quickb2.display.immediate.graphics 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.qb2S_Math;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Graphics extends qb2UtilityClass
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint3:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector:qb2GeoVector = new qb2GeoVector();
		
		public static function drawEllipse(graphics:qb2I_GraphicsCommands, centerPoint:qb2I_DrawPoint, majorAxis:qb2I_DrawPoint, minorAxis:Number):void
		{
			s_utilVector.copy(majorAxis);
			var majorLength:Number = s_utilVector.calcLength();
			var minorLength:Number = minorAxis;
			
			var kappa:Number = 0.5522848; // 
			var offsetMajor:Number = majorLength * kappa;  // control point offset horizontal
			var offsetMinor:Number = minorLength * kappa;  // control point offset vertical

			s_utilPoint1.copy(centerPoint);
			graphics.getTransformStack().pushAndConcatTranslation(s_utilPoint1);
			var rotation:Number = qb2S_Math.X_AXIS.calcSignedAngleTo(s_utilVector);
			graphics.getTransformStack().pushAndConcatRotation(rotation);
			
			s_utilPoint1.set( -majorLength, 0);
			graphics.moveTo(s_utilPoint1);
			
			s_utilPoint1.set( -majorLength, -offsetMinor);
			s_utilPoint2.set( -offsetMajor, -minorLength);
			s_utilPoint3.set( 0, -minorLength);
			graphics.drawCubicCurveTo(s_utilPoint1, s_utilPoint2, s_utilPoint3);
			
			s_utilPoint1.set( offsetMajor, -minorLength);
			s_utilPoint2.set( majorLength, -offsetMinor);
			s_utilPoint3.set( majorLength, 0);
			graphics.drawCubicCurveTo(s_utilPoint1, s_utilPoint2, s_utilPoint3);
			
			s_utilPoint1.set( majorLength, offsetMinor);
			s_utilPoint2.set( offsetMajor, minorLength);
			s_utilPoint3.set( 0, minorLength);
			graphics.drawCubicCurveTo(s_utilPoint1, s_utilPoint2, s_utilPoint3);
			
			s_utilPoint1.set( -offsetMajor, minorLength);
			s_utilPoint2.set( -majorLength, offsetMinor);
			s_utilPoint3.set( -majorLength, 0);
			graphics.drawCubicCurveTo(s_utilPoint1, s_utilPoint2, s_utilPoint3);
			
			graphics.getTransformStack().pop();
			graphics.getTransformStack().pop();
		}
		
		//private static var closedSplineRatio:Number = .41414141414141;
		//private static const refVec:qb2GeoVector = new qb2GeoVector(0, -1);
		
		/*public function drawCubicSpline(startTangent:qb2GeoVector, endTangent:qb2GeoVector, points:Vector.<qb2GeoPoint>, doMoveTo:Boolean = true):void
		{
			if( doMoveTo )  this.moveTo(points[0]);
			
			var lineWidth:Number = .1;
			
			var startClone:qb2GeoVector = startTangent.clone() as qb2GeoVector;
			startClone.negate();
			var startPointClone:qb2GeoPoint = points[0].clone() as qb2GeoPoint;
			startPointClone.translate(startClone);
			points.unshift(startPointClone);
			var endPointClone:qb2GeoPoint = points[points.length - 1].clone() as qb2GeoPoint;
			endPointClone.translate(endTangent);
			points.push(endPointClone);
			
			for ( var i:int = 2; i < points.length-2; i++) 
			{
				var prevPrevPoint:qb2GeoPoint = points[ i >= 2 ? i - 2 : points.length + (i - 2) ];
				var ithPoint:qb2GeoPoint = points[i];
				var prevPoint:qb2GeoPoint = points[i > 0 ? i - 1 : points.length - 1];   
				var nextPoint:qb2GeoPoint = points[i < points.length-1 ? i + 1 : 0]; 
				var nextNextPoint:qb2GeoPoint = points[i < points.length - 2 ? i + 2 : (i + 2) % points.length]; 
				
				
				var prevVec:qb2GeoVector = prevPoint.minus(ithPoint);
				var nextVec:qb2GeoVector = nextPoint.minus(ithPoint);
				var ithAngle:Number = nextVec.calcClockwiseAngleTo(prevVec);
				var ithConcave:Boolean = ithAngle <= qb2S_Math.PI;
				var ithTangent:qb2GeoVector = nextVec.clone() as qb2GeoVector;
				ithTangent.rotate( ithAngle / 2);  ithTangent.setToPerpVector( -qb2U_Math.sign(ithAngle));
				
				
				
				var prevVec2:qb2GeoVector = ithPoint.minus(nextPoint);
				var nextVec2:qb2GeoVector = nextNextPoint.minus(nextPoint);
				var nextAngle:Number = nextVec2.calcClockwiseAngleTo(prevVec2);
				var nextConcave:Boolean = nextAngle <= qb2S_Math.PI;
				var nextTangent:qb2GeoVector = nextVec2.clone() as qb2GeoVector;
				nextTangent.rotate( nextAngle / 2);  nextTangent.setToPerpVector( -qb2U_Math.sign(nextAngle));
				
				//--- This is close enough visually to just draw a straight line...if we allow smaller angle differences then things can glitch out.
				if ( ithTangent.isCodirectionalTo(nextTangent, null) )
				{
					this.drawLineTo(nextPoint);
					continue;
				}
			
				
				//--- Find the vector bisecting the ith and next tangent lines.
				var angleDiff:Number = ithTangent.calcSignedAngleTo(nextTangent);
				var rot:Number = angleDiff / 2;
				
				var ithSegVec:qb2GeoVector = nextVec;
				ithSegVec.normalize();
				var midwayPoint:qb2GeoPoint = ithPoint.calcMidwayPoint(nextPoint);
				var splitterVec:qb2GeoVector = ithTangent.clone() as qb2GeoVector;
				splitterVec.rotate(rot);
				var ithEdge:qb2GeoLine = new qb2GeoLine(ithPoint, nextPoint);
				
				/*if ( nextTangent.angleTo(splitterVec) > RAD_90 )
				{
					nextTangent.negate();
					splitterVec.mirror(nextTangent);
				}
				
				var ithTangentLine:qb2GeoLine = new qb2GeoLine(ithPoint, ithPoint.clone().translate(ithTangent) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
				var nextTangentLine:qb2GeoLine = new qb2GeoLine(nextPoint, nextPoint.clone().translate(nextTangent) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
				var ghostVertex:qb2GeoPoint = new qb2GeoPoint();
				ithTangentLine.calcIsIntersecting(nextTangentLine, ghostVertex);
				
				
				
				if ( ithConcave == nextConcave )
				{
					var saveType:qb2E_GeoLineType = ithEdge.getLineType();
					ithEdge.setLineType(qb2E_GeoLineType.INFINITE);
					var distToEdge:Number = ithEdge.calcDistanceTo(ghostVertex);
					ithEdge.setLineType(saveType);
					
					midwayPoint.translate(ithSegVec.calcPerpVector(ithConcave ? -1 : 1).scale(distToEdge *closedSplineRatio, distToEdge *closedSplineRatio ) as qb2GeoVector);
					
					var vec1:qb2GeoVector = (splitterVec.clone() as qb2GeoVector);
					vec1.negate();
					var vec2:qb2GeoVector = splitterVec.clone().mirror(ithSegVec.convertTo(qb2GeoLine)) as qb2GeoVector;
					var mirroring:Boolean = false;
					var clockAngle:Number = vec2.calcClockwiseAngleTo(vec1);
					if ( clockAngle < qb2S_Math.PI && ithConcave || clockAngle >= qb2S_Math.PI && !ithConcave )
					{
						mirroring = true;
						vec1.mirror(ithSegVec.convertTo(qb2GeoLine));
						vec2.mirror(ithSegVec.convertTo(qb2GeoLine));
					}
					var hitLine1:qb2GeoLine = new qb2GeoLine(midwayPoint, midwayPoint.clone().translate(vec1) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
					var hitLine2:qb2GeoLine = new qb2GeoLine(midwayPoint, midwayPoint.clone().translate(vec2) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
					
					
					var controlIntPoint1:qb2GeoPoint = new qb2GeoPoint();
					var controlIntPoint2:qb2GeoPoint = new qb2GeoPoint();
					ithTangentLine.calcIsIntersecting(hitLine1, controlIntPoint1);
					nextTangentLine.calcIsIntersecting(hitLine2, controlIntPoint2);
					var anchor:qb2GeoPoint = controlIntPoint1.calcMidwayPoint(controlIntPoint2);
					
					//this.lineStyle(lineWidth, 0x00ff00);
					this.drawCurveTo(controlIntPoint1, anchor);
					this.drawCurveTo(controlIntPoint2, nextPoint);
				}
				else
				{
					splitterVec.mirror(ithSegVec.convertTo(qb2GeoLine));
					var hitLine:qb2GeoLine = new qb2GeoLine(midwayPoint, midwayPoint.clone().translate(splitterVec) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
					
					
					controlIntPoint1 = new qb2GeoPoint();
					controlIntPoint2 = new qb2GeoPoint();
					ithTangentLine.calcIsIntersecting(hitLine, controlIntPoint1);
					nextTangentLine.calcIsIntersecting(hitLine, controlIntPoint2);
					anchor = controlIntPoint1.calcMidwayPoint(controlIntPoint2);
					
					//this.lineStyle(lineWidth, 0xff0000);
					this.drawCurveTo(controlIntPoint1, anchor);
					this.drawCurveTo(controlIntPoint2, nextPoint);
				}
			}
		}
	
		/*public function drawClosedCubicSpline(points:Vector.<qb2GeoPoint>, drawSplineTangents:Boolean = false ):void
		{
			this.moveTo(points[0]);
			
			var lineWidth:Number = .1;
			
			var ithTangents:Vector.<qb2GeoVector> = new Vector.<qb2GeoVector>();
			
			var tracer:String = "";
			
			for ( var i:int = 0; i < points.length; i++) 
			{
				var prevPrevPoint:qb2GeoPoint = points[ i >= 2 ? i - 2 : points.length + (i - 2) ];
				var ithPoint:qb2GeoPoint = points[i];
				var prevPoint:qb2GeoPoint = points[i > 0 ? i - 1 : points.length - 1];   
				var nextPoint:qb2GeoPoint = points[i < points.length-1 ? i + 1 : 0]; 
				var nextNextPoint:qb2GeoPoint = points[i < points.length - 2 ? i + 2 : (i + 2) % points.length]; 
				
				
				
				/*var prevPrevVec:qb2GeoVector = prevPrevPoint.minus(prevPoint);
				var prevNextVec:qb2GeoVector = ithPoint.minus(prevPoint);
				var prevPrevAngle:Number = prevNextVec.calcClockwiseAngleTo(prevPrevVec);
				var prevTangent:qb2GeoVector = prevNextVec.rotatedBy(prevPrevAngle / 2).setToPerpVector( -qb2U_Math.sign(prevPrevAngle));
				
				
				
				var prevVec:qb2GeoVector = prevPoint.minus(ithPoint);
				var nextVec:qb2GeoVector = nextPoint.minus(ithPoint);
				var ithAngle:Number = nextVec.calcClockwiseAngleTo(prevVec);
				var ithConcave:Boolean = ithAngle <= qb2S_Math.PI;
				var ithTangent:qb2GeoVector = (nextVec.clone().rotate( ithAngle / 2) as qb2GeoVector).setToPerpVector( -qb2U_Math.sign(ithAngle));
				
				
				
				var prevVec2:qb2GeoVector = ithPoint.minus(nextPoint);
				var nextVec2:qb2GeoVector = nextNextPoint.minus(nextPoint);
				var nextAngle:Number = nextVec2.calcClockwiseAngleTo(prevVec2);
				var nextConcave:Boolean = nextAngle <= qb2S_Math.PI;
				var nextTangent:qb2GeoVector = (nextVec2.clone().rotate( nextAngle / 2) as qb2GeoVector).setToPerpVector( -qb2U_Math.sign(nextAngle));
				
				
				if ( ithAngle != 0 && ithTangent.calcClockwiseAngleTo(prevVec2) < ithTangent.calcClockwiseAngleTo(nextVec2) )
				{//trace("first violated", i, refVec1.calcClockwiseAngleTo(prevVec), refVec1.calcClockwiseAngleTo(nextVec) );
					//trace("VIO");
					//nextTangent.negate();
					//nextConcave = !nextConcave;
					
					//ithTangent.negate();
					//ithConcave = !ithConcave;
					
				}
				
				/*if ( nextAngle != 0 && nextTangent.calcClockwiseAngleTo(prevVec) > nextTangent.calcClockwiseAngleTo(nextVec) )
				{//trace("first violated", i, refVec1.calcClockwiseAngleTo(prevVec), refVec1.calcClockwiseAngleTo(nextVec) );
					//trace("VIO");
					ithTangent.negate();
					ithConcave = !ithConcave;
					
					//ithTangent.negate();
					//ithConcave = !ithConcave;
					
				}*/
				
				
				/*if ( prevPrevAngle != 0 && prevTangent.calcClockwiseAngleTo(prevVec) < prevTangent.calcClockwiseAngleTo(nextVec) )
				{//trace("first violated", i, refVec1.calcClockwiseAngleTo(prevVec), refVec1.calcClockwiseAngleTo(nextVec) );
					//trace("VIO");
					ithTangent.negate();
					ithConcave = !ithConcave;
					
					//ithTangent.negate();
					//ithConcave = !ithConcave;
					
				}
				
				
				
				
				
				
				
				
				
				var secondVio:Boolean = false;
				if ( nextAngle != 0 && nextTangent.calcClockwiseAngleTo(prevVec2) < nextTangent.calcClockwiseAngleTo(nextVec2) )
				{//trace("next violated", i);
					//nextTangent.negate();
					//nextConcave = !nextConcave;
					
					//secondVio = true;
				}
				
				
				//--- Find the vector bisecting the ith and next tangent lines.
				var angleDiff:Number = ithTangent.calcSignedAngleTo(nextTangent);
				var rot:Number = angleDiff / 2;
				
				var ithSegVec:qb2GeoVector = nextVec.normalize();
				var midwayPoint:qb2GeoPoint = ithPoint.calcMidwayPoint(nextPoint);
				var splitterVec:qb2GeoVector = ithTangent.clone().rotate(rot) as qb2GeoVector;
				var ithEdge:qb2GeoLine = new qb2GeoLine(ithPoint, nextPoint);
				
				/*if ( nextTangent.angleTo(splitterVec) > RAD_90 )
				{
					nextTangent.negate();
					splitterVec.mirror(nextTangent);
				}
				
				var ithTangentLine:qb2GeoLine = new qb2GeoLine(ithPoint, ithPoint.clone().translate(ithTangent) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
				var nextTangentLine:qb2GeoLine = new qb2GeoLine(nextPoint, nextPoint.clone().translate(nextTangent) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
				var ghostVertex:qb2GeoPoint = new qb2GeoPoint();
				ithTangentLine.calcIsIntersecting(nextTangentLine, ghostVertex);
				
				if ( drawSplineTangents  )
				{
					/*if ( firstVio && secondVio )
						this.lineStyle(lineWidth, 0x0000ff);
					else  if ( firstVio )
						this.lineStyle(lineWidth, 0xff0000);
					else if ( secondVio )
						this.lineStyle(lineWidth, 0x00ff00);
					else
						this.setLineStyle(lineWidth, 0xffffff);
						
					this.pushLineStyle(lineWidth, 0xFFFFFFFF);
					{
						ithEdge.draw(this);
					}
					this.popLineStyle();
					
					this.pushLineStyle(lineWidth, 0xFF0000FF);
					{
						splitterVec.draw(this, ghostVertex);
					}
					this.popLineStyle();
					
					this.pushLineStyle(lineWidth, 0x00FFFF00);
					{
						ithTangent.draw(this, ghostVertex);
					}
					this.popLineStyle();
					
					this.pushLineStyle(lineWidth, 0x00FF0000);
					{
						nextTangent.draw(this, ghostVertex);
					}
					this.popLineStyle();
				}
				
				
				
				//if( 
				
				tracer += i + "-" + ithConcave + "-" + nextConcave + " ";
				
				//if ( ithConcave ) insideConcave = true;
				//if ( !nextConcave ) insideConcave = false;
				
				if ( ithConcave == nextConcave )
				{
					var saveType:qb2E_GeoLineType = ithEdge.getLineType();
					ithEdge.setLineType(qb2E_GeoLineType.INFINITE);
					var distToEdge:Number = ithEdge.calcDistanceTo(ghostVertex);
					ithEdge.setLineType(saveType);
					
					midwayPoint.translate(ithSegVec.calcPerpVector(ithConcave ? -1 : 1).scale(distToEdge *closedSplineRatio, distToEdge *closedSplineRatio ) as qb2GeoVector);
					
					var vec1:qb2GeoVector = (splitterVec.clone() as qb2GeoVector);
					vec1.negate();
					var vec2:qb2GeoVector = splitterVec.clone().mirror(ithSegVec.convertTo(qb2GeoLine)) as qb2GeoVector;
					var mirroring:Boolean = false;
					var clockAngle:Number = vec2.calcClockwiseAngleTo(vec1);
					if ( clockAngle < qb2S_Math.PI && ithConcave || clockAngle >= qb2S_Math.PI && !ithConcave )
					{
						mirroring = true;
						vec1.mirror(ithSegVec.convertTo(qb2GeoLine));
						vec2.mirror(ithSegVec.convertTo(qb2GeoLine));
					}
					var hitLine1:qb2GeoLine = new qb2GeoLine(midwayPoint, midwayPoint.clone().translate(vec1) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
					var hitLine2:qb2GeoLine = new qb2GeoLine(midwayPoint, midwayPoint.clone().translate(vec2) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
					
					if ( drawSplineTangents  )
					{
						/*this.lineStyle(lineWidth, mirroring ? 0xff0000 : 0xffffff);
						hitLine1.asVector().draw(graphics, midwayPoint);
						hitLine2.asVector().draw(graphics, midwayPoint);
					
						this.moveTo(ithPoint);
					}
					
					var controlIntPoint1:qb2GeoPoint = new qb2GeoPoint();
					var controlIntPoint2:qb2GeoPoint = new qb2GeoPoint();
					var output:qb2GeoIntesectionOutput2d = qb2GeoIntesectionOutput2d.getInstance();
					ithTangentLine.calcIsIntersecting(hitLine1, controlIntPoint1);
					nextTangentLine.calcIsIntersecting(hitLine2, controlIntPoint2);
					var anchor:qb2GeoPoint = controlIntPoint1.calcMidwayPoint(controlIntPoint2);
					
					//this.lineStyle(lineWidth, 0x00ff00);
					this.drawCurveTo(controlIntPoint1, anchor);
					this.drawCurveTo(controlIntPoint2, nextPoint);
				}
				else
				{
					splitterVec.mirror(ithSegVec.convertTo(qb2GeoLine));
					var hitLine:qb2GeoLine = new qb2GeoLine(midwayPoint, midwayPoint.clone().translate(splitterVec) as qb2GeoPoint, qb2E_GeoLineType.INFINITE);
					
					/*if ( drawSplineTangents )
					{
						this.pushLineStyle(lineWidth, 0xFFFFFFFF);
						{
							splitterVec.draw(this, midwayPoint);
						}
						this.popLineStyle();
						
						this.moveTo(ithPoint);
					}
					
					controlIntPoint1 = new qb2GeoPoint();
					controlIntPoint2 = new qb2GeoPoint();
					ithTangentLine.calcIsIntersecting(hitLine, controlIntPoint1);
					nextTangentLine.calcIsIntersecting(hitLine, controlIntPoint2);
					anchor = controlIntPoint1.calcMidwayPoint(controlIntPoint2);
					
					//this.lineStyle(lineWidth, 0xff0000);
					this.drawCurveTo(controlIntPoint1, anchor);
					this.drawCurveTo(controlIntPoint2, nextPoint);
				}
				
				ithTangents.push(ithTangent);
			}
			
			//trace(tracer);
		}
		
		public function drawQuadraticSpline(points:Vector.<qb2GeoPoint>, startNormal:qb2GeoVector, proportionality:Number = .5, drawKnots:Boolean = false, vertexRadius:Number = 0):void
		{			
			if ( points.length < 2 )  return;
			
			moveTo(points[0]);
			var lastNormal:qb2GeoVector = startNormal.calcNormal();
			for (var i:int = 1; i < points.length; i++) 
			{
				var startAnchor:qb2GeoPoint = points[i - 1];
				var endAnchor:qb2GeoPoint = points[i];
				var scale:Number = endAnchor.calcDistanceTo(startAnchor) * proportionality;
				var control:qb2GeoPoint = startAnchor.clone().translate(lastNormal.scale(scale, scale) as qb2GeoVector) as qb2GeoPoint;
				drawCurveTo(control, endAnchor);
				
				if ( i < points.length - 1 )  lastNormal = endAnchor.minus(control).calcNormal();
			}
		}*/
	}
}