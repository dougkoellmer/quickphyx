package quickb2.physics.utils 
{
	import Box2DAS.Common.V2;
	import flash.utils.Dictionary;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2E_RuntimeErrorCode;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.physics.core.iterators.qb2AttachedObjectIterator;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.lang.*;
	import quickb2.lang.operators.*;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2U_Force extends qb2UtilityClass
	{
		public static function applyRadialImpulse(group:qb2Group, focalPoint:qb2GeoPoint, impulse:Number = 0, radiusOfEffect:Number = Number.MAX_VALUE, dropOff:Number = 0, angularOffset:Number = 0, scaleMasses:Boolean = false):void
		{			
			applyRadial(group, true, focalPoint, impulse, radiusOfEffect, dropOff, angularOffset, scaleMasses);
		}
		
		public static function applyRadialForce(group:qb2Group, focalPoint:qb2GeoPoint, force:Number, radiusOfEffect:Number = Number.MAX_VALUE, dropOff:Number = 0, angularOffset:Number = 0, scaleMasses:Boolean = false):void
		{
			applyRadial(group, false, focalPoint, force, radiusOfEffect, dropOff, angularOffset, scaleMasses);
		}
		
		private static function applyRadial(group:qb2Group, impulse:Boolean, focalPoint:qb2GeoPoint, scalar:Number = 0, radiusOfEffect:Number = Number.MAX_VALUE, dropOff:Number = 0, angularOffset:Number = 0, scaleMasses:Boolean = false):void
		{
			/*for ( var i:int = 0; i < _objects.length; i++ )
			{
				var object:qb2A_PhysicsObject = _objects[i];
				
				if ( !(object is qb2A_PhysicsObject) )  continue;
				
				var tang:qb2A_PhysicsObject = object as qb2A_PhysicsObject;
				
				if ( tang is qb2Group )
				{
					(tang as qb2Group).applyRadial(impulse, focalPoint, scalar, radiusOfEffect, dropOff, angularOffset, scaleMasses);
				}
				else
				{
					var centroid:qb2GeoPoint = tang.calcCenterOfMass();
					var vec:qb2GeoVector = centroid.minus(focalPoint);
					var vecLength:Number = vec.length;
					if ( vecLength > radiusOfEffect || vecLength == 0 )  continue;
					vec.rotate(angularOffset);
					
					var ratio:Number = 1 - (vecLength / radiusOfEffect) * dropOff;
					var thisScalar:Number = scalar * ratio;
					if ( scaleMasses )  thisScalar *= tang.mass;
					
					vec.normalize().scale(thisScalar);
					
					impulse ? tang.applyLinearImpulse(centroid, vec) : tang.applyForce(centroid, vec);
				}
			}*/
			
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
		}
			
		public static function applyUniformImpulse(group:qb2Group, impulseVector:qb2GeoVector, scaleMasses:Boolean = false):void
		{
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(group, qb2I_RigidObject);
			var centerOfMass:qb2GeoPoint = new qb2GeoPoint();
			
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next(); )
			{
				var vector:qb2GeoVector = impulseVector;
				if ( scaleMasses )
				{
					var tempVector:qb2GeoVector = qb2_poolNew(qb2GeoVector);
					vector = impulseVector.clone() as qb2GeoVector;
					tempVector.set(rigid.getEffectiveProp(qb2S_PhysicsProps.MASS), rigid.getEffectiveProp(qb2S_PhysicsProps.MASS));
					vector.scaleByNumber(tempVector);
					qb2_poolDelete(tempVector);
				}
				rigid.calcCenterOfMass(centerOfMass)
				
				rigid.applyLinearImpulse(centerOfMass, vector);
				
				iterator.skipBranch(); // don't descend down further into qb2Body's.
			}
		}
		
		public static function applyUniformForce(group:qb2Group, forceVector:qb2GeoVector, scaleMasses:Boolean = false):void
		{
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(group, qb2I_RigidObject);
			var centerOfMass:qb2GeoPoint = new qb2GeoPoint();
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next() as qb2I_RigidObject; )
			{
				var vector:qb2GeoVector = forceVector;
				if ( scaleMasses )
				{
					var tempVector:qb2GeoVector = qb2_poolNew(qb2GeoVector);
					vector = forceVector.clone() as qb2GeoVector;
					tempVector.set(rigid.getEffectiveProp(qb2S_PhysicsProps.MASS), rigid.getEffectiveProp(qb2S_PhysicsProps.MASS));
					vector.scaleByNumber(tempVector);
					qb2_poolDelete(tempVector);
				}
				rigid.calcCenterOfMass(centerOfMass)
				
				rigid.applyForce(centerOfMass, vector);
				
				iterator.skipBranch(); // don't descend down further into qb2Body's.
			}
		}
		
		public static function applyUniformTorque(group:qb2Group, torque:Number, scaleMasses:Boolean = false):void
		{
			if ( !group.getChildCount() )  return;
			
			var thisCentroid:qb2GeoPoint = new qb2GeoPoint();
			var tangCentroid:qb2GeoPoint = new qb2GeoPoint();
			group.calcCenterOfMass(thisCentroid);
			
			var scaler:qb2GeoVector = new qb2GeoVector();
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(group, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = iterator.next() as qb2I_RigidObject; )
			{
				rigid.calcCenterOfMass(tangCentroid);
				var tangent:qb2GeoVector = tangCentroid.minus(thisCentroid);
				tangent.normalize();
				
				tangent.rotate( Math.PI / 2);
				var force:Number = torque / tangCentroid.calcDistanceTo(thisCentroid);
				
				force = scaleMasses ? force * rigid.getEffectiveProp(qb2S_PhysicsProps.MASS) : force;
				scaler.set(force, force);
				tangent.scaleByNumber(scaler);
				
				rigid.applyForce(tangCentroid, tangent);
				
				iterator.skipBranch();
			}
		}
	}
}