package quickb2.physics.core 
{
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2Flag;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.backend.*;
	import quickb2.physics.core.backend.qb2I_BackEndRepresentation;
	import quickb2.physics.core.bridge.qb2P_Flusher;
	
	import quickb2.physics.core.bridge.qb2PF_DirtyFlag;
	import quickb2.physics.core.bridge.qb2PF_SimulatedObjectFlag;
	import quickb2.physics.core.tangibles.qb2A_PhysicsObjectContainer;
	import quickb2.physics.core.tangibles.qb2I_RigidObject;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2PropMap;
	
	/**
	 * ...
	 * @author 
	 */
	[qb2_abstract] public class qb2A_SimulatedPhysicsObject extends qb2A_PhysicsObject
	{		
		private var m_representation:qb2I_BackEndRepresentation = null;
		
		public function qb2A_SimulatedPhysicsObject() 
		{
			include "../../lang/macros/QB2_ABSTRACT_CLASS";
			
			init();
		}
		
		private function init():void
		{
		}
	
		public function getBackEndRepresentation():qb2I_BackEndRepresentation
		{
			qb2P_Flusher.getInstance().flush();
			
			return m_representation;
		}
		
		internal function setBackEndRepresentation(backEndRep:qb2I_BackEndRepresentation):void
		{
			m_representation = backEndRep;
		}
		
		protected override function copy_protected(source:*):void
		{
			//TODO: Implement
		}
		
		internal override function onStepComplete_internal():void
		{
			super.onStepComplete_internal();
			
			if ( m_representation != null )
			{
				m_representation.onStepComplete();
			}
		}
	}
}