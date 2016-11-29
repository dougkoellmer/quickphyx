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

package quickb2.physics.extras.todo 
{
	import quickb2.objects.tangibles.qb2Group;
	
	/** TODO: This should be a bunch of bodies connected with joints (piston springs or revolute joints) with parameters to change flexibility, stiffness, etc., which in
	 *        in turn edit the joints' properties.  The trick here is rendering a nice smooth curve for rope, especially when it's kinked.  It should also have an option 
	 *        to simulate until it's in a nice catenary arc, so when the user adds it to the world it isn't flopping around.
	 * 
	 * @private
	 * @author Doug Koellmer
	 */	 
	public class qb2Rope extends qb2Group
	{
		
		public function qb2Rope() 
		{
			
		}
		
	}

}