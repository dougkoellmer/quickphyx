package quickb2.math.geo.curves 
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2GeoGeometryIterator;
	import quickb2.math.qb2A_MathEntity;
	import quickb2.utils.prop.qb2PropMap;
	
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	import quickb2.math.geo.qb2I_GeoHyperPlane;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.lang.operators.*;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2GeoCompositeCurve extends qb2A_GeoCurve
	{
		private static const s_utilLine:qb2GeoLine = new qb2GeoLine();
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		
		private const m_curves:Vector.<qb2A_GeoCurve> = new Vector.<qb2A_GeoCurve>();
		private var m_isClosed:Boolean = false;
		
		public function qb2GeoCompositeCurve(... curves)
		{
			for ( var i:int = 0; i < curves.length; i++ )
			{
				addCurve(curves[i]);
			}
		}
		
		protected final override function isContainer():Boolean
		{
			return true;
		}
		
		public override function getCurveType():qb2F_GeoCurveType
		{
			if ( isClosed() )
			{
				return qb2F_GeoCurveType.IS_CLOSED;
			}
			else
			{
				return null;
			}
		}
		
		public function setIsClosed(value:Boolean):void
		{
			var wasClosed:Boolean = this.isClosed();
			
			m_isClosed = value;
			
			if (wasClosed != this.isClosed() )
			{
				this.dispatchChangedEvent();
			}
		}
		
		public function isClosed():Boolean
		{
			return m_isClosed || hasClosedCurve();
		}
		
		protected override function onSubEntityChanged(entity:qb2A_MathEntity):void
		{
			var curve:qb2A_GeoCurve = entity as qb2A_GeoCurve;
			
			if ( qb2F_GeoCurveType.IS_CLOSED.overlaps(curve.getCurveType()) )
			{
				if ( this.m_curves.length > 1 )
				{
					qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_STATE, "Cannot contain more than one curve if one of the curves is closed.");
				}
			}
		}
		
		public function set(... curves):void
		{
			this.pushEventDispatchBlock();
			
			this.removeAllCurves();
			
			for ( var i:int = 0; i < curves.length; i++ )
			{
				this.addCurve(curves[i]);
			}
			
			this.popEventDispatchBlock();
		}
		
		public function getCurveCount():int
		{
			return m_curves.length;
		}
		
		private function onBeforeCurveAdded(curve:qb2A_GeoCurve):void
		{
			var newCurveIsClosed:Boolean = qb2F_GeoCurveType.IS_CLOSED.overlaps(curve.getCurveType());
			
			if ( this.hasClosedCurve() && newCurveIsClosed )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_STATE, "Already contains a closed curve.");
			}
			else if ( m_curves.length > 0 && newCurveIsClosed )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_STATE, "Already contains non-closed curves.");
			}
		}
		
		private function addCurve_private(curve:qb2A_GeoCurve):void
		{
			if ( curve == null )
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected curve to be non-null.");
			}
			
			onBeforeCurveAdded(curve);
			
			m_curves.push(curve);
			
			this.addEventListenerToSubEntity(curve, false);
		}
		
		public function addCurve(... curves):void
		{
			for ( var i:int = 0; i < curves.length; i++ )
			{
				var curve:qb2A_GeoCurve = curves[i];
				
				addCurve_private(curve);				
			}
			
			this.dispatchChangedEvent();
		}
		
		public function setCurveAt(index:uint, curve:qb2A_GeoCurve):void
		{
			this.removeEventListenerFromSubEntity(m_curves[index], false);
			
			onBeforeCurveAdded(curve);
			
			m_curves[index] = curve;
			
			this.addEventListenerToSubEntity(curve, true);
		}
			
		public function insertCurveAt(index:uint, curve:qb2A_GeoCurve):void
		{
			onBeforeCurveAdded(curve);
			
			m_curves.splice(index, 0, curve);
			
			this.addEventListenerToSubEntity(curve, true);
		}
		
		public function removeCurve(curve:qb2A_GeoCurve):void
		{
			removeCurveAt(m_curves.indexOf(curve));
		}
		
		public function removeCurveAt(index:int):void
		{
			var curve:qb2A_GeoCurve = m_curves.splice(index, 1)[0];
			
			this.removeEventListenerFromSubEntity(curve, true);
		}
		
		public function removeAllCurves():void
		{
			this.pushEventDispatchBlock();
			
			for ( var i:int = m_curves.length - 1; i >= 0; i-- )
			{
				this.removeCurveAt(i);
			}
			
			this.popEventDispatchBlock();
		}
		
		public function getCurveAt(index:int):qb2A_GeoCurve
		{
			return m_curves[index];
		}
		
		protected override function copy_protected(otherObject:*):void
		{
			var other:qb2GeoCompositeCurve = otherObject as qb2GeoCompositeCurve;
			if ( other != null )
			{
				this.m_isClosed = other.m_isClosed;
			}
		}
		
		public override function calcPointAtParam(param:Number, point_out:qb2GeoPoint):void
		{
			return this.calcPointAtDistance(this.calcLength() * param, point_out);
		}
		
		public override function calcPointAtDistance(distance:Number, point_out:qb2GeoPoint):void
		{
			var geoIterator:qb2GeoGeometryIterator = new qb2GeoGeometryIterator(this, qb2A_GeoCurve);
			
			qb2PU_CompositeCurve.calcPointAtDistance(geoIterator, distance, point_out);
		}
		
		public override function calcParamAtPoint(pointOnCurve:qb2GeoPoint):Number
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			
			return NaN;
		}
		
		public override function calcSubcurve(startParam:Number, endParam:Number):qb2A_GeoCurve
		{return null;
			/*var toReturn:qb2GeoPolyline;
			var point1:qb2GeoPoint = new qb2GeoPoint(), point2:qb2GeoPoint = new qb2GeoPoint();
			if ( getSubcurveHelper(pointOrDistStart, pointOrDistFinish, point1, point2) )
			{
				var index1:int = this.closestSegmentTo(point1);
				var index2:int = this.closestSegmentTo(point2);
				if ( index1 >= 0 && index2 >= 0 )
				{
					if ( index1 == index2 )
					{
						return lines[index1].getSubcurve(pointOrDistStart, pointOrDistFinish);
					}
					else if( index1 < index2 )
					{
						toReturn = new qb2GeoPolyline();
						toReturn.addVertex(point1);
						for( var i:int = index1; i < index2; i++ )
						{
							toReturn.addVertex(lines[i].point2.clone());
						}
						toReturn.addVertex(point2);
						
						var startLine:qb2GeoLine = lines[index1];
						var endLine:qb2GeoLine   = lines[index2];
					}
				}
			}
			return toReturn;*/
		}
		
		public override function clone():*
		{
			var curve:qb2GeoCompositeCurve = super.clone();
			
			for ( var i:int = 0; i < m_curves.length; i++ )
			{
				curve.addCurve(m_curves[i]);
			}
			
			return curve;
		}
		
		public override function flip():void
		{
			this.pushEventDispatchBlock();
			{
				m_curves.reverse();
				
				for ( var i:int = 0; i < m_curves.length; i++ )
				{
					m_curves[i].flip();
				}
			}
			this.popEventDispatchBlock();
		}
		
		public override function calcIsLinear(line_out_nullable:qb2GeoLine = null, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			var geoIterator:qb2GeoGeometryIterator = new qb2GeoGeometryIterator(this, qb2A_GeoCurve);
			
			return qb2PU_CompositeCurve.calcIsLinear(geoIterator, line_out_nullable, tolerance_nullable);
		}
		
		public override function calcLength():Number
		{
			var geoIterator:qb2GeoGeometryIterator = new qb2GeoGeometryIterator(this, qb2A_GeoCurve);
			
			return qb2PU_CompositeCurve.calcLength(geoIterator);
		}
		
		/*public override function calcSelfIntersection(outputPoints:Vector.<qb2GeoPoint> = null, stopAtFirstPointFound:Boolean = true, distanceTolerance:Number = 0, radianTolerance:Number = 0):Boolean
		{
			var intersecting:Boolean = false;
			var ithLine:qb2GeoLine = qb2_poolNew(qb2GeoLine);
			var jthLine:qb2GeoLine = qb2_poolNew(qb2GeoLine);
			
			var limit:int = m_curves.length;
			
			if ( m_isClosed && !this.areEndPointsOverlapped() )
			{
				limit++;
			}
			
			for( var i:int = 0; i < limit; i++ )
			{
				var ithPlusOnePoint:qb2GeoPoint = i == m_curves.length ? m_curves[0] : m_curves[i];
				
				ithLine.set(m_curves[i], ithPlusOnePoint);
				
				for( var j:int = i+1; j < limit; j++ )
				{
					var jthPlusOnePoint:qb2GeoPoint = j == m_curves.length ? m_curves[0] : m_curves[j];
					
					jthLine.set(m_curves[j], jthPlusOnePoint);
					
					var outputPoint:qb2GeoPoint = outputPoints ? new qb2GeoPoint() : null;
					if ( ithLine.intersectsLine(jthPlusOnePoint, outputPoint, distanceTolerance, radianTolerance) )
					{
						if ( outputPoints )
						{
							outputPoints.push(outputPoint);
						}
						
						intersecting = true;
						
						if ( stopAtFirstPointFound )  return true;
					}
				}
			}
			
			qb2_poolDelete(ithLine);
			qb2_poolDelete(jthLine);
			
			return intersecting;
		}*/

		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			var geoIterator:qb2GeoGeometryIterator = new qb2GeoGeometryIterator(this, qb2A_GeoCurve);
			for ( var curve:qb2A_GeoCurve; (curve = geoIterator.next()) != null; )
			{
				curve.draw(graphics, propertyMap_nullable);
			}
		}
		
		private function hasClosedCurve():Boolean
		{
			return m_curves.length > 0 && qb2F_GeoCurveType.IS_CLOSED.overlaps(m_curves[0].getCurveType());
		}
		
		protected override function nextGeometry(progress:int, T_extends_qb2A_GeoEntity:Class, progressOffset_out:qb2Integer):qb2A_GeoEntity
		{
			//--- DRK > We're not doing isKindOf check here because various subclasses of qb2A_GeoCurve can vary.
			//---		We're forcing the caller to explicitly demand "any type of curve".
			if ( T_extends_qb2A_GeoEntity === qb2A_GeoCurve )
			{
				//---DRK > NOTE: There might be recursion-related problems with using these static members, but none have cropped up yet, so using them for performance.
				var utilPoint1:qb2GeoPoint = new qb2GeoPoint();
				var utilPoint2:qb2GeoPoint = new qb2GeoPoint();
				var utilLine:qb2GeoLine = s_utilLine;
				
				var curveCountWithLines:int = m_curves.length * 2 - 1;
				var index:int = Math.floor(progress / 2);
				var currentCurve:qb2A_GeoCurve;
				
				if ( progress < curveCountWithLines )
				{
					currentCurve = m_curves[index];
					var nextCurve:qb2A_GeoCurve = index < m_curves.length - 1 ? m_curves[index + 1] : null;
						
					if ( progress % 2 == 0 )
					{
						if ( index < m_curves.length - 1 )
						{
							currentCurve.calcPointAtParam(1, utilPoint1);
							nextCurve.calcPointAtParam(0, utilPoint2);
							
							if ( utilPoint1.isEqualTo(utilPoint2, qb2GeoTolerance.EXACT) )
							{
								progressOffset_out.value++;
							}
						}
						
						return m_curves[index];
					}
					else
					{
						currentCurve.calcPointAtParam(1, utilPoint1);
						nextCurve.calcPointAtParam(0, utilPoint2);
						
						utilLine.set(utilPoint1, utilPoint2);
						
						return utilLine;
					}
				}
				else if ( progress == curveCountWithLines && curveCountWithLines > 0 && m_isClosed && !this.hasClosedCurve())
				{
					currentCurve = m_curves[index];
					currentCurve.calcPointAtParam(1, utilPoint1);
					m_curves[0].calcPointAtParam(0, utilPoint2);
					
					utilLine.set(utilPoint1, utilPoint2);
					
					if ( utilLine.calcLength() > 0 )
					{
						return utilLine;
					}
				}
			}
			
			return null;
		}
		
		protected override function nextDecomposition(progress:int):qb2A_GeoEntity
		{
			return progress < m_curves.length ? m_curves[progress] : null;
		}

		/*public override function convertTo(T:Class):*
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this, "curveCount", m_curves.length, "isClosed", isClosed());
			}
			
			return super.convertTo(T);
		}*/
	}
}