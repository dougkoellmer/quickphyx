package quickb2.physics.core.bridge 
{
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.utils.prop.qb2PropMap;
	import quickb2.utils.prop.qb2MutablePropFlags;
	
	/**
	 * ...
	 * @author ...
	 */
	public interface qb2PI_FlushTreeVisitor 
	{
		function onPreVisit(node_nullable:qb2P_FlushNode, object:qb2A_PhysicsObject, parentCollector_nullable:qb2P_FlushCollector, changeFlags_out:qb2MutablePropFlags):void;
		
		function onVisit(node_nullable:qb2P_FlushNode, collector:qb2P_FlushCollector, parentCollector_nullable:qb2P_FlushCollector):void;
		
		function onPostVisit(object:qb2A_PhysicsObject, originalNodeDirtyFlags:int):void;
		
		function onFlushComplete(world:qb2World):void;
		
		function onShortDelayVisit(collector:qb2P_FlushCollector):void;
	}
}