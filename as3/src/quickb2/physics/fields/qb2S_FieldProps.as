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

package quickb2.physics.fields
{
	import quickb2.lang.*;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.operators.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.physics.core.prop.qb2PhysicsProp;
	import quickb2.physics.core.prop.qb2S_PhysicsProps;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2I_Prop;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2S_FieldProps extends qb2S_PhysicsProps
	{
		include "../../lang/macros/QB2_ENUM";
		
		// for gravity well
		
		/// Should the force be multiplied by the inverse square of the distance?
		public static const USE_INVERSE_SQUARE_LAW:qb2PhysicsProp					= new qb2PhysicsProp(true);
		
		/**
		 * A unitless constant by which to multiply the force. In nature, this constant is very small, because gravity
		 * is an extremely weak force. Here it will generally be quite large because your objects will usually have
		 * human-scale sizes and masses.
		 */
		public static const GRAVITY_CONSTANT:qb2PhysicsProp							= new qb2PhysicsProp(5000.0); // also for planetary gravity
		
		/// An imaginary mass for the well itself, independent of the well's actual mass, which will usually be zero.
		public static const WELL_MASS:qb2PhysicsProp								= new qb2PhysicsProp(1);
		
		/// The minimum horizon keeps forces from scaling too much at small distances.
		public static const MIN_HORIZON:qb2PhysicsProp								= new qb2PhysicsProp(10); // also for vortex
		
		/// Cancels forces past a maximum distance.
		public static const MAX_HORIZON:qb2PhysicsProp								= new qb2PhysicsProp(500); // also for vortex
		
		
		
	
		
		// for vibrator field
		public static const SCALE_IMPULSE_BY_MASS:qb2PhysicsProp					= new qb2PhysicsProp(true);
		public static const RANDOMIZE_IMPULSE:qb2PhysicsProp						= new qb2PhysicsProp(false);
		public static const MIN_IMPULSE:qb2PhysicsProp								= new qb2PhysicsProp(5.0);
		public static const MAX_IMPULSE:qb2PhysicsProp								= new qb2PhysicsProp(5.0);
		
		
		
		
		// for vortex
		
		public static const SIMULATE_DRAG:qb2PhysicsProp							= new qb2PhysicsProp(true); // also for wind field
		
		/**
		 * Is this a free vortex like a toilet flushing, where the water drains down freely?  Or is this an induced vortex, like stirring your tea?
		 * A free vortex applies the most force at its center, while a non-free vortex applies the most force at its outer horizon.
		 */
		public static const IS_FREE_VORTEX:qb2PhysicsProp							= new qb2PhysicsProp(true);
		
		/**
		 * How fast the vortex is spinning.  This is measured near its MIN_HORIZON if IS_FREE_VORTEX==true, near its MAX_HORIZON if IS_FREE_VORTEX==false.
		 */
		public static const VORTEX_SPEED:qb2PhysicsProp							= new qb2PhysicsProp(15.0);
		public static const AIR_DENSITY:qb2PhysicsProp							= new qb2PhysicsProp(3.0); // also for wind field
		public static const VORTEX_ANGLE:qb2PhysicsProp							= new qb2PhysicsProp(135 * (Math.PI/180.0));
		
		
		public function qb2E_FieldProperty(defaultValue:*)
		{
			super(defaultValue);
		}
	}
}