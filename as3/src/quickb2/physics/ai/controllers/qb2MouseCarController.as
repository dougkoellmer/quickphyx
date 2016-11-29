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

package quickb2.physics.ai.controllers 
{
	
	import quickb2.math.general.*;
	import quickb2.math.geo.*;
	import flash.display.*;
	import TopDown.objects.*;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2MouseCarController extends qb2MouseController
	{
		public var maxThrottleDistance:Number = 100;
		public var brakeDistance:Number = 33;
		public var brakeWithThrottle:Boolean = false;
		public var variableThrottle:Boolean = true;
		
		public function qb2MouseCarController(mouseSource:Stage)
		{
			super(mouseSource);
		}
		
		protected override function activated():void
		{
			if ( host is qb2CarBody )
			{
				brainPort.open = true;
				super.activated();
			}
			else
			{
				brainPort.open = false;
			}
		}
		
		protected override function update():void
		{
			super.update();
			
			brainPort.clear();
			
			var mousePosition:qb2GeoPoint = positionalSpace ? new qb2GeoPoint(positionalSpace.mouseX, positionalSpace.mouseY) : mouse.position;
			var direction:qb2GeoVector = mousePosition.minus(host.position);
			var pullLength:Number = variableThrottle ? direction.length : maxThrottleDistance;
			direction.normalize();
			lastDirection.copy(direction);
			
			if ( pullLength <= brakeDistance && (brakeWithThrottle || !brakeWithThrottle && !mouseIsDown) )
			{
				brainPort.NUMBER_PORT_3 = qb2U_Math.constrain(1 - pullLength/brakeDistance, 0, 1);
			}
			
			if ( direction.calcLengthSquared() == 0 )  return;
			
			var carNormal:qb2GeoVector = host.getNormal();
			var maxTurnAngle:Number = (host as qb2CarBody).maxTurnAngle;
			var turnAngle:Number = carNormal.signedAngleTo(direction);
			
			var absTurnAngle:Number = Math.abs(turnAngle);
			var absThrottle:Number = qb2U_Math.constrain(pullLength / maxThrottleDistance, 0, 1);
			var upDown:Number = Math.abs(turnAngle) > qb2S_Math.PI - maxTurnAngle ? -absThrottle : absThrottle;
			brainPort.NUMBER_PORT_1 = mouseIsDown ? upDown : 0;
			
			if ( upDown > 0 )
			{
				brainPort.NUMBER_PORT_2 = qb2U_Math.constrain(turnAngle, -maxTurnAngle, maxTurnAngle);
			}
			else
			{
				brainPort.NUMBER_PORT_2 = qb2U_Math.constrain( (qb2U_Math.sign(turnAngle)*(qb2S_Math.PI-absTurnAngle)), -maxTurnAngle, maxTurnAngle);
			}
		}
	}
}