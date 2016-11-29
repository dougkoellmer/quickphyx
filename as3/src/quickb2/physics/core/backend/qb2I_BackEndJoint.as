package quickb2.physics.core.backend 
{
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.physics.core.joints.qb2Joint;
	import quickb2.physics.core.prop.qb2CoordProp;
	import quickb2.thirdparty.box2d.joints.qb2Box2dJointRepresentation;
	
	/**
	 * ...
	 * @author 
	 */
	public interface qb2I_BackEndJoint extends qb2I_BackEndRepresentation
	{
		function isSimulating():Boolean;
		
		function onAttachmentRemoved():void;
		
		function setJointAnchor(anchorProperty:qb2CoordProp, transform_nullable:qb2AffineMatrix, anchor:qb2GeoPoint):void;
	}
}