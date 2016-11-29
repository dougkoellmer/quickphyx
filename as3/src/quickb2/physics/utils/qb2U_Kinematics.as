package quickb2.physics.utils 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Kinematics 
	{
		private static const s_treeIterator:qb2TreeIterator = new qb2TreeIterator();
		
		public static function calcLinearVelocityAtPoint(physicsObject:qb2A_TangibleObject, point:qb2GeoPoint, vector_out:qb2GeoVector):void
		{
			/*if ( physicsObject._bodyB2 )
			{
				var conversion:Number = physicsObject.getWorldPixelsPerMeter();
				var pointB2:V2 = new V2(point.m_x / conversion, point.m_y / conversion);
				var velVecB2:V2 = physicsObject._bodyB2.GetLinearVelocityFromWorldPoint(pointB2);
				return new qb2GeoVector(velVecB2.x, velVecB2.y);
			}
			else if ( physicsObject.m_ancestorBody )
			{
				if ( physicsObject.m_ancestorBody._bodyB2 )
				{
					return calcLinearVelocityAtPoint(physicsObject.m_ancestorBody, qb2U_Geom.calcWorldPoint(physicsObject.m_parent, point));
				}
				else
				{
					qb2_throw(new qb2Error(qb2E_ErrorCode.NOT_IMPLEMENTED));
				}
			}
			else if ( physicsObject as qb2Group )
			{
				qb2_throw(new qb2Error(qb2E_ErrorCode.NOT_IMPLEMENTED));
				
				/*var asGroup:qb2Group = this as qb2Group;
				var rigids:Vector.<qb2I_RigidObject> = asGroup.getRigidsAtPoint(point);
				if ( rigids )
				{
					var highestRigid:qb2I_RigidObject = rigids[rigids.length - 1];
					return highestRigid.getLinearVelocityAtPoint(point);
				}*/
			//}
		}
		
		public static function calcLinearVelocityAtLocalPoint(physicsObject:qb2A_TangibleObject, point:qb2GeoPoint, vector_out:qb2GeoVector):void
		{
			//TODO: Make this purely quickb2 code...nothing to do with box2d...
			
			/*if ( physicsObject._bodyB2 )
			{
				var conversion:Number = physicsObject.getWorldPixelsPerMeter();
				var pointB2:V2 = new V2(point.getX() / conversion, point.getY() / conversion);
				var velVecB2:V2 = physicsObject._bodyB2.GetLinearVelocityFromLocalPoint(pointB2);
				return new qb2GeoVector(velVecB2.x, velVecB2.y);
			}
			else if ( physicsObject.m_ancestorBody )
			{
				if ( physicsObject.m_ancestorBody._bodyB2 )
				{
					var ancestorBodyLocalPoint:qb2GeoPoint = qb2U_Geom.calcLocalPoint(physicsObject.m_ancestorBody, qb2U_Geom.calcWorldPoint(physicsObject, point));
					return calcLinearVelocityAtLocalPoint(physicsObject.m_ancestorBody, ancestorBodyLocalPoint);
				}
				else
				{
					qb2_throw(new qb2Error(qb2E_ErrorCode.NOT_IMPLEMENTED));
				}
			}
			else if ( physicsObject as qb2Group )
			{
				qb2_throw(new qb2Error(qb2E_ErrorCode.NOT_IMPLEMENTED));
				/*var asGroup:qb2Group = this as qb2Group;
				var rigids:Vector.<qb2I_RigidObject> = asGroup.getRigidsAtPoint(point);
				if ( rigids )
				{
					var highestRigid:qb2I_RigidObject = rigids[rigids.length - 1];
					return highestRigid.calcLinearVelocityAtPoint(point);
				}*/
			//}
		}
		
		public static function calcAvgLinearVelocity(group:qb2Group, vector_out:qb2GeoVector):void
		{
			vector_out.set(0, 0);
			s_treeIterator.initialize(group, qb2I_RigidObject);
			var descendantCount:int = 0;
			var scaleVector:qb2GeoVector = new qb2GeoVector();
			for ( var rigid:qb2I_RigidObject; rigid = s_treeIterator.next() as qb2I_RigidObject; )
			{
				vector_out.translateBy(rigid.getLinearVelocity());
				descendantCount++;
				s_treeIterator.skipBranch();
			}
			
			if ( descendantCount )
			{
				var scaler:Number = 1.0 / (descendantCount as Number);
				scaleVector.set(scaler, scaler);
				vector_out.scaleBy(scaleVector);
			}
		}
		
		public static function setAvgLinearVelocity(group:qb2Group, vector:qb2GeoVector):void
		{
			s_treeIterator.initialize(group, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = s_treeIterator.next() as qb2I_RigidObject; )
			{
				rigid.getLinearVelocity().copy(vector);
				
				s_treeIterator.skipBranch();
			}
		}

		public static function calcAvgAngularVelocity(group:qb2Group):Number
		{
			var average:Number = 0;
			s_treeIterator.initialize(group, qb2I_RigidObject);
			var descendantCount:int = 0;
			for ( var rigid:qb2I_RigidObject; rigid = s_treeIterator.next() as qb2I_RigidObject; )
			{
				average += rigid.getAngularVelocity();
				descendantCount++;
				s_treeIterator.skipBranch();
			}
			
			if ( descendantCount )  average /= descendantCount;
			
			return average;
		}
		
		public static function setAvgAngularVelocity(group:qb2Group, radsPerSec:Number):void
		{
			s_treeIterator.initialize(group, qb2I_RigidObject);
			for ( var rigid:qb2I_RigidObject; rigid = s_treeIterator.next() as qb2I_RigidObject; )
			{
				rigid.setAngularVelocity(radsPerSec);
				
				s_treeIterator.skipBranch();
			}
		}
	}
}