/**
 * Copyright (c) 2010 Doug Koellmer
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

package quickb2.display.immediate.graphics
{
	import quickb2.display.immediate.color.qb2Color;
	import quickb2.lang.errors.qb2E_RuntimeErrorCode;
	import quickb2.lang.errors.qb2U_Error;
	import quickb2.lang.foundation.qb2Enum;
	import quickb2.lang.operators.*;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2E_PerpVectorDirection;
	import quickb2.math.qb2AffineMatrix;
	import quickb2.math.qb2S_Math;
	import quickb2.math.qb2TransformStack;
	import quickb2.utils.*;
	
	import quickb2.math.geo.curves.qb2E_GeoLineType;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	import quickb2.math.geo.curves.qb2GeoLine;
	
	/**
	 * Provides a partial convenience implementation of qb2I_GraphicsContext.
	 * You still need to subclass this, as this class cannot be used directly.
	 * However, it does do a lot of the annoying work for you.
	 * 
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_GraphicsContext implements qb2I_GraphicsContext
	{
		private const m_paramStacks:Vector.<Vector.<*>> = new Vector.<Vector.<*>>(qb2Enum.getCount(qb2E_DrawParam), true);
		
		private const m_transformStack:qb2TransformStack = new qb2TransformStack();
	
		public function qb2A_GraphicsContext()
		{
			include "../../../lang/macros/QB2_ABSTRACT_CLASS";
			
			m_transformStack.get().setToIdentity();
			
			this.pushParam(qb2E_DrawParam.LINE_THICKNESS, 1);
			this.pushParam(qb2E_DrawParam.LINE_COLOR, 0xFF000000);
		}
		
		/**
		 * Convenience method for subclasses.
		 * 
		 * @param	point
		 * @param	point_out
		 */
		protected function calcTransformedPoint(point:qb2I_DrawPoint, point_out:qb2GeoPoint):void
		{
			point_out.copy(point);
			point_out.transformBy(m_transformStack.get());
		}
		
		public function getTransformStack():qb2TransformStack
		{
			return m_transformStack;
		}
		
		private function getOrCreateParamStack(param:qb2E_DrawParam):Vector.<*>
		{
			var stack:Vector.<*> = m_paramStacks[param.getOrdinal()];
			
			if ( stack == null )
			{
				stack = m_paramStacks[param.getOrdinal()] = new Vector.<*>();
			}
			
			return stack;
		}
		
		public function pushParam(param:qb2E_DrawParam, value_copied:*):void
		{
			var stack:Vector.<*> = getOrCreateParamStack(param);
			
			if ( value_copied == null )
			{
				stack.push(null);
			}
			else
			{
				if ( param == qb2E_DrawParam.LINE_THICKNESS )
				{
					if ( !qb2U_Type.isNumeric(value_copied) )
					{
						qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected numeric value.");
					}
					
					stack.push(value_copied);
				}
				else
				{
					if ( qb2U_Type.isKindOf(value_copied, qb2Color) )
					{
						stack.push((value_copied as qb2Color).getRawValue());
					}
					else if ( qb2U_Type.isNumeric(value_copied) )
					{
						stack.push(value_copied);
					}
					else
					{
						qb2U_Error.throwCode(qb2E_RuntimeErrorCode.ILLEGAL_ARGUMENT, "Expected numeric value or qb2Color.");
					}
				}
			}
		}
		
		public function popParam(param:qb2E_DrawParam):void
		{
			var stack:Vector.<*> = getOrCreateParamStack(param);
			
			stack.pop();
		}
		
		public function getParam(param:qb2E_DrawParam):*
		{
			var stack:Vector.<*> = m_paramStacks[param.getOrdinal()];
			
			if ( stack == null || stack.length == 0 )
			{
				return null;
			}
			
			return stack[stack.length-1];
		}
	}
}