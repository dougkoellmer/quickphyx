package quickb2.thirdparty.box2d 
{
	import Box2DAS.Collision.Shapes.b2CircleShape;
	import Box2DAS.Collision.Shapes.b2EdgeShape;
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Common.b2Def;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.geo.bounds.qb2GeoBoundingBall;
	import quickb2.math.geo.bounds.qb2GeoBoundingBox;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.iterators.qb2E_GeoTessellatorMode;
	import quickb2.math.geo.curves.iterators.qb2GeoCurveTessellator;
	import quickb2.math.geo.curves.iterators.qb2GeoTessellatorConfig;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.curves.qb2F_GeoCurveType;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.math.geo.qb2GeoGeometryIterator;
	import quickb2.math.geo.qb2GeoPolygonAnalyzer;
	import quickb2.math.geo.qb2I_GeoCircularEntity;
	import quickb2.math.geo.surfaces.planar.qb2A_GeoCurveBoundedPlane;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2S_Math;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.utils.prop.qb2PropMap;
	
	//TODO: Make the parameter order in these methods consistent.
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Box2dFixtureMaking extends qb2UtilityClass
	{
		private static const s_polygonAnalyzer:qb2GeoPolygonAnalyzer = new qb2GeoPolygonAnalyzer();
		private static const s_geoIterator:qb2GeoGeometryIterator = new qb2GeoGeometryIterator();
		private static const s_tessellator:qb2GeoCurveTessellator = new qb2GeoCurveTessellator();
		private static const s_tessellatorConfig:qb2GeoTessellatorConfig = new qb2GeoTessellatorConfig();
		
		private static const s_decomposedVertices:Vector.<Number> = new Vector.<Number>();
		
		private static const s_vertices:Vector.<V2> = new Vector.<V2>();
		
		private static const s_iteratorPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_lastPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilVector1:qb2GeoVector = new qb2GeoVector();
		
		
		public static function makeFixturesFromGeometry(propertyMap:qb2PropMap, transform_nullable:qb2AffineMatrix, box2dBody:b2Body, box2dFixtures_out:Vector.<b2Fixture>):void
		{
			var geometry:qb2A_GeoEntity = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.GEOMETRY);
			var geometryAsCurveBoundedPlane:qb2A_GeoCurveBoundedPlane = geometry as qb2A_GeoCurveBoundedPlane;
				
			if ( geometryAsCurveBoundedPlane != null )
			{				
				var boundaryAsCurve:qb2A_GeoCurve = geometryAsCurveBoundedPlane.getBoundary();
				var boundaryAsCircle:qb2I_GeoCircularEntity = boundaryAsCurve as qb2I_GeoCircularEntity;
				
				if ( boundaryAsCircle != null )
				{
					var radius:Number = boundaryAsCircle.getRadius();
					
					if ( radius >= 0 )
					{
						makeBox2dCircleShape(transform_nullable, box2dBody, boundaryAsCircle.getCenter(), boundaryAsCircle.getRadius(), propertyMap, box2dFixtures_out);
					}
				}
				else
				{
					makeBox2dPolygonShapeFromBoundaryCurve(transform_nullable, box2dBody, boundaryAsCurve, propertyMap, box2dFixtures_out);
				}
			}
			else
			{				
				var geometryAsCurve:qb2A_GeoCurve = geometry as qb2A_GeoCurve;
				
				if ( geometryAsCurve != null )
				{
					var curveThickness:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVE_THICKNESS);
					
					if ( curveThickness == 0 )
					{
						makeBox2dEdgeShape(transform_nullable, box2dBody, geometryAsCurve, propertyMap, box2dFixtures_out);
					}
					else
					{
						makeBox2dPolygonShapeFromCurve(transform_nullable, box2dBody, geometryAsCurve, propertyMap, box2dFixtures_out);
					}
				}
				else
				{
					var geometryAsPoint:qb2GeoPoint = geometry as qb2GeoPoint;
					
					if( geometryAsPoint != null )
					{
						//--- DRK > NOTE how a point radius of zero doesn't create geometry, but we don't early out because
						//---		the point can still affect mass properties.
						var pointRadius:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.POINT_RADIUS);
						if ( pointRadius > 0 )
						{
							makeBox2dCircleShape(transform_nullable, box2dBody, geometryAsPoint, pointRadius, propertyMap, box2dFixtures_out);
						}
					}
					else
					{
						var geometryAsBoundingBall:qb2GeoBoundingBall = geometry as qb2GeoBoundingBall;
						
						if ( geometryAsBoundingBall != null )
						{
							makeBox2dCircleShape(transform_nullable, box2dBody, geometryAsBoundingBall.getCenter(), geometryAsBoundingBall.getRadius(), propertyMap, box2dFixtures_out);
						}
						else
						{
							var geometryAsBoundingBox:qb2GeoBoundingBox = geometry as qb2GeoBoundingBox;
							
							if ( geometryAsBoundingBox )
							{
								s_geoIterator.initialize(geometryAsBoundingBox, qb2GeoPoint, s_iteratorPoint);
								s_polygonAnalyzer.initialize(s_geoIterator, 0);
								 
								 makeBox2dPolygonShapeFromIterator(transform_nullable, box2dBody, s_polygonAnalyzer, propertyMap, box2dFixtures_out);
							}
						}
					}
				}
			}
		}
		
		public static function makeBox2dCircleShape(transform_nullable:qb2AffineMatrix, box2dBody:b2Body, center:qb2GeoPoint, radius:Number, propertyMap:qb2PropMap, box2dFixtures_out:Vector.<b2Fixture>):void
		{
			s_utilPoint.copy(center);
			
			if ( transform_nullable != null )
			{
				s_utilPoint.transformBy(transform_nullable);
			}
			
			var pixelsPerMeter:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.PIXELS_PER_METER);
			var fixtureDef:b2FixtureDef = b2Def.fixture;
			var circleShape:b2CircleShape = b2Def.circle;
			circleShape.m_p.x = s_utilPoint.getX() / pixelsPerMeter;
			circleShape.m_p.y = s_utilPoint.getY() / pixelsPerMeter;
			circleShape.m_radius = radius / pixelsPerMeter;
			fixtureDef.shape = circleShape;
			
			createFixture(box2dBody, fixtureDef, box2dFixtures_out);
		}
		
		public static function makeBox2dPolygonShapeFromBoundaryCurve(transform_nullable:qb2AffineMatrix, box2dBody:b2Body, curve:qb2A_GeoCurve, propertyMap:qb2PropMap, box2dFixtures_out:Vector.<b2Fixture>):void
		{
			var allowComplex:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_DECOMPOSABLE);
			var iterator:qb2I_Iterator = initTessellator(curve, true, propertyMap);
			s_polygonAnalyzer.initialize(iterator, 0);
			
			makeBox2dPolygonShapeFromIterator(transform_nullable, box2dBody, s_polygonAnalyzer, propertyMap, box2dFixtures_out);
		}
		
		public static function makeBox2dPolygonShapeFromIterator(transform_nullable:qb2AffineMatrix, box2dBody:b2Body, polygonAnalyzer:qb2GeoPolygonAnalyzer, propertyMap:qb2PropMap, box2dFixtures_out:Vector.<b2Fixture>):void
		{
			var fixtureDef:b2FixtureDef = b2Def.fixture;
			var polygonShape:b2PolygonShape = b2Def.polygon;
			s_vertices.length = 0;
			var pixelsPerMeter:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.PIXELS_PER_METER);
			var allowComplex:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.IS_DECOMPOSABLE);
			
			for ( ; (polygonAnalyzer.next()) != null; )
			{
				if ( transform_nullable != null )
				{
					s_iteratorPoint.transformBy(transform_nullable);
				}
				
				var v2:V2 = new V2();
				
				v2.x = s_iteratorPoint.getX() / pixelsPerMeter;
				v2.y = s_iteratorPoint.getY() / pixelsPerMeter;
				
				s_vertices.push(v2);
			}
			
			var numVerts:int = s_vertices.length;
			
			var i:int;
			
			if ( numVerts > 2 )
			{
				if ( allowComplex )
				{
					var isConvex:Boolean = polygonAnalyzer.isConvexPolygon();
					
					if ( isConvex && numVerts <= 8 )
					{
						b2PolygonShape.EnsureCorrectVertexDirection(s_vertices);
						polygonShape.m_vertexCount = numVerts;
						polygonShape.Set(s_vertices);
						fixtureDef.shape = polygonShape;
						
						createFixture(box2dBody, fixtureDef, box2dFixtures_out);
					}
					else
					{
						s_decomposedVertices.length = 0;
						
						for ( i = 0; i < numVerts; i++)
						{
							s_decomposedVertices.push(s_vertices[i].x, s_vertices[i].y);
						}
						
						var polygonShapes:Vector.<b2PolygonShape> = b2PolygonShape.Decompose(s_decomposedVertices);
						
						for ( i = 0; i < polygonShapes.length; i++ )
						{
							fixtureDef.shape = polygonShapes[i];
							createFixture(box2dBody, fixtureDef, box2dFixtures_out);
						}
						
						s_decomposedVertices.length = 0;
					}
				}
				else
				{
					polygonShape.m_vertexCount = numVerts;
					polygonShape.Set(s_vertices);
					fixtureDef.shape = polygonShape;
					
					createFixture(box2dBody, fixtureDef, box2dFixtures_out);
				}
			}
			else if( numVerts == 2 )
			{
				var edgeShape:b2EdgeShape = b2Def.edge;
				edgeShape.m_vertex0.v2 = polygonShape.m_vertices[0];
				edgeShape.m_vertex1.v2 = polygonShape.m_vertices[1];
				fixtureDef.shape = edgeShape;
				
				createFixture(box2dBody, fixtureDef, box2dFixtures_out);
			}
			
			s_vertices.length = 0;
		}
		
		public static function makeBox2dCurveSegmentShape(box2dBody:b2Body, point1:qb2GeoPoint, point2:qb2GeoPoint, propertyMap:qb2PropMap, box2dFixtures_out:Vector.<b2Fixture>):void
		{
			var fixtureDef:b2FixtureDef = b2Def.fixture;
			var curveThickness:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVE_THICKNESS);
			var pixelsPerMeter:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.PIXELS_PER_METER);
			var polygonShape:b2PolygonShape = b2Def.polygon;
			polygonShape.m_vertices.length = 0;
			
			point2.calcDelta(point1, s_utilVector1);
			var length:Number = s_utilVector1.calcLength() / pixelsPerMeter;
			curveThickness /= pixelsPerMeter;
			var angle:Number = qb2S_Math.X_AXIS.calcSignedAngleTo(s_utilVector1);
			
			s_utilVector1.scaleByNumber(.5);
			var v2:V2 = new V2();
			v2.xy(point1.getX(), point2.getY());
			v2.x += s_utilVector1.getX();
			v2.y += s_utilVector1.getY();
			v2.multiplyN(1 / pixelsPerMeter);
			
			polygonShape.SetAsBox(length / 2, curveThickness / 2, v2, angle);
			fixtureDef.shape = polygonShape;
			
			createFixture(box2dBody, fixtureDef, box2dFixtures_out);
		}
		
		public static function makeBox2dPolygonShapeFromCurve(transform_nullable:qb2AffineMatrix, box2dBody:b2Body, curve:qb2A_GeoCurve, propertyMap:qb2PropMap, box2dFixtures_out:Vector.<b2Fixture>):void
		{
			var curveThickness:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVE_THICKNESS);
			var roundedCaps:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVES_HAVE_ROUNDED_CAPS);
			var roundedCorners:Boolean = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVES_HAVE_ROUNDED_CORNERS);
			
			var cornerRadius:Number = curveThickness / 2;
			
			var iterator:qb2I_Iterator = initTessellator(curve, false, propertyMap);
			var count:int = 0;
			for ( var point:qb2GeoPoint; point = iterator.next(); )
			{
				if ( transform_nullable != null )
				{
					point.transformBy(transform_nullable);
				}
				
				if ( count == 0 )
				{
					if ( roundedCaps )
					{
						makeBox2dCircleShape(null, box2dBody, point, cornerRadius, propertyMap, box2dFixtures_out);
					}
				}
				else
				{
					makeBox2dCurveSegmentShape(box2dBody, s_lastPoint, point, propertyMap, box2dFixtures_out);
					
					if ( count > 1 && roundedCorners )
					{
						makeBox2dCircleShape(null, box2dBody, s_lastPoint, cornerRadius, propertyMap, box2dFixtures_out);
					}
				}
				
				s_lastPoint.copy(point);
				
				count++;
			}
			
			if ( roundedCaps )
			{
				makeBox2dCircleShape(null, box2dBody, s_lastPoint, cornerRadius, propertyMap, box2dFixtures_out);
			}
		}
		
		private static function makeBox2dEdgeShape(transform_nullable:qb2AffineMatrix, box2dBody:b2Body, curve:qb2A_GeoCurve, propertyMap:qb2PropMap, box2dFixtures_out:Vector.<b2Fixture>):void
		{
			var curveThickness:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVE_THICKNESS);
			
			var polygonShape:b2PolygonShape = b2Def.polygon;
			polygonShape.m_vertices.length = 0;
			
			var iterator:qb2I_Iterator = initTessellator(curve, false, propertyMap);
			for ( var point:qb2GeoPoint; point = iterator.next(); )
			{
				if ( transform_nullable != null )
				{
					s_iteratorPoint.transformBy(transform_nullable);
				}
			}
		}
		
		private static function initTessellator(curve:qb2A_GeoCurve, forPolygon:Boolean, propertyMap:qb2PropMap):qb2I_Iterator
		{
			var maxPointCount:int = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.MAX_CURVE_TESSELLATION_POINTS);
			var minPointCount:int = forPolygon ? 3 : 2;
			var targetPointCount:int = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVE_POINT_COUNT);
			var targetSegmentLength:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVE_TESSELLATION);
			
			s_tessellatorConfig.minPointsPerCurvedSegment = minPointCount;
			s_tessellatorConfig.maxPointsPerCurvedSegment = maxPointCount;
	
			if ( targetPointCount > 0 )
			{
				s_tessellatorConfig.mode = qb2E_GeoTessellatorMode.BY_POINT_COUNT;
				s_tessellatorConfig.targetPointCount = targetPointCount;
			}
			else
			{
				s_tessellatorConfig.mode = qb2E_GeoTessellatorMode.BY_SEGMENT_LENGTH;
				s_tessellatorConfig.targetSegmentLength = targetSegmentLength;
			}
			
			s_tessellator.initialize(curve, s_tessellatorConfig, s_iteratorPoint);
				
			return s_tessellator;
		}
		
		private static function createFixture(box2dBody:b2Body, fixtureDef:b2FixtureDef, box2dFixtures_out:Vector.<b2Fixture>):void
		{
			fixtureDef.density = 0; // DRK > Always setting zero density because we handle mass data ourselves.
			var fixture:b2Fixture = box2dBody.CreateFixture(fixtureDef);
			
			box2dFixtures_out.push(fixture);
		}
	}
}