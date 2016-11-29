package quickb2.debugging.testing 
{
	public interface qb2I_Test 
	{
		function getName():String;
		
		function onBefore():void;
		function run(asserter:qb2Asserter):void;
		function onAfter():void;
	}
}