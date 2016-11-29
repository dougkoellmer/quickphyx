package quickb2.physics.utils 
{
	import quickb2.lang.foundation.qb2UtilityClass;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.curves.qb2GeoLine;
	import quickb2.physics.core.iterators.qb2AttachedObjectIterator;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2U_Joint extends qb2UtilityClass
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilLine:qb2GeoLine = new qb2GeoLine();
		
		private static function calcGlobalAnchor(tang_nullable:qb2A_TangibleObject, anchor:qb2GeoPoint, point_out:qb2GeoPoint):void
		{
			if ( tang_nullable == null )
			{
				point_out.copy(anchor);
			}
			else
			{
				qb2U_Geom.calcGlobalPoint(tang_nullable, anchor, point_out);
			}
		}
		
		public static function calcGlobalAnchorA(joint:qb2Joint, point_out:qb2GeoPoint):void
		{
			calcGlobalAnchor(joint.getObjectA(), joint.getLocalAnchorA(), point_out);
		}
		
		public static function calcGlobalAnchorB(joint:qb2Joint, point_out:qb2GeoPoint):void
		{
			calcGlobalAnchor(joint.getObjectB(), joint.getLocalAnchorB(), point_out);
		}
		
		public static function calcAnchorLine(joint:qb2Joint, line_out:qb2GeoLine):void
		{
			calcGlobalAnchor(joint.getObjectA(), joint.getLocalAnchorA(), line_out.getPointA());
			calcGlobalAnchor(joint.getObjectB(), joint.getLocalAnchorB(), line_out.getPointB());
		}
		
		public static function calcAnchorDistance(joint:qb2Joint):Number
		{
			calcAnchorLine(joint, s_utilLine);
			
			return s_utilLine.calcLength();
		}
	}
}