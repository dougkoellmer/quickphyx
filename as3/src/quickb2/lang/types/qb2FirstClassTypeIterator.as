package quickb2.lang.types 
{
	import quickb2.utils.iterator.qb2I_Iterator;
	import quickb2.math.geo.bounds.qb2F_GeoBoundingBoxContainment;
	import quickb2.math.geo.coords.qb2GeoPoint;
	
	
	import quickb2.utils.*;
	
	
	/**
	 * 
	 * @author 
	 */
	public class qb2FirstClassTypeIterator implements qb2I_Iterator
	{
		private var m_currentType:qb2A_FirstClassType = null;
		private var m_progress:int = 0;
		private var m_depth:qb2E_FirstClassTypeIteratorDepth = null;
		private var m_returnType:Class = null;
		private const m_iteratorQueue:qb2OptVector = new qb2OptVector();
		
		public function qb2FirstClassTypeIterator(firstClassType:qb2A_FirstClassType = null, eDepth:qb2E_FirstClassTypeIteratorDepth = null, T_extends_qb2A_FirstClassType:Class = null)
		{
			initialize(firstClassType, eDepth, T_extends_qb2A_FirstClassType);
		}

		public function initialize(firstClassType:qb2A_FirstClassType, eDepth:qb2E_FirstClassTypeIteratorDepth = null, T_extends_qb2A_FirstClassType:Class = null):void
		{
			m_currentType = firstClassType;
			m_progress = 0;
			
			if (m_currentType != null)
			{
				m_currentType.populateInterfaceArray();
			}
			
			m_depth = eDepth ? eDepth : qb2E_FirstClassTypeIteratorDepth.ALL;
			m_returnType = T_extends_qb2A_FirstClassType ? T_extends_qb2A_FirstClassType : qb2A_FirstClassType;
			
			if ( m_currentType == null )  return;
			
			if ( m_depth == qb2E_FirstClassTypeIteratorDepth.ALL && m_returnType != qb2Class )
			{
				var currentTypeAsClass:qb2Class = m_currentType as qb2Class;
				
				if ( currentTypeAsClass != null )
				{
					m_iteratorQueue.push(currentTypeAsClass.getSuperClass());
				}
				
				for ( var i:int = 0; i < m_currentType.m_immediateInterfaces.length; i++ )
				{
					m_iteratorQueue.push(m_currentType.m_immediateInterfaces[i]);
				}
			}
		}
		
		public function next():*
		{
			var nextObject:qb2A_FirstClassType = null;
			
			var currentTypeAsClass:qb2Class = m_currentType as qb2Class;
			
			if ( m_depth == qb2E_FirstClassTypeIteratorDepth.ALL )
			{
				if ( m_returnType == qb2Class )
				{
					if ( currentTypeAsClass != null )
					{
						nextObject = currentTypeAsClass.getSuperClass();
						m_currentType = nextObject;
					}
				}
				else
				{
					if ( m_progress < m_iteratorQueue.getLength() )
					{
						nextObject = m_iteratorQueue.getObject(m_progress);
						
						var nextObjectAsClass:qb2Class = nextObject as qb2Class;
						
						if ( nextObjectAsClass != null )
						{
							var nextObjectSuperClass:qb2Class = nextObjectAsClass.getSuperClass();
							if ( nextObjectSuperClass != null )
							{
								m_iteratorQueue.push(nextObjectSuperClass);
							}
						}
						
						for ( var i:int = 0; i < nextObject.m_immediateInterfaces.length; i++ )
						{
							m_iteratorQueue.push(nextObject.m_immediateInterfaces[i]);
						}
					}
					
					m_progress++;
				}
			}
			else if ( m_depth == qb2E_FirstClassTypeIteratorDepth.IMMEDIATE )
			{
				if ( m_returnType == qb2Class)
				{
					if ( currentTypeAsClass != null && m_progress == 0 )
					{
						nextObject = currentTypeAsClass.getSuperClass();
					}
				}
				else if (  m_returnType == qb2Interface )
				{
					if( m_progress < m_currentType.m_immediateInterfaces.length )
					{
						nextObject = m_currentType.m_immediateInterfaces[m_progress];
					}
				}
				else if ( m_returnType == qb2A_FirstClassType )
				{
					if ( currentTypeAsClass != null )
					{
						if ( m_progress == 0 )
						{
							nextObject = currentTypeAsClass.getSuperClass();
						}
						else if( m_progress-1 < m_currentType.m_immediateInterfaces.length )
						{
							nextObject = m_currentType.m_immediateInterfaces[m_progress-1];
						}
					}
					else
					{
						if( m_progress < m_currentType.m_immediateInterfaces.length )
						{
							nextObject = m_currentType.m_immediateInterfaces[m_progress];
						}
					}
				}
				
				m_progress++;
			}
			
			return nextObject;
		}
	}
}