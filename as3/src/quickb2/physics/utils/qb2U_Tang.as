package quickb2.physics.utils 
{
	import flash.utils.Dictionary;
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.physics.core.iterators.qb2AttachedObjectIterator;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2Group;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Tang extends qb2UtilityClass
	{
		private static const s_treeIterator:qb2TreeIterator = new qb2TreeIterator();
		private static const s_objectIterator:qb2AttachedObjectIterator = new qb2AttachedObjectIterator();
		
		public static function calcCenterOfMass(tang:qb2A_TangibleObject, point_out:qb2GeoPoint):void
		{
			var totMass:Number = 0;
			var totX:Number = 0, totY:Number = 0;
			
			s_treeIterator.initialize(tang, qb2A_TangibleObject);
			for ( var tang:qb2A_TangibleObject; (tang = s_treeIterator.next() as qb2A_TangibleObject) != null; )
			{
				var ithMass:Number = tang.getEffectiveProp(qb2S_PhysicsProps.MASS);
				calcCenterOfMass(tang, point_out);
				qb2U_Geom.calcGlobalPoint(tang, point_out, point_out, tang.getParent());
				
				totX += point_out.getX() * ithMass;
				totY += point_out.getY() * ithMass;
				totMass += ithMass;
			}
			
			if ( totMass )
			{
				point_out.set(totX / totMass, totY / totMass);
			}
			else
			{
				point_out.set(0, 0);
			}
		}
		
		public static function calcAttachedMass(tang:qb2A_TangibleObject, inWorldOnly:Boolean = true):Number
		{
			var totalMass:Number = 0;
			s_objectIterator.initialize(tang);
			
			var ancestorBodiesAlreadyVisited:Dictionary = new Dictionary(true);
			if ( tang.getAncestorBody() != null )
			{
				ancestorBodiesAlreadyVisited[tang.getAncestorBody()] = true;
			}
			
			for ( var attached:qb2A_TangibleObject; (attached = s_objectIterator.next()) != null; )
			{
				if ( inWorldOnly && attached.getWorld() == null )  continue;
				
				if ( attached.getAncestorBody() != null )
				{
					if ( !ancestorBodiesAlreadyVisited[attached.getAncestorBody()] )
					{
						totalMass += attached.getAncestorBody().getEffectiveProp(qb2S_PhysicsProps.MASS);
						
						ancestorBodiesAlreadyVisited[attached.getAncestorBody()] = true;
					}
				}
				else
				{
					if ( qb2U_Type.isKindOf(attached, qb2Group) )  continue;
					
					totalMass += attached.getEffectiveProp(qb2S_PhysicsProps.MASS);
				}
			}
			
			if ( tang.getAncestorBody() != null )
			{
				totalMass += tang.getAncestorBody().getEffectiveProp(qb2S_PhysicsProps.MASS) - tang.getEffectiveProp(qb2S_PhysicsProps.MASS);
			}
			
			return totalMass;
		}
	}
}