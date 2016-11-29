package quickb2.debugging.testing 
{
	import quickb2.lang.types.qb2Class;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2A_DefaultTest implements qb2I_Test
	{
		private var m_name:String;
		
		public function qb2A_DefaultTest(name_nullable:String = null) 
		{
			m_name = name_nullable == null ? (this as Object).constructor.toString() : name_nullable;
		}
		
		public function getName():String
		{
			if ( m_name == null )
			{
				return qb2Class.getInstance((this as Object).constructor).getSimpleName();
			}
			else
			{
				return m_name;
			}
		}
		
		[qb2_virtual] public function onBefore():void
		{
			
		}
		
		[qb2_abstract] public function run(asserter:qb2Asserter):void
		{
			
		}
		
		[qb2_virtual] public function onAfter():void
		{
			
		}
	}
}