package quickb2.utils 
{
	import quickb2.debugging.logging.qb2Logger;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.types.*;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2ObjectPool
	{
		private static const s_logger:qb2Logger = qb2Logger.getInstanceByClass(qb2ObjectPool);
		
		private var m_constructor:qb2I_Constructor;
		private var m_delegate:qb2I_ObjectPoolDelegate;
		
		private const m_instances:Vector.<Object> = new Vector.<Object>();
		private var m_logicalSize:int = 0;
	
		public function qb2ObjectPool(constructor:qb2I_Constructor, delegate_nullable:qb2I_ObjectPoolDelegate = null) 
		{
			m_constructor = constructor;
			m_delegate = delegate_nullable;
		}
		
		public function garbageCollect():void
		{
			//TODO: implement;
			qb2U_Error.throwCode(qb2E_RuntimeErrorCode.NOT_IMPLEMENTED);
		}
		
		public function checkOut():*
		{
			var physicalSize:int = m_instances.length;
			
			while ( m_logicalSize >= physicalSize )
			{
				m_instances.push(null);
				
				physicalSize++;
			}
			
			if (m_instances[m_logicalSize] == null)
			{
				m_instances[m_logicalSize] = m_constructor.newInstance();
			}
			
			var instance:Object = m_instances[m_logicalSize];
			
			m_logicalSize++;
			
			if ( m_delegate != null )
			{
				m_delegate.onCheckOut(instance);
			}
			
			return instance;
		}
		
		public function checkIn(instance:Object):void
		{
			if ( m_logicalSize > 0 )
			{
				if ( m_delegate != null )
				{
					m_delegate.onCheckIn(instance);
				}
				
				m_instances[m_logicalSize-1] = instance;
			
				m_logicalSize--;
			}
			else
			{
				s_logger.logWarning("Pool for class is already empty.");
			}
		}
	}
}