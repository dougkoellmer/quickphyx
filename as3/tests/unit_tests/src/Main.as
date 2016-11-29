package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import quickb2.debugging.testing.qb2I_Test;
	import quickb2.debugging.testing.qb2TestSuite;
	import quickb2.debugging.testing.qb2TestSuiteResult;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.physics.core.property.qb2E_PhysicsProperty;
	import quickb2.physics.core.tangibles.qb2Group;
	import quickb2.physics.core.tangibles.qb2World;
	import quickb2.physics.fields.qb2E_FieldProperty;
	import quickb2.utils.property.qb2ImmutablePropertyMap;
	import quickb2.utils.property.qb2MutablePropertyMap;
	
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite 
	{
		public function Main():void
		{
			var testSuite:qb2TestSuite = new qb2TestSuite();
			
			testSuite.addTest(new MassTest());
			testSuite.addTest(new PropertyTest());
			testSuite.addTest(new CompositeCurveIterationTest());
			testSuite.addTest(new AncestorBodyTest());
			testSuite.addTest(new WorldTest());
			
			
			var result:qb2TestSuiteResult = testSuite.run();
			
			trace(result.convertToString());
		}
	}
}