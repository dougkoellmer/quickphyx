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

package quickb2.math.geo.curves
{
	import quickb2.lang.errors.*;
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.event.qb2Event;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	import quickb2.math.geo.qb2PU_Geo;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoCurveBoundedPlane;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoPlanarSurface;
	import quickb2.math.geo.surfaces.planar.qb2GeoCircularDisk;
	import quickb2.math.geo.surfaces.planar.qb2GeoCurveBoundedPlane;
	import quickb2.math.qb2U_Formula;
	
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	
	
	import quickb2.lang.types.*;

	[qb2_abstract] public class qb2A_GeoCurve extends qb2A_GeoEntity
	{
		public function qb2A_GeoCurve()
		{
			super();
			
			include "../../../lang/macros/QB2_ABSTRACT_CLASS";
		}
		
		[qb2_abstract] public function calcArea(startParam:Number, endParam:Number):Number
		{
			include "../../../lang/macros/QB2_ABSTRACT_METHOD";
			
			return NaN;
		}
		
		[qb2_abstract] public function calcPointAtParam(param:Number, point_out:qb2GeoPoint):void
		{
			include "../../../lang/macros/QB2_ABSTRACT_METHOD";
		}
		
		[qb2_abstract] public function calcParamAtPoint(point:qb2GeoPoint):Number
		{
			include "../../../lang/macros/QB2_ABSTRACT_METHOD";
			return NaN;
		}
		
		[qb2_abstract] public function calcNormalAtParam(param:Number, vector_out:qb2GeoVector, normalizeVector:Boolean):void
		{
			include "../../../lang/macros/QB2_ABSTRACT_METHOD";
		}
		
		[qb2_abstract] protected function calcSimpleMomentOfInertia(mass:Number, curveThickness:Number = 0 ):Number
		{
			return NaN;
		}
		
		public override function calcMomentOfInertia(mass:Number, axis_nullable:qb2I_GeoHyperAxis = null, centerOfMass_out_nullable:qb2GeoPoint = null):Number
		{
			var centerOfMassInertia:Number = this.calcSimpleMomentOfInertia(mass);
			
			return qb2PU_Geo.calcMomentOfInertia2d(this, centerOfMassInertia, mass, axis_nullable, centerOfMass_out_nullable);
		}
		
		private function calcParam(distance:Number):Number
		{
			var length:Number = this.calcLength();
			
			var param:Number = length == 0 ? 0 : distance / length;
			
			return param;
		}
		
		public function calcPointAtDistance(distance:Number, point_out:qb2GeoPoint):void
		{
			return this.calcPointAtParam(calcParam(distance), point_out);
		}
		
		public function calcNormalAtDistance(distance:Number, vector_out:qb2GeoVector, normalizeVector:Boolean):void
		{
			return this.calcNormalAtParam(calcParam(distance), vector_out, normalizeVector);
		}
		
		public function calcDistanceAtPoint(pointOnCurve:qb2GeoPoint):Number
		{
			return this.calcParamAtPoint(pointOnCurve) * this.calcLength();
		}
		
		[qb2_abstract] public function calcSubcurve(startParam:Number, endParam:Number):qb2A_GeoCurve
		{
			include "../../../lang/macros/QB2_ABSTRACT_METHOD";
			
			return null;
		}
		
		[qb2_abstract] public function flip():void
		{
			include "../../../lang/macros/QB2_ABSTRACT_METHOD";
		}
		
		public function calcIsLinear(line_out_nullable:qb2GeoLine = null, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			return false;
		}
		
		[qb2_abstract] public function calcLength():Number
		{
			include "../../../lang/macros/QB2_ABSTRACT_METHOD";
			
			return NaN;
		}

		[qb2_abstract] public function getCurveType():qb2F_GeoCurveType
		{
			include "../../../lang/macros/QB2_ABSTRACT_METHOD";
			return null;
		}
		
		protected final function calcSubcurveHelper(outCurve:qb2A_GeoCurve, T_extends_qb2A_GeoCurve:Class):*
		{
			var outCurveCast:qb2A_GeoCurve = (outCurve as T_extends_qb2A_GeoCurve) as qb2A_GeoCurve;
			
			if ( outCurveCast == null )
			{
				var outCompositeCurve:qb2GeoCompositeCurve = outCurve as qb2GeoCompositeCurve;
				
				if ( outCompositeCurve != null )
				{
					outCurveCast = new T_extends_qb2A_GeoCurve();
					outCompositeCurve.set(outCurveCast);
				}
			}
			
			return outCurveCast;
		}

		/*public function splitAtPoints(splitPoints:Vector.<qb2GeoPoint>, fixedVector:Boolean = true):Vector.<qb2A_GeoCurve>
		{
			var toReturn:Vector.<qb2A_GeoCurve> = Vector.<qb2A_GeoCurve>(splitPoints.length + 1, fixedVector);
			toReturn[0] =  calcSubcurve(this.calcStartPoint(), splitPoints[0]);
			for ( var i:int = 0; i < splitPoints.length; i++ )
			{
				toReturn[i+1] = calcSubcurve(splitPoints[i], splitPoints[i+1]);
			}
			toReturn[toReturn.length - 1] =  calcSubcurve(splitPoints[splitPoints.length - 1], this.calcEndPoint());
			
			return toReturn;
		}

		public function splitAtDistances(distances:Vector.<Number>, fixedVector:Boolean = true):Vector.<qb2A_GeoCurve>
		{
			var toReturn:Vector.<qb2A_GeoCurve> = Vector.<qb2A_GeoCurve>(distances.length + 1, fixedVector);
			
			return toReturn;
		}

		public function splitAtPoint(splitPoint:qb2GeoPoint, fixedVector:Boolean = true):Vector.<qb2A_GeoCurve>
		{
			var wrapper:Vector.<qb2GeoPoint> = Vector.<qb2GeoPoint>(1, fixedVector);
			wrapper[0] = splitPoint;
			return splitAtPoints(wrapper, fixedVector);
		}

		public function splitAtDistance(distance:Number, fixedVector:Boolean = true):Vector.<qb2A_GeoCurve>
		{
			var wrapper:Vector.<Number> = Vector.<Number>(1, fixedVector);
			wrapper[0] = distance;
			return splitAtDistances(wrapper, fixedVector);
		}

		qb2_friend function calcSubcurveHelper(pointOrDistStart:Object, pointOrDistFinish:Object, out1:qb2GeoPoint, out2:qb2GeoPoint):Boolean
		{
			var point1:qb2GeoPoint, point2:qb2GeoPoint;
			if ( pointOrDistStart is qb2GeoPoint )
			{
				var output:qb2GeoLine = new qb2GeoLine();
				this.calcDistanceTo(pointOrDistStart as qb2GeoPoint, output);
				point1 = output.calcStartPoint();
			}
			else if ( pointOrDistStart is Number )
				point1 = calcPointAtDistance(pointOrDistStart as Number);
				
			if ( pointOrDistFinish is qb2GeoPoint )
			{
				this.calcDistanceTo(pointOrDistStart as qb2GeoPoint, output);
				point2 = output.calcEndPoint();
			}

			else if ( pointOrDistFinish is Number )
				point2 = calcPointAtDistance(pointOrDistFinish as Number);
				
			if ( point1 && point2 )
			{
				out1.copy(point1);
				out2.copy(point2);
				return true;
			}
			return false;
		}*/
		
		/*public override function convertTo(T:Class):*
		{
			//--- NOTE: I think for the most part that the qb2A_GeoPlanarSurface case will be
			//---		taken care of by subclasses, but the qb2GeoCurveBoundedPlane can be hit frequently.
			if ( qb2U_Type.isKindOf(T, qb2GeoCurveBoundedPlane) )
			{
				var boundedPlane:qb2GeoCurveBoundedPlane = qb2Class.getInstance(T).newInstance();
				var curve:qb2A_GeoCurve = this.getClass().newInstance();
				boundedPlane.setBoundary(curve);
				
				return boundedPlane;
			}
			
			return super.convertTo(T);
		}*/
	}
}