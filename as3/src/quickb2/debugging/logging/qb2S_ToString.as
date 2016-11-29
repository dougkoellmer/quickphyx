/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package quickb2.debugging.logging
{
	import quickb2.lang.foundation.qb2SettingsClass;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public final class qb2S_ToString extends qb2SettingsClass
	{
		/// The two characters indicating the beginning and end of a class trace.
		public static var classBrackets:String   = "[]";
		
		/// The two characters indicating the beginning and end of the variable list of a class.
		public static var variableBrackets:String     = "()";
		
		/// The character(s) to signify a variable's value.
		public static var equalityCharacter:String = "=";
		
		public static var stringQuoteCharacter:String = "'";
		
		/// The character(s) delimiting the list of variables for a class.
		public static var variableDelimiter:String      = ", ";
		
		/// The precision to which decimals are printed.
		public static var defaultFloatingPointPrecision:int = 2;
		
		/// The base with which integers are printed.
		public static var defaultIntegerBase:int = 10;
		
		/// Whether strings made with qb2U_ToString have newlines and indenting for nested objects.
		public static var multiline:Boolean = true;
		
		public static var nullString:String = "null";
		
		public static var useQualifiedClassNames:Boolean = false;
		
		/// Associates a list of class names to the variables that they should spit out for convertTo(String) calls.
		/*public static const classToVariableMap:Object = 
		{
			qb2World:                 {totalNumPolygons:null, totalNumCircles:null, totalNumJoints:null},
			qb2Body:                  {mass:null, position:null, rotation:null, linearVelocity:null, angularVelocity:null, childCount:null},
			qb2Group:                 {mass:null, numObjects:null},
			qb2CircleShape:           {mass:null, position:null, rotation:null, radius:null},
			qb2PolygonShape:          {mass:null, position:null, rotation:null, numVertices:null},
			
			qb2Chain:                 {mass:null, numLinks:null, length:null, linkWidth:null, linkThickness:null, linkLength:null},
			qb2FollowBody:            {position:null, rotation:null, targetPosition:null, targetRotation:null},
			qb2SoftPoly:              {mass:null, numVertices:null, subdivision:null, isCircle:null},
			qb2SoftRod:               {mass:null, numSegments:null, length:null, width:null},
			qb2TripSensor:            {position:null, tripTime:null, numVisitors:null, numTrippedVisitors:null},
			qb2Terrain:      	      {position:null, frictionZMultiplier:null},
			qb2SoundField:     	      {position:null, sound:null},
			qb2WindowWalls:           {},
			
			qb2Joint:         {collideConnected:null, isActive:null},
			qb2DistanceJoint:         {length:null, isRope:null, localAnchor1:null, localAnchor2:null, isActive:null},
			qb2MouseJoint:            {worldTarget:null, localAnchor:null, isActive:null},
			qb2PistonJoint:           {springK:null, hasLimits:null, localAnchor1:null, localAnchor2:null, isActive:null},
			qb2RevoluteJoint:         {springK:null, hasLimits:null, localAnchor1:null, localAnchor2:null, isActive:null},
			qb2WeldJoint:             {localAnchor1:null, localAnchor2:null, isActive:null},
			
			qb2GravityField:          {gravityVector:null},
			qb2GravityWellField:      {},
			qb2PlanetaryGravityField: {},
			qb2VibratorField:         {frequencyHz:null, impulseNormal:null, minImpulse:null, maxImpulse:null},
			qb2VortexField:           {},
			qb2WindField:             {windVector:null},
			
			qb2Event:                 {type:null},
			qb2ContainerEvent:        {type:null, parentObject:null, childObject:null},
			qb2ContactEvent:          {type:null, localObject:null, otherObject:null, contactPoint:null, contactNormal:null},
			qb2MassEvent:             {type:null, affectedObject:null, massChange:null, densityChange:null, areaChange:null},
			qb2RayCastEvent:          {type:null},
			qb2SubContactEvent:       {type:null, ancestorGroup:null, contactPoint:null, contactNormal:null},
			qb2TripSensorEvent:       {type:null, sensor:null, visitingObject:null},
			qb2StepEvent:           {type:null, object:null}
		};*/
	}
}