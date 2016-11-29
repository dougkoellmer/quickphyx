package quickb2.physics.utils 
{
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2I_TangibleObject;
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.surfaces.qb2GeoBoundingBox;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObject;
	import quickb2.utils.qb2SettingsClass;
	import quickb2.utils.qb2Util;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public final class qb2U_Bounds extends qb2Util 
	{
		public static function calcBoundingBox(tang:qb2A_TangibleObject, box_out:qb2GeoBoundingBox, worldSpace_nullable:qb2A_PhysicsObject = null):void
		{
			/*var boxSet:Boolean = false;
			
			var queue:Vector.<qb2A_PhysicsObject> = new Vector.<qb2A_PhysicsObject>();
			queue.unshift(this);
			
			while ( queue.length )
			{
				var tang:qb2A_PhysicsObject = queue.shift();
				
				if ( tang as qb2Shape )
				{
					if ( tang as qb2CircleShape )
					{
						var asCircleShape:qb2CircleShape = tang as qb2CircleShape;
						var circlePoint:qb2GeoPoint = asCircleShape.getParent().calcWorldPoint(asCircleShape.getPosition(), worldSpace);
						
						if ( !boxSet )
						{
							box.setMin(circlePoint);
							box.getMax().copy(box.getMin());
							box.swell(asCircleShape.getRadius());
							boxSet = true;
						}
						else
						{
							box.expandTo(tang.convertTo(qb2GeoCircle));
						}
					}
					else if ( tang as qb2PolygonShape )
					{
						var asPolygonShape:qb2PolygonShape = tang as qb2PolygonShape;
						
						for (var i:int = 0; i < asPolygonShape.getVertexCount(); i++) 
						{
							var ithVertex:qb2GeoPoint = asPolygonShape.getParent().calcWorldPoint(asPolygonShape.getVertexAt(i), worldSpace);
							
							if ( !boxSet )
							{
								box.setMin(ithVertex);
								box.getMax().copy(box.getMin());
								boxSet = true;
							}
							else
							{
								box.expandTo(ithVertex);
							}
						}
					}
				}
				else if ( tang is qb2A_PhysicsObjectContainer )
				{
					var asContainer:qb2A_PhysicsObjectContainer = tang as qb2A_PhysicsObjectContainer;
					
					for ( i = 0; i < asContainer._objects.length; i++) 
					{
						var ithObject:qb2A_PhysicsObject = asContainer._objects[i];
						
						if ( ithObject is qb2A_PhysicsObject )
						{
							queue.unshift(ithObject as qb2A_PhysicsObject);
						}
					}
				}
			}
			
			if ( !boxSet && (this is qb2Body) )
			{
				var worldPos:qb2GeoPoint = calcWorldPoint( (this as qb2Body).m_rigidImp._position, worldSpace);
				box.set(worldPos, box.getMax().copy(worldPos) as qb2GeoPoint);
			}*/
		}
		
		public static function calcBoundingBall(tang:qb2I_TangibleObject, outBall::qb2GeoBoundingBall, worldSpace:qb2A_PhysicsObject = null):void
		{
			/*var circle:qb2GeoBoundingBall = new qb2GeoBoundingBall();
			var circleSet:Boolean = false;
			
			var queue:Vector.<qb2A_PhysicsObject> = new Vector.<qb2A_PhysicsObject>();
			queue.unshift(this);
			
			var points:Dictionary = new Dictionary(true);
			
			while ( queue.length )
			{
				var tang:qb2A_PhysicsObject = queue.shift();
				
				if ( tang is qb2Shape )
				{
					if ( tang is qb2CircleShape )
					{
						var asCircleShape:qb2CircleShape = tang as qb2CircleShape;
						var circlePoint:qb2GeoPoint = asCircleShape.getParent().calcWorldPoint(asCircleShape.position, worldSpace);
						points[circlePoint] = asCircleShape.getRadius();
					}
					else if ( tang is qb2PolygonShape )
					{
						var asPolygonShape:qb2PolygonShape = tang as qb2PolygonShape;
						
						for (var i:int = 0; i < asPolygonShape.numVertices; i++) 
						{
							var ithVertex:qb2GeoPoint = asPolygonShape.getParent().calcWorldPoint(asPolygonShape.getVertexAt(i), worldSpace);
							points[ithVertex] = 0;
						}
					}
				}
				else if ( tang is qb2A_PhysicsObjectContainer )
				{
					var asContainer:qb2A_PhysicsObjectContainer = tang as qb2A_PhysicsObjectContainer;
					
					for ( i = 0; i < asContainer._objects.length; i++) 
					{
						var ithObject:qb2A_PhysicsObject = asContainer._objects[i];
						
						if ( ithObject is qb2A_PhysicsObject )
						{
							queue.push(ithObject as qb2A_PhysicsObject);
						}
					}
				}
			}*/
			
			return null;
		}
	}
}