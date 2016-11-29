package quickb2.lang.errors 
{
	/**
	 * ...
	 * @author 
	 */
	public class qb2Throwable extends Error
	{
		public function qb2Throwable(message:String, id:int) 
		{
			super(message, id);
			
			include "../macros/QB2_ABSTRACT_CLASS";
		}
	}
}