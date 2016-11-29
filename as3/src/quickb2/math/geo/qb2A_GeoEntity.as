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

package quickb2.math.geo
{
	import flash.events.*;
	import quickb2.lang.*;
	import quickb2.lang.foundation.*;
	import quickb2.utils.primitives.qb2Integer;
	import quickb2.utils.prop.qb2PropMap;
	
	import quickb2.lang.operators.*;
	import quickb2.lang.errors.*;
	import quickb2.lang.types.*;
	import quickb2.math.*;
	import quickb2.math.geo.*;
	import quickb2.math.geo.bounds.*;
	import quickb2.math.geo.coords.*;
	import quickb2.math.geo.curves.*;
	import quickb2.display.immediate.graphics.*;
	import quickb2.display.immediate.style.*;
	
	/**
	 * Abstract base class for all 2d point-set classes. Any subclass represents a set of points in 2d space.
	 */
	[qb2_abstract] public class qb2A_GeoEntity extends qb2A_MathEntity
	{
		internal static var s_matrix:qb2AffineMatrix = null;
		
		public function qb2A_GeoEntity()
		{
			include "../../lang/macros/QB2_ABSTRACT_CLASS";
		}
		
		[qb2_abstract] protected function isContainer():Boolean
		{
			return false;
		}
		
		public function expandBoundingRegion(region:qb2A_GeoBoundingRegion):void
		{
			region.pushEventDispatchBlock();
			{
				var iterator:qb2GeoDecompositionIterator = new qb2GeoDecompositionIterator(this);
				for ( var entity:qb2A_GeoEntity; entity = iterator.next(); )
				{
					entity.expandBoundingRegion(region);
				}
			}
			region.popEventDispatchBlock();
		}
		
		public function copy(otherObject:*):void
		{
			this.copy_protected(otherObject);
		}
		
		[qb2_virtual] protected override function copy_protected(otherObject:*):void
		{
			if ( !qb2U_Type.isKindOf(otherObject, qb2A_GeoEntity) )  return;
			
			this.pushEventDispatchBlock();
			{
				var thisSubEntities:Vector.<qb2A_GeoEntity> = new Vector.<qb2A_GeoEntity>();
				var iterator:qb2GeoDecompositionIterator = new qb2GeoDecompositionIterator(this);
				for ( var thisSubentity:qb2A_GeoEntity; (thisSubentity = iterator.next()) != null; )
				{
					thisSubEntities.push(thisSubentity);
				}
				
				var count:int = 0;
				iterator.initialize(otherObject);
				for ( var otherSubentity:qb2A_GeoEntity; (otherSubentity = iterator.next()) != null; )
				{
					if ( count >= thisSubEntities.length )  break;
					
					otherSubentity.copy(thisSubEntities[count]);
					
					count++;
				}
			}
			this.popEventDispatchBlock();
		}
		
		public function calcBoundingBox(outBox:qb2GeoBoundingBox):void
		{
			outBox.set(null, null);
			var boxSet:Boolean = false;
			
			var iterator:qb2GeoDecompositionIterator = new qb2GeoDecompositionIterator(this);
			for ( var entity:qb2A_GeoEntity; entity = iterator.next(); )
			{
				if ( !boxSet )
				{
					entity.calcBoundingBox(outBox);
					
					boxSet = true;
				}
				else
				{
					entity.expandBoundingRegion(outBox);
				}
			}
		}
		
		[qb2_abstract] public function calcBoundingBall(outBall:qb2GeoBoundingBall):void
		{
		}
		
		public function calcCenterOfMass(point_out:qb2GeoPoint):void
		{
			/*var verts:Vector.<qb2GeoPoint> = new Vector.<qb2GeoPoint>();
			var iterator:qb2GeoDecompositionIterator = qb2GeoDecompositionIterator.getInstance(this, qb2E_AllocationMode.SOURCE);
			for ( var entity:qb2A_GeoEntity; entity = iterator.next(); )
			{
				if ( qb2U_Type.isKindOf(entity, qb2GeoPoint) )
				{
					verts.push(entity as qb2GeoPoint);
				}
				else
				{
					verts.push(entity.calcCenterOfMass());
				}
				
				numVerts++;
			}
			qb2GeoDecompositionIterator.releaseInstance(iterator);
			
			var numVerts:uint = verts.length;
			
			if ( numVerts >= 3 )
			{
				var centerOfMass:qb2GeoPoint = new qb2GeoPoint();
				const k_inv3:Number = 1.0 / 3.0;
				var totalArea:Number = 0;
			
				for (var i:int = 0; i < numVerts; i++)
				{
					var ithPnt:qb2GeoPoint = m_verts[i];
					var nextPnt:qb2GeoPoint = (i + 1) < numVerts ? m_verts[i + 1] : m_verts[0];
					
					var D:Number = ithPnt.m_x * nextPnt.m_y - ithPnt.m_y * nextPnt.m_x;
		
					var triangleArea:Number = 0.5 * D;
					totalArea += triangleArea;
					
					centerOfMass.m_x += triangleArea * k_inv3 * (ithPnt.m_x + nextPnt.m_x);
					centerOfMass.m_y += triangleArea * k_inv3 * (ithPnt.m_y + nextPnt.m_y);
				}
				
				if ( totalArea )
				{
					centerOfMass.scale(new qb2GeoVector(1.0 / totalArea, 1.0 / totalArea));
				}
				else
				{
					centerOfMass.set();
				}
				
				return centerOfMass;
			}
			else if( numVerts == 2 )
			{
				return verts[0].calcMidwayPoint(verts[1]);
			}
			else if ( numVerts == 1 )
			{
				return verts[0].clone();
			}
			
			return new qb2GeoPoint();*/
		}
		
		[qb2_abstract] public function calcDistanceSquaredTo(otherEntity:qb2A_GeoEntity, line_out_nullable:qb2GeoLine = null):Number
		{
			include "../../lang/macros/QB2_ABSTRACT_METHOD";
			
			return NaN;
		}
		
		[qb2_abstract] public function calcMomentOfInertia(mass:Number, axis_nullable:qb2I_GeoHyperAxis = null, centerOfMass_out_nullable:qb2GeoPoint = null):Number
		{
			include "../../lang/macros/QB2_ABSTRACT_METHOD";
			
			return NaN;
		}
		
		[qb2_virtual] public function calcDistanceTo(entity:qb2A_GeoEntity, line_out_nullable:qb2GeoLine = null):Number
		{
			return Math.sqrt(this.calcDistanceSquaredTo(entity, line_out_nullable));
		}
		
		[qb2_abstract] public function calcIsIntersecting(entity:qb2A_GeoEntity, options_nullable:qb2GeoIntersectionOptions = null, result_out_nullable:qb2GeoIntersectionResult = null):Boolean
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
			
			return false;
			//return qb2InternalgeoMegaSwitch.process(this, otherEntity, output, tolerance, pointEqualityMode, qb2InternalgeoMegaSwitch.INTERSECTION);
		}
		
		[qb2_virtual] public function isEqualTo(entity:qb2A_GeoEntity, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			var equal:Boolean = true;
			
			var thisObjects:Vector.<qb2A_GeoEntity> = new Vector.<qb2A_GeoEntity>();
			var iterator:qb2GeoDecompositionIterator = new qb2GeoDecompositionIterator(this);
			for ( var thisSubentity:qb2A_GeoEntity ; (thisSubentity = iterator.next()) != null; )
			{
				thisObjects.push(thisSubentity);
			}
			
			var count:int = 0;
			iterator.initialize(entity);
			for ( var otherSubentity:qb2A_GeoEntity ; (otherSubentity = iterator.next()) != null; )
			{
				if ( count >= thisObjects.length )
				{
					equal = false;
					break;
				}
				
				thisSubentity = thisObjects[count];
				
				if ( !thisSubentity.isEqualTo(otherSubentity, tolerance_nullable) )
				{
					equal = false;
					break;
				}
				
				count++;
			}
			
			if ( count != thisObjects.length )
			{
				equal = false;
			}
			
			return equal;
		}
		
		public function translateBy(vector:qb2A_GeoCoordinate, negated:Boolean = false):void
		{
			var matrix:qb2AffineMatrix = new qb2AffineMatrix();
			matrix.setToTranslation(vector, negated);
			
			this.transformBy(matrix);
		}
		
		public function scaleBy(values:qb2GeoVector, origin_nullable:qb2GeoPoint = null):void
		{
			var matrix:qb2AffineMatrix = new qb2AffineMatrix();
			matrix.setToScaling(values, origin_nullable);
			
			this.transformBy(matrix);
		}
		
		public function rotateBy(radians:Number, axis_nullable:qb2I_GeoHyperAxis = null):void
		{
			var matrix:qb2AffineMatrix = new qb2AffineMatrix();
			matrix.setToRotation(radians, axis_nullable as qb2GeoPoint);
			
			this.transformBy(matrix);
		}
		
		public function transformBy(matrix:qb2I_Matrix):void
		{
			this.pushEventDispatchBlock();
			{
				var iterator:qb2GeoDecompositionIterator = new qb2GeoDecompositionIterator(this);
				for ( var entity:qb2A_GeoEntity; entity = iterator.next(); )
				{
					entity.transformBy(matrix);
				}
			}
			this.popEventDispatchBlock();
		}
		
		[qb2_abstract] public function slice(plane:qb2I_GeoHyperPlane, entities_out:Vector.<qb2A_GeoEntity>):void  { }
		
		[qb2_virtual] public function draw(graphics:qb2I_Graphics2d, propertyMap_nullable:qb2PropMap = null):void
		{
			include "../../lang/macros/QB2_ABSTRACT_METHOD";
		}
		
		internal function nextDecomposition_internal(progress:int):qb2A_GeoEntity
		{
			return nextDecomposition(progress);
		}
		
		internal function nextGeometry_internal(progress:int, T__extends__qb2A_GeoEntity:Class, progressOffset_out:qb2Integer):qb2A_GeoEntity
		{
			return nextGeometry(progress, T__extends__qb2A_GeoEntity, progressOffset_out);
		}
		
		[qb2_virtual] protected function nextDecomposition(progress:int):qb2A_GeoEntity
		{
			return null;
		}
		
		[qb2_virtual] protected function nextGeometry(progress:int, T_extends_qb2A_GeoEntity:Class, progressOffset_out:qb2Integer):qb2A_GeoEntity
		{
			return null;
		}
		
		/*public override function convertTo(T:Class):*
		{
			if ( qb2U_Type.isKindOf(T, qb2A_GeoEntity) )
			{
				var newInstance:qb2A_GeoEntity = this.getClass().newInstance();
				
				newInstance.copy(this);
				
				return newInstance;
			}
			
			return super.convertTo(T);
		}*/
	}
}