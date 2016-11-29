package quickb2.math.geo.coords 
{
	import quickb2.debugging.logging.*;
	import quickb2.event.qb2Event;
	import quickb2.lang.*;
	import quickb2.math.geo.*;
	import quickb2.display.immediate.graphics.*;
	import quickb2.math.qb2U_Matrix;
	
	import quickb2.math.qb2I_Matrix;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_GeoCoordinate extends qb2A_GeoEntity implements qb2I_Matrix, qb2I_DrawPoint, qb2I_GeoHyperAxis
	{
		//--- DRK > These are exposed to subclasses solely to improve read performance...they shouldn't be edited directly by subclasses.
		internal var m_x:Number, m_y:Number, m_z:Number;
		
		public function qb2A_GeoCoordinate(x:Number = 0, y:Number = 0, z:Number = 0)
		{
			set(x, y, z);
		}
		
		public function floor():void
		{
			this.set(Math.floor(m_x), Math.floor(m_y), Math.floor(m_z));
		}
		
		public function ceil():void
		{
			this.set(Math.ceil(m_x), Math.ceil(m_y), Math.ceil(m_z));
		}
		
		public function round():void
		{
			this.set(Math.round(m_x), Math.round(m_y), Math.round(m_z));
		}
		
		public function setComponent(index:int, value:Number):void
		{
			switch(index)
			{
				case 0: setX(value);  break;
				case 1: setY(value);  break;
				case 2: setZ(value);  break;
			}
		}
		
		public function getComponent(index:int):Number
		{
			switch(index)
			{
				case 0: return m_x;
				case 1: return m_y;
				case 2: return m_z;
			}
			
			return 0;
		}
		
		public function isNAN():Boolean
		{
			return isNaN(m_x) || isNaN(m_y) || isNaN(m_z);
		}
		
		public function zeroOut():void
		{
			set(0, 0, 0);
		}
		
		public override function isEqualTo(otherEntity:qb2A_GeoEntity, tolerance_nullable:qb2GeoTolerance = null):Boolean
		{
			tolerance_nullable = qb2GeoTolerance.getDefault(tolerance_nullable);
			
			var asCoord:qb2A_GeoCoordinate = otherEntity as qb2A_GeoCoordinate;
			
			if ( asCoord != null )
			{
				//if( otherEntity
			}
			
			return false;
		}
		
		public function set(x:Number, y:Number, z:Number = 0):void
		{
			var updated:Boolean = x != m_x || y != m_y || z != m_z;
			
			m_x = x;
			m_y = y;
			m_z = z;
			
			if ( updated )
			{
				this.dispatchChangedEvent();
			}
		}
		
		public function getX():Number
		{
			return m_x;
		}
		public function setX(value:Number):void
		{
			set(value, m_y, m_z);
		}
		
		public function getY():Number
		{
			return m_y;
		}
		
		public function setY(value:Number):void
		{
			set(m_x, value, m_z);
		}
		
		public function getZ():Number
		{
			return m_z;
		}
		
		public function setZ(value:Number):void
		{
			set(m_x, m_y, value);
		}
		
		public function inc( xDelta:Number, yDelta:Number, zDelta:Number = 0 ):void
		{
			set(m_x + xDelta, m_y + yDelta, m_z + zDelta);
		}
			
		public function incX(value:Number):void
		{
			inc(value, 0, 0);
		}
		
		public function incY(value:Number):void
		{
			inc(0, value, 0);
		}
		
		public function incZ(value:Number):void
		{
			inc(0, 0, value);
		}
		
		protected override function copy_protected(otherObject:*):void
		{
			var otherCoordinate:qb2A_GeoCoordinate = otherObject as qb2A_GeoCoordinate;
			
			if ( otherCoordinate != null )
			{
				this.set(otherCoordinate.getX(), otherCoordinate.getY(), otherCoordinate.getZ());
			}
			else
			{
				var otherDrawPoint:qb2I_DrawPoint = otherObject as qb2I_DrawPoint;
				
				if ( otherDrawPoint != null )
				{
					this.set(otherDrawPoint.getX(), otherDrawPoint.getY(), 0);
				}
			}
		}
		
		public override function translateBy(vector:qb2A_GeoCoordinate, negate:Boolean = false):void
		{
			if ( negate )
			{
				this.inc(-vector.m_x, -vector.m_y, -vector.m_z);
			}
			else
			{
				this.inc(vector.m_x, vector.m_y, vector.m_z);
			}
		}
		
		public function scaleByNumber(value:Number):void
		{
			this.set(m_x * value, m_y * value, m_z * value);
		}
		
		/*public override function scale(vector:qb2GeoVector, origin:qb2GeoPoint = null):void
		{
			if ( origin )
			{
				var vec:qb2GeoVector = (new qb2GeoPoint()).minus(origin);
				this.translate(vec);
				this.set(m_x * vector.m_x, m_y * vector.m_y, m_z * vector.m_z);
				vec.negate();
				this.translate(vec);
			}
			else
			{
				this.set(m_x * vector.m_x, m_y * vector.m_y, m_z * vector.m_z);
			}
		}*/

		public override function rotateBy(radians:Number, axis:qb2I_GeoHyperAxis = null):void
		{
			var axis2d:qb2A_GeoCoordinate = axis as qb2A_GeoCoordinate;
			
			var originX:Number, originY:Number, originZ:Number;
			
			if ( axis2d != null )
			{
				originX = axis2d.m_x;
				originY = axis2d.m_y;
				originZ = axis2d.m_z;
			}
			else
			{
				originX = 0;
				originY = 0;
				originZ = 0;
			}
			
			const sinRad:Number = Math.sin(radians);
			const cosRad:Number = Math.cos(radians);
			const newVertX:Number = originX + cosRad * (this.m_x - originX) - sinRad * (this.m_y - originY);
			const newVertY:Number = originY + sinRad * (this.m_x - originX) + cosRad * (this.m_y - originY);
			
			this.set(newVertX, newVertY);
		}
		
		/*public override function convertTo(T:Class):*
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this, "x", m_x, "y", m_y, "z", m_z);
			}
			
			return super.convertTo(T);
		}*/
		
		public function getMatrixColumnCount():int 
		{
			return 1;
		}
		
		public function getMatrixRowCount():int 
		{
			return 3;
		}
		
		public function getMatrixValue(row:int, col:int):Number 
		{
			if ( row == 2 )
			{
				return 1;
			}
			else
			{
				return this.getComponent(row);
			}
		}
		
		public function setMatrixValue(row:int, col:int, value:Number):void 
		{
			if (row == 2 )
			{
				return;
			}
			
			this.setComponent(row, value);
		}
	}
}