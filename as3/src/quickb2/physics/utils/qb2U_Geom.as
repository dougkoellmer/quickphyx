package quickb2.physics.utils 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2A_GeoCoordinate;
	import quickb2.math.geo.curves.qb2A_GeoCurve;
	import quickb2.math.geo.qb2I_GeoHyperPlane;
	import quickb2.math.geo.surfaces.qb2A_GeoSurface;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2I_Matrix;
	import quickb2.math.qb2TransformStack;
	import quickb2.math.qb2U_Formula;
	import quickb2.physics.core.iterators.qb2AncestorIterator;
	import quickb2.physics.core.iterators.qb2AttachedJointIterator;
	import quickb2.physics.core.iterators.qb2ChildIterator;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.*;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.core.tangibles.qb2Shape;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.utils.prop.qb2PropMap;
	
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	
	import quickb2.lang.foundation.*;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2U_Geom extends qb2UtilityClass
	{
		//TODO: Optimize "local" methods below to not use vectors.
		
		private static const s_affineMatrix1:qb2AffineMatrix = new qb2AffineMatrix();
		private static const s_affineMatrix2:qb2AffineMatrix = new qb2AffineMatrix();
		
		private static const s_transformStack:qb2TransformStack = new qb2TransformStack();
		
		private static const s_ancestorIterator:qb2AncestorIterator = new qb2AncestorIterator();
		
		public static function calcGlobalPoint(object:qb2A_PhysicsObject, localPoint:qb2GeoPoint, point_out:qb2GeoPoint, globalSpace_nullable:qb2A_PhysicsObjectContainer = null):void
		{
			point_out.copy(localPoint);
			
			s_ancestorIterator.initialize(object, null, false);
			
			for ( var currParent:qb2A_TangibleObject; (currParent = s_ancestorIterator.next()) != null; )
			{
				if ( currParent == globalSpace_nullable )  break;
				
				var currParentX:Number = currParent.getPosition().getX();
				var currParentY:Number = currParent.getPosition().getY();
				var currParentRot:Number = currParent.getRotation();
				
				point_out.inc(currParentX, currParentY);
				
				var sinRad:Number = Math.sin(currParentRot);
				var cosRad:Number = Math.cos(currParentRot);
				var newVertX:Number = currParentX + cosRad * (point_out.getX() - currParentX) - sinRad * (point_out.getY() - currParentY);
				var newVertY:Number = currParentY + sinRad * (point_out.getX() - currParentX) + cosRad * (point_out.getY() - currParentY);
				
				point_out.set(newVertX, newVertY);
			}
		}

		public static function calcLocalPoint(object:qb2A_PhysicsObject, globalPoint:qb2GeoPoint, point_out:qb2GeoPoint, globalSpace_nullable:qb2A_PhysicsObjectContainer = null):void
		{
			point_out.copy(globalPoint);
			
			var spaceList:Vector.<qb2A_TangibleObject> = new Vector.<qb2A_TangibleObject>();
		
			s_ancestorIterator.initialize(object, null, false);
			for ( var currParent:qb2A_TangibleObject; (currParent = s_ancestorIterator.next()) != null; )
			{
				if ( currParent == globalSpace_nullable )  break;
				
				spaceList.unshift(currParent);
			}
			
			for (var i:int = 0; i < spaceList.length; i++) 
			{
				var space:qb2A_TangibleObject = spaceList[i];
				
				point_out.translateBy(space.getPosition(), true);
				
				var sinRad:Number = Math.sin(-space.getRotation());
				var cosRad:Number = Math.cos(-space.getRotation());
				var newVertX:Number = cosRad * (point_out.getX()) - sinRad * (point_out.getY());
				var newVertY:Number = sinRad * (point_out.getX()) + cosRad * (point_out.getY());
				
				point_out.set(newVertX, newVertY);
			}
		}

		public static function calcGlobalVector(object:qb2A_PhysicsObject, localVector:qb2GeoVector, vector_out:qb2GeoVector, globalSpace_nullable:qb2A_PhysicsObjectContainer = null):void
		{
			vector_out.copy(localVector);
			
			s_ancestorIterator.initialize(object, null, false);
			
			for ( var currParent:qb2A_TangibleObject; (currParent = s_ancestorIterator.next()) != null; )
			{
				if ( currParent == globalSpace_nullable )  break;
			
				var sinRad:Number = Math.sin(currParent.getRotation());
				var cosRad:Number = Math.cos(currParent.getRotation());
				var newVecX:Number = vector_out.getX() * cosRad - vector_out.getY() * sinRad;
				var newVecY:Number = vector_out.getX() * sinRad + vector_out.getY() * cosRad;
				
				vector_out.set(newVecX, newVecY);
			}
		}

		public static function calcLocalVector(object:qb2A_PhysicsObject, globalVector:qb2GeoVector, vector_out:qb2GeoVector, globalSpace_nullable:qb2A_PhysicsObjectContainer = null):void
		{
			vector_out.copy(globalVector);
			
			var spaceList:Vector.<qb2A_TangibleObject> = new Vector.<qb2A_TangibleObject>();
			
			s_ancestorIterator.initialize(object, null, false);
			for ( var currParent:qb2A_TangibleObject; (currParent = s_ancestorIterator.next()) != null; )
			{
				if ( currParent == globalSpace_nullable )  break;
				
				spaceList.unshift(currParent);
			}
			
			for (var i:int = 0; i < spaceList.length; i++) 
			{
				var space:qb2A_TangibleObject = spaceList[i];
			
				var sinRad:Number = Math.sin(-space.getRotation());
				var cosRad:Number = Math.cos(-space.getRotation());
				var newVecX:Number = vector_out.getX() * cosRad - vector_out.getY() * sinRad;
				var newVecY:Number = vector_out.getX() * sinRad + vector_out.getY() * cosRad;
				
				vector_out.set(newVecX, newVecY);
			}
		}
		
		public static function calcGlobalRotation(object:qb2A_PhysicsObject, localRotation:Number, globalSpace_nullable:qb2A_PhysicsObjectContainer = null):Number
		{
			var worldRotation:Number = localRotation;
			
			s_ancestorIterator.initialize(object, null, false);
			for ( var currParent:qb2A_TangibleObject; (currParent = s_ancestorIterator.next()) != null; )
			{
				if ( currParent == globalSpace_nullable )  break;
				
				worldRotation += currParent.getRotation();
			}
			
			return worldRotation;
		}

		public static function calcLocalRotation(object:qb2A_PhysicsObject, worldRotation:Number, globalSpace_nullable:qb2A_PhysicsObjectContainer = null):Number
		{
			var calcLocalRotation:Number = worldRotation;
			
			var spaceList:Vector.<qb2A_TangibleObject> = new Vector.<qb2A_TangibleObject>();
			
			s_ancestorIterator.initialize(object, null, false);
			for ( var currParent:qb2A_TangibleObject; (currParent = s_ancestorIterator.next()) != null; )
			{
				if ( currParent == globalSpace_nullable )  break;
				
				spaceList.unshift(currParent);
			}
			
			for (var i:int = 0; i < spaceList.length; i++) 
			{
				var space:qb2A_TangibleObject = spaceList[i];
				
				calcLocalRotation -= space.getRotation();
			}
			
			return calcLocalRotation;
		}
		
		public static function calcDistance(objectA:qb2A_PhysicsObject, objectB:qb2A_PhysicsObject, line_out_nullable:qb2GeoLine = null, excludes:Array = null):Number
		{
			//--- Do a bunch of checks for whether objectA is a legal operation in the first place.
			/*if ( !objectA.getWorld() || !objectB.getWorld() )
			{
				qb2U_Error.throwCode(qb2E_ErrorCode.BAD_DISTANCE_QUERY);
				return NaN;
			}
			if ( objectA == objectB )
			{
				qb2U_Error.throwCode(qb2E_ErrorCode.BAD_DISTANCE_QUERY);
				return NaN;
			}
			if ( objectA is qb2A_PhysicsObjectContainer )
			{
				if ( qb2U_Family.isDescendantOf(objectB, objectA as qb2A_PhysicsObjectContainer) )
				{
					qb2U_Error.throwCode(qb2E_ErrorCode.BAD_DISTANCE_QUERY);
					return NaN;
				}
			}
			if ( objectB is qb2A_PhysicsObjectContainer )
			{
				if ( qb2U_Family.isDescendantOf(objectA, objectB as qb2A_PhysicsObjectContainer) )
				{
					qb2U_Error.throwCode(qb2E_ErrorCode.BAD_DISTANCE_QUERY);
					return NaN;
				}
			}
			
			var fixtures1:Array = getFixtures(objectA, excludes);
			var fixtures2:Array = getFixtures(objectB, excludes);
			
			var numFixtures1:int = fixtures1.length;
			var smallest:Number = Number.MAX_VALUE;
			var vec:V2 = null;
			var pointA:qb2GeoPoint = new qb2GeoPoint();
			var pointB:qb2GeoPoint = new qb2GeoPoint();
			
			var din:b2DistanceInput = b2Def.distanceInput;
			var dout:b2DistanceOutput = b2Def.distanceOutput;
			pointShape = pointShape ? pointShape : new b2CircleShape();
			
			for (var i:int = 0; i < numFixtures1; i++) 
			{
				var ithFixture:* = fixtures1[i];
				
				if ( ithFixture is b2Fixture )
				{
					var asFix:b2Fixture = ithFixture as b2Fixture;
					din.proxyA.Set( asFix.m_shape);
					din.transformA.xf = asFix.m_body.GetTransform();
				}
				else
				{
					din.proxyA.Set( pointShape);
					din.transformA.xf = ithFixture as XF;
				}
				
				var numFixtures2:int = fixtures2.length;
				for (var j:int = 0; j < numFixtures2; j++) 
				{
					var jthFixture:* = fixtures2[j];
					
					if ( jthFixture is b2Fixture )
					{
						asFix = jthFixture as b2Fixture;
						din.proxyB.Set( (jthFixture as b2Fixture).m_shape);
						din.transformB.xf = asFix.m_body.GetTransform();
					}
					else
					{
						din.proxyB.Set(pointShape);
						din.transformB.xf = jthFixture as XF;
					}
					
					din.useRadii = true;
					b2Def.simplexCache.count = 0;
					b2Distance();
					var seperation:V2 = dout.pointB.v2.subtract(dout.pointA.v2);
					var distance:Number = seperation.lengthSquared();
					
					if ( distance < smallest )
					{
						smallest = distance;
						vec = seperation;
						pointA.set(dout.pointA.x, dout.pointA.y);
						pointB.set(dout.pointB.x, dout.pointB.y);
					}
				}					
			}
			
			if ( !vec )
			{
				qb2_throw(new qb2Error(qb2E_ErrorCode.BAD_DISTANCE_QUERY));
				return NaN;
			}
			
			var physScale:Number = objectA.getWorldPixelsPerMeter();
			
			vec.multiplyN(physScale);
			
			if ( output )
			{
				output.getStartPoint().copy(pointA.scale(physScale, physScale));
				output.getEndPoint().copy(pointB.scale(physScale, physScale));
			}
		
			return vec.length();*/
			
			return 1;
		}
		
		private static function getFixtures(tang:qb2A_PhysicsObject, excludes:Array):Array
		{
			var returnFixtures:Array = [];
			
			/*var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(tang as qb2A_PhysicsObject);
			
			for ( var object:qb2A_PhysicsObject; iterator.next(); )
			{
				if ( excludes )
				{
					for (var k:int = 0; k < excludes.length; k++) 
					{
						var exclude:* = excludes[k];
						if ( exclude is Class )
						{
							var asClass:Class = exclude as Class;
							if ( object is asClass )
							{
								continue;
							}
						}
						else if ( object == exclude )
						{
							continue;
						}
					}
				}
				
				if ( object as qb2Shape )
				{
					var shapeFixtures:Vector.<b2Fixture> = (object as qb2Shape).m_fixtures;
					
					for (var i:int = 0; i < shapeFixtures.length; i++) 
					{
						returnFixtures.push(shapeFixtures[i]);
					}
				}
				else if ( object as qb2A_PhysicsObjectContainer )
				{
					var asContainer:qb2A_PhysicsObjectContainer = object as qb2A_PhysicsObjectContainer;
				
					if ( asContainer._bodyB2 )
					{
						returnFixtures.push(asContainer._bodyB2.GetTransform());
					}
					else
					{
						var worldPnt:qb2GeoPoint = qb2U_Geom.calcWorldPoint(asContainer, new qb2GeoPoint());
						var xf:XF = new XF();
						xf.p.x = worldPnt.getX() / asContainer.getWorldPixelsPerMeter();
						xf.p.y = worldPnt.getY() / asContainer.getWorldPixelsPerMeter();
						returnFixtures.push(xf);
					}
				}
			}*/
			
			return returnFixtures;
		}
		
		public static function findShapeAtPoint(tang:qb2A_TangibleObject, mousePoint:qb2GeoPoint):qb2Shape
		{
			if ( tang.getEffectiveProp(qb2S_PhysicsProps.MASS) == 0 )  return null;
			
			mousePoint.translateBy(tang.getPosition(), true);
			mousePoint.rotateBy( -tang.getRotation());
			
			var isContainer:Boolean = qb2U_Type.isKindOf(tang, qb2A_PhysicsObjectContainer);
						
			if ( isContainer )
			{
				var asContainer:qb2A_PhysicsObjectContainer = tang as qb2A_PhysicsObjectContainer;
				var currentChild:qb2A_PhysicsObject = asContainer.getFirstChild();
				
				while (currentChild != null )
				{
					if ( qb2U_Type.isKindOf(currentChild, qb2A_TangibleObject) )
					{
						var asTang:qb2A_TangibleObject = currentChild as qb2A_TangibleObject;
						
						if ( asTang.getEffectiveProp(qb2S_PhysicsProps.IS_DEBUG_DRAGGABLE) )
						{
							var shape:qb2Shape = findShapeAtPoint(asTang, mousePoint);
							
							if ( shape != null )
							{
								return shape;
							}
						}
					}
					
					currentChild = currentChild.getNextSibling();
				}
			}
			else
			{
				if ( tang.getEffectiveProp(qb2S_PhysicsProps.IS_DEBUG_DRAGGABLE) )
				{
					var geometry:qb2A_GeoEntity = tang.getEffectiveProp(qb2S_PhysicsProps.GEOMETRY);
					
					if ( geometry != null )
					{
						if ( geometry.calcIsIntersecting(mousePoint) )
						{
							return tang as qb2Shape;
						}
					}
				}
			}
			
			mousePoint.rotateBy(tang.getRotation());
			mousePoint.translateBy(tang.getPosition());
			
			return null;
		}
		
		private static function calcIntersection_private(object:qb2A_TangibleObject, entity:qb2A_GeoEntity):Boolean
		{
			var intersecting:Boolean = false;
			
			calcTransform(object, s_affineMatrix1);
			s_affineMatrix1.invert();
			s_transformStack.pushAndConcat(s_affineMatrix1);

			if ( qb2U_Type.isKindOf(object, qb2Shape) )
			{
				var geometry:qb2A_GeoEntity = object.getEffectiveProp(qb2S_PhysicsProps.GEOMETRY);
				
				if ( geometry != null )
				{
					entity.transformBy(s_transformStack.get());
					
					intersecting = geometry.calcIsIntersecting(entity);
					
					s_affineMatrix1.copy(s_transformStack.get());
					s_affineMatrix1.invert();
					entity.transformBy(s_affineMatrix1);
				}
			}
			else
			{
				var child:qb2A_PhysicsObject = (object as qb2A_PhysicsObjectContainer).getFirstChild();
				
				while ( child != null )
				{
					var asTang:qb2A_TangibleObject = child as qb2A_TangibleObject;
					
					if ( calcIntersection_private(asTang, entity) )
					{
						intersecting = true;
						
						break;
					}
					
					child = child.getNextSibling();
				}
			}
			
			s_transformStack.pop();
			
			return intersecting;
		}
		
		public static function calcIntersection(object:qb2A_TangibleObject, entity:qb2A_GeoEntity):Boolean
		{
			s_transformStack.get().setToIdentity();
			
			return calcIntersection_private(object, entity);
		}
		
		public static function reflect(physObject:qb2A_TangibleObject, plane:qb2I_GeoHyperPlane):void
		{
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
		}
		
		public static function translate(tang:qb2A_TangibleObject, vector:qb2GeoVector):void
		{
		}
		
		public static function rotate(tang:qb2A_TangibleObject, radians:Number, origin_nullable:qb2GeoPoint = null):void
		{
			tang.getPosition().rotateBy(radians, origin_nullable);
			tang.setRotation(tang.getRotation() + radians);
		}
		
		public static function calcGlobalTransform(tang:qb2A_TangibleObject, matrix_out:qb2AffineMatrix, globalSpace_nullable:qb2A_PhysicsObjectContainer = null):void
		{
			calcTransform(tang, matrix_out);
			
			s_ancestorIterator.initialize(tang, null, true);
			
			for ( var currParent:qb2A_TangibleObject; (currParent = s_ancestorIterator.next()) != null; )
			{
				if ( currParent == globalSpace_nullable )  break;
				
				calcTransform(currParent, s_affineMatrix1);
				matrix_out.preConcat(s_affineMatrix1);
			}
		}
		
		public static function calcTransform(tang:qb2A_TangibleObject, matrix_out:qb2AffineMatrix):void
		{
			matrix_out.setToTranslation(tang.getPosition());
			s_affineMatrix2.setToRotation(tang.getRotation());
			matrix_out.concat(s_affineMatrix2);
		}
		
		public static function pushToTransformStack(tang:qb2A_TangibleObject, stack_out:qb2TransformStack):void
		{
			s_affineMatrix1.setToTranslation(tang.getPosition());
			s_affineMatrix2.setToRotation( tang.getRotation());
			
			stack_out.pushAndConcat(s_affineMatrix1);
			stack_out.pushAndConcat(s_affineMatrix2);
		}
		
		public static function popFromTransformStack(tang:qb2A_TangibleObject, stack_out:qb2TransformStack):void
		{
			stack_out.pop();
			stack_out.pop();
		}
		
		public static function calcSurfaceArea(geometry_nullable:qb2A_GeoEntity, propertyMap:qb2PropMap):Number
		{
			var surfaceArea:Number = 0.0;
			
			if ( geometry_nullable != null )
			{
				var geomAsSurface:qb2A_GeoSurface = geometry_nullable as qb2A_GeoSurface;
				
				if ( geomAsSurface != null )
				{
					surfaceArea = geomAsSurface.calcSurfaceArea();
				}
				else
				{
					var geomAsCurve:qb2A_GeoCurve = geometry_nullable as qb2A_GeoCurve;
					
					if ( geomAsCurve != null )
					{
						var thickness:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.CURVE_THICKNESS);
						
						surfaceArea = thickness * geomAsCurve.calcLength();
						
						//TODO: Include surface area of rounded vs. angled corners, and endcaps?
					}
					else
					{
						var geomAsPoint:qb2A_GeoCoordinate = geometry_nullable as qb2A_GeoCoordinate;
						
						if ( geomAsPoint != null )
						{
							var radius:Number = propertyMap.getPropertyOrDefault(qb2S_PhysicsProps.POINT_RADIUS);
							
							surfaceArea = qb2U_Formula.circleArea(radius);
						}
					}
				}
			}
			
			return surfaceArea;
		}
		
		public static function transform(tang:qb2A_TangibleObject, matrix:qb2I_Matrix, options:qb2F_TransformOption):void
		{
			var scaleMass:Boolean = options.overlaps(qb2F_TransformOption.TRANSFORM_MASS);
			var scaleJointAnchors:Boolean = options.overlaps(qb2F_TransformOption.TRANSFORM_JOINT_ANCHORS);
			var scaleActor:Boolean = options.overlaps(qb2F_TransformOption.TRANSFORM_ACTORS);
		}
		
		public static function scale(tang:qb2A_TangibleObject, values:qb2GeoVector, options:qb2F_TransformOption, origin_nullable:qb2GeoPoint = null):void
		{
			
			/*
			
			var xValue:Number = vector.getX();
			var yValue:Number = vector.getY();
			
			var asRigid:qb2I_RigidObject = tang as qb2I_RigidObject;
			
			if ( asRigid )
			{
				asRigid.getPosition().scale(vector, origin);
					
				if ( scaleJointAnchors )
				{
					var iterator:qb2AttachedJointIterator = qb2AttachedJointIterator.getInstance(asRigid);
			
					for ( var joint:qb2Joint; joint = iterator.next(); )
					{
						var jointWithTwoObjects:qb2I_JointWithTwoObjects = joint as qb2I_JointWithTwoObjects;
						
						if ( jointWithTwoObjects )
						{
							if ( jointWithTwoObjects.getObjectA() == tang )
							{
								jointWithTwoObjects.getLocalAnchorA().scale(vector, origin);
							}
							else if ( jointWithTwoObjects.getObjectB() == tang )
							{
								jointWithTwoObjects.getLocalAnchorA().scale(vector, origin);
							}
						}
						else
						{
							var jointWithOneObject:qb2I_JointWithOneObject = joint as qb2I_JointWithOneObject;
							if ( jointWithOneObject.getObject() == asRigid )
							{
								jointWithOneObject.getLocalAnchor().scale(vector, origin);
							}
						}
					}
				}
				
				if ( tang.getActor() && scaleActor )
				{
					tang.getActor().scale(xValue, yValue);
				}
			}
			
			if ( tang as qb2A_PhysicsObjectContainer )
			{
				var forwardOrigin:qb2GeoPoint = tang is qb2Group ? origin : null;
				
				//var subOrigin:qb2GeoPoint = physObject as qb2Body ? null : origin; // objects belonging to bodies are scaled relative to the body's origin.
				
				var childIterator:qb2ChildIterator = qb2ChildIterator.getInstance(tang as qb2A_PhysicsObjectContainer, qb2A_TangibleObject);
				for ( var subTang:qb2A_TangibleObject; subTang = childIterator.next() as qb2A_TangibleObject; )
				{
					scale(subTang, vector, forwardOrigin, scaleMass, scaleJointAnchors, scaleActor);
				}
			}
			else if ( tang as qb2Shape )
			{
				var geom:qb2A_GeoEntity = (tang as qb2Shape).getGeometry();
				
				if ( geom )
				{
					geom.scale(vector, origin);
				}
				
				if ( scaleMass )
				{
					var scaling:Number 	 = xValue * yValue;
					tang.setMass(tang.getEffectiveProp(qb2S_PhysicsProps.MASS) * scaling);
				}
			}*/
		}
	}
}