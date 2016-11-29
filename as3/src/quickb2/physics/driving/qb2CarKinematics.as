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

package quickb2.physics.driving
{
	import quickb2.lang.*
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2CarKinematics
	{
		internal var m_longSpeed:Number = 0;
		internal var m_latSpeed:Number = 0;
		internal var m_longAccel:Number = 0;
		internal var m_latAccel:Number = 0;
		internal var m_overallSpeed:Number = 0;
		
		public function getLongSpeed():Number
		{
			return m_longSpeed;
		}
			
		public function getLatSpeed():Number
		{
			return m_latSpeed;
		}
			
		public function getLongAccel():Number
		{
			return m_longAccel;
		}
			
		public function getLatAccel():Number
		{
			return m_latAccel;
		}
			
		public function getOverallSpeed():Number
		{
			return m_overallSpeed;
		}
	}
}