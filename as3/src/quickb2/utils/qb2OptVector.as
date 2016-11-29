package quickb2.utils 
{
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.lang.operators.qb2_assert;
	
	/**
	 * A wrapper of AS3's native vector class that is optimized for vectors that have a long lifetime and repeatedly have many elements added and removed.
	 * The optimization comes from never actually decreasing the length of the internal vector, only growing it, and thus avoiding unnecessary memory
	 * allocations and deallocations.
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2OptVector extends qb2A_Object
	{
		private const m_data:Vector.<*> = new Vector.<*>();
		private var m_length:int = 0;
		
		public function qb2OptVector() 
		{
			
		}
		
		public function copy(otherObject:*):void
		{
			copy_protected(otherObject);
		}
		
		protected override function copy_protected(otherObject:*):void
		{
			var otherVector:qb2OptVector = otherObject as qb2OptVector;
			if ( otherVector )
			{
				var otherLength:int = otherVector.getLength();
				this.setLength(otherLength, true);
				
				for ( var i:int = 0; i < otherLength; i++ )
				{
					this.setObject(i, otherVector.getObject(i));
				}
			}
		}
		
		/**
		 * Returns the logical length of the array, which can differ from the actual "physicsal" length of the internal vector.
		 * 
		 * @return
		 */
		public function getLength():int
		{
			return m_length;
		}
		
		public function getLast():*
		{
			return m_length != 0 ? m_data[m_length - 1] : null;
		}
		
		/**
		 * Sets the logical length of this vector.  If the new size is greater than the existing size, the new indeces will be filled with null.
		 * If the new size is less than the existing size, by default all references to the orphaned indeces will be set to null.
		 * 
		 * @param	length The new length.
		 * @param	clearOrphanedData Whether to null-out potentially orphaned indeces.  Only relevant if length decreases.
		 */
		public function setLength(length:int, clearOrphanedData:Boolean = true):void
		{
			if ( length < m_length )
			{
				if ( clearOrphanedData )
				{
					while ( length > m_length )
					{
						this.pop(clearOrphanedData);
					}
				}
			}
			else if ( length > m_length )
			{
				while (length > m_length )
				{
					this.push(null);
				}
			}
			
			m_length = length;
		}
		
		public function getObject(index:int):*
		{
			return m_data[index];
		}
		
		public function setObject(index:int, object:*):void
		{
			m_data[index] = object;
		}
		
		/**
		 * Actually clears the internal vector being used, setting both the logical and the physical length of this array to zero.
		 */
		public function clear():void
		{
			m_data.length = 0;
			m_length = 0;
		}
		
		/**
		 * Returns the internal data that qb2OptVector uses.  It's faster to use this directly for iterating,
		 * but remember to use qb2OptVector::getLength() as the size of the vector.
		 * 
		 * @return
		 */
		public function getData():Vector.<*>
		{
			return m_data;
		}
		
		public function remove(index:int):*
		{
			return m_data.splice(index, 1)[0];
		}
		
		/**
		 * Pushes one or more elements to the end of the vector, growing it if necessary.
		 * .
		 * @param	... args
		 */
		public function push(... args):void
		{
			var argCount:int = args.length ? args.length : 1;
			
			for ( var i:int = 0; i < argCount; i++ )
			{
				if ( m_length >= m_data.length )
				{
					m_data.push(null);
				}
				
				m_data[m_length] = i < args.length ? args[i] : m_data[m_length];
				
				m_length++;
			}
		}
		
		/**
		 * Pops an element from the end of the array, but maintains the internal vector's "physical" length.
		 * @return
		 */
		public function pop(clearOrphanedData:Boolean = true ):Object
		{
			m_length--;
			
			qb2_assert(m_length >= 0);
			
			var toReturn:Object = m_data[m_length];
			
			if ( clearOrphanedData )
			{
				m_data[m_length] = null;
			}
			
			return toReturn;
		}
	}
}