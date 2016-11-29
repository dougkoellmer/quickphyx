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

package quickb2.math.geo.bounds
{
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.display.immediate.style.qb2U_Style;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.types.qb2Class;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.*;
	import flash.display.*;
	import quickb2.lang.*
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2GeoEllipse;
	import quickb2.math.geo.qb2GeoDecompositionIterator;
	import quickb2.math.geo.qb2GeoGeometryIterator;
	import quickb2.math.geo.qb2GeoTolerance;
	import quickb2.math.geo.qb2I_GeoCircularEntity;
	import quickb2.math.geo.qb2I_GeoHyperAxis;
	import quickb2.math.geo.qb2PU_Circle;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoCurveBoundedPlane;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoPlanarSurface;
	import quickb2.math.geo.surfaces.planar.qb2GeoCircularDisk;
	import quickb2.math.geo.surfaces.planar.qb2GeoEllipticalDisk;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.utils.prop.qb2PropMap;
	
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2GeoCircle;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.event.qb2EventDispatcher;

	public class qb2GeoBoundingBall extends qb2A_GeoBoundingRegion implements qb2I_GeoCircularEntity
	{
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		
		private const m_center:qb2GeoPoint = new qb2GeoPoint();
		private var m_radius:Number;
		
		public function qb2GeoBoundingBall(sourceCenter:qb2GeoPoint = null, radius:Number=0) 
		{
			init(sourceCenter, radius);
		}
		
		private function init(sourceCenter:qb2GeoPoint, radius:Number):void
		{
			set(sourceCenter ? sourceCenter : m_center, radius);
			
			this.addEventListenerToSubEntity(m_center, false);
		}
		
		public function set(center_copied_nullable:qb2GeoPoint, radius:Number):void
		{
			m_radius = radius;
			
			if ( center_copied_nullable != null )
			{
				m_center.copy(center_copied_nullable);
			}
			else
			{
				this.dispatchChangedEvent();
			}
		}
		
		public override function expandBoundingRegion(region:qb2A_GeoBoundingRegion):void
		{
			region.pushEventDispatchBlock();
			region.expandToPoint(m_center, m_radius);
			region.popEventDispatchBlock();
		}
		
		public override function expandToPoint(point:qb2GeoPoint, radius:Number = 0):void
		{
			var vector:qb2GeoVector = point.minus(this.m_center);
			
			if ( radius )
			{
				var length:Number = vector.calcLength() + radius

				if ( length > this.m_radius )
				{
					this.setRadius(length);
				}
			}
			else
			{
				var lengthSquared:Number = vector.calcLengthSquared();
				
				if ( lengthSquared > this.m_radius * this.m_radius )
				{
					length = Math.sqrt(lengthSquared);
					
					this.setRadius(length);
				}
			}
		}
		
		public override function calcMomentOfInertia(mass:Number, axis_nullable:qb2I_GeoHyperAxis = null, centerOfMass_out_nullable:qb2GeoPoint = null):Number
		{
			if ( axis_nullable == null )
			{
				if ( centerOfMass_out_nullable != null )
				{
					this.calcCenterOfMass(centerOfMass_out_nullable);
				}
				
				return qb2U_MomentOfInertia.circularDisk(mass, this.getRadius());
			}
			else if ( qb2U_Type.isKindOf(axis_nullable, qb2GeoVector)  )
			{
				if ( centerOfMass_out_nullable != null )
				{
					this.calcCenterOfMass(centerOfMass_out_nullable);
				}
				
				return qb2U_MomentOfInertia.sphere(mass, this.getRadius());
			}
			else if ( qb2U_Type.isKindOf(axis_nullable, qb2GeoPoint) )
			{
				var axisAsPoint:qb2GeoPoint = axis_nullable as qb2GeoPoint;
				centerOfMass_out_nullable = centerOfMass_out_nullable != null ? centerOfMass_out_nullable : s_utilPoint;
				this.calcCenterOfMass(centerOfMass_out_nullable);
				
				var centerOfMassInertia:Number = qb2U_MomentOfInertia.circularDisk(mass, this.getRadius());
				
				return qb2U_MassFormula.parallelAxisTheorem(centerOfMassInertia, mass, axisAsPoint.calcDistanceSquaredTo(centerOfMass_out_nullable));
			}
			else
			{
				qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
				
				return NaN;
			}
		}
		
		public override function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			point_out.copy(this.getCenter());
		}
		
		public override function isEqualTo(otherEntity:qb2A_GeoEntity, tolerance:qb2GeoTolerance = null):Boolean
		{
			return qb2PU_Circle.isEqualTo(this, otherEntity, tolerance);
		}
		
		protected override function copy_protected(source:*):void
		{
			qb2PU_Circle.copy(source, this);
		}

		/*public override function convertTo(T:Class):*
		{
			var entity:* = qb2PU_Circle.convertTo(this, T);
				
			if ( entity != null )
			{
				return entity;
			}
			
			return super.convertTo(T);
		}*/
		
		public function getRadius():Number
		{
			return m_radius;
		}
		public function setRadius(radius:Number):void
		{
			m_radius = radius;
			
			this.dispatchChangedEvent();
		}
		
		public function getCenter():qb2GeoPoint
		{
			return m_center;
		}
		
		public override function swell(byAmount:Number):void
		{
			this.setRadius(this.getRadius() + byAmount);
		}
		
		public override function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			qb2U_Style.populateGraphics(graphics, propertyMap_nullable);
			graphics.drawCircle(m_center, m_radius);
			qb2U_Style.depopulateGraphics(graphics, propertyMap_nullable);
		}
		
		protected override function nextDecomposition(progress:int):qb2A_GeoEntity
		{
			if ( progress == 0 )
			{
				return m_center;
			}
			
			return null;
		}
	}
}