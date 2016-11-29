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

package quickb2.display.immediate.style
{
	import quickb2.display.retained.qb2I_Actor;
	import quickb2.lang.*;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.operators.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.qb2A_GeoEntity;
	import quickb2.physics.core.tangibles.qb2A_TangibleObject;
	import quickb2.physics.core.tangibles.qb2ContactFilter;
	import quickb2.utils.prop.qb2E_PropType;
	import quickb2.utils.prop.qb2E_SpecialPropValue;
	import quickb2.utils.prop.qb2Prop;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2StyleProp extends qb2Prop
	{
		public function qb2StyleProp(name:String, defaultValue:*, expectedType_nullable:* = null)
		{
			super(qb2StyleProp, name, defaultValue, expectedType_nullable);
		}
	}
}