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

package quickb2.thirdparty.flash
{
	import flash.display.Graphics;
	import quickb2.display.immediate.color.qb2E_ColorChannel;
	import quickb2.display.immediate.color.qb2S_Color;
	import quickb2.display.immediate.color.qb2U_Color;
	import quickb2.display.immediate.graphics.*;
	import quickb2.display.immediate.graphics.qb2E_DrawParam;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.qb2S_Math;
	
	/**
	 * Wraps the Flash Graphics object in order to implement qb2I_Graphics2d
	 * 
	 * @author Doug Koellmer
	 */
	public class qb2FlashVectorGraphics2d extends qb2A_GraphicsContext implements qb2I_Graphics2d
	{
		private static const s_utilPoint1:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint2:qb2GeoPoint = new qb2GeoPoint();
		private static const s_utilPoint3:qb2GeoPoint = new qb2GeoPoint();
		
		private static const NORMAL_SCALE_MODE:String = "normal";
		private static const CAPS_STYLE:String = "none";
		
		private var m_flashGraphicsObject:Graphics = null;
		
		private var m_needsEndFill:Boolean = false;
		
		public function qb2FlashVectorGraphics2d(flashGraphicsObject_nullable:Graphics = null):void
		{
			setFlashGraphicsObject(flashGraphicsObject_nullable);
		}
		
		public function fill():void
		{
			m_flashGraphicsObject.endFill();
		}
		
		public function getFlashGraphicsObject():Graphics
		{
			return m_flashGraphicsObject;
		}
		
		public function setFlashGraphicsObject(flashGraphicsObject:Graphics, copyData:Boolean = true):void
		{
			if ( flashGraphicsObject != null && m_flashGraphicsObject != null && copyData )
			{
				flashGraphicsObject.clear();
				flashGraphicsObject.copyFrom(m_flashGraphicsObject);
			}
			
			m_flashGraphicsObject = flashGraphicsObject;
			
			if ( m_flashGraphicsObject != null )
			{
				setFill(null);
				setLineStyle();
			}
		}
		
		public function clearBuffer():void
		{			
			m_flashGraphicsObject.clear();
		}
		
		public override function pushParam(param:qb2E_DrawParam, value_copied:* ):void
		{
			var oldValue:* = super.getParam(param);
			
			super.pushParam(param, value_copied);
			
			updateGraphics(param, oldValue);
		}
		
		public override function popParam(param:qb2E_DrawParam):void
		{
			var oldValue:* = super.getParam(param);
			
			super.popParam(param);
			
			updateGraphics(param, oldValue);
		}
		
		private function updateGraphics(param:qb2E_DrawParam, oldValue:*):void
		{
			if ( m_flashGraphicsObject == null )  return;
			
			switch(param)
			{
				case qb2E_DrawParam.FILL_COLOR:
				{
					setFill(oldValue);
					
					break;
				}
				
				case qb2E_DrawParam.LINE_THICKNESS:
				case qb2E_DrawParam.LINE_COLOR:
				{
					setLineStyle();
					
					break;
				}
			}
		}
		
		private function isColorDefined(param:qb2E_DrawParam):Boolean
		{
			if ( super.getParam(param) == null )
			{
				return false;
			}
			
			var currentColor:int = getParam(param);
			
			if ( (currentColor & qb2S_Color.ALPHA_MASK) == 0 )
			{
				return param == qb2E_DrawParam.FILL_COLOR; // fill color of alpha 0 is still valid, but for lines it's meaningless.
			}
			
			return true;
		}
		
		private function setFill(oldValue:*):void
		{
			var newValue:* = super.getParam(qb2E_DrawParam.FILL_COLOR);
			
			if ( oldValue == null )
			{
				if ( newValue != null )
				{
					this.beginFill();
				}
			}
			else
			{
				if ( newValue != null )
				{
					m_flashGraphicsObject.endFill();
					
					this.beginFill();
				}
				else
				{
					m_flashGraphicsObject.endFill();
				}
			}
		}
		
		private function beginFill():void
		{
			var color:int = super.getParam(qb2E_DrawParam.FILL_COLOR);
			var rgbColor:int = color & qb2S_Color.COLOR_MASK;
			var alpha:Number = qb2U_Color.channelMantissa(qb2E_ColorChannel.ALPHA, color);
			
			m_flashGraphicsObject.beginFill(rgbColor, alpha);
		}
		
		private function setLineStyle():void
		{
			if ( !isColorDefined(qb2E_DrawParam.LINE_COLOR) )
			{
				m_flashGraphicsObject.lineStyle();
				
				return;
			}
			
			var color:int = super.getParam(qb2E_DrawParam.LINE_COLOR);
			var rgbColor:int = color & qb2S_Color.COLOR_MASK;
			var alpha:Number = qb2U_Color.channelMantissa(qb2E_ColorChannel.ALPHA, color);
			
			m_flashGraphicsObject.lineStyle(getParam(qb2E_DrawParam.LINE_THICKNESS), rgbColor, alpha, false, NORMAL_SCALE_MODE, CAPS_STYLE);
		}
		
		public function moveTo(point:qb2I_DrawPoint):void
		{
			this.calcTransformedPoint(point, s_utilPoint1);
			
			m_flashGraphicsObject.moveTo(s_utilPoint1.getX(), s_utilPoint1.getY());
		}
		
		public function drawLineTo(point:qb2I_DrawPoint):void
		{
			this.calcTransformedPoint(point, s_utilPoint1);
			
			m_flashGraphicsObject.lineTo(s_utilPoint1.getX(), s_utilPoint1.getY());
		}
		
		public function drawCubicCurveTo(controlPoint1:qb2I_DrawPoint, controlPoint2:qb2I_DrawPoint, anchorPoint:qb2I_DrawPoint):void
		{
			this.calcTransformedPoint(controlPoint1, s_utilPoint1);
			this.calcTransformedPoint(controlPoint2, s_utilPoint2);
			this.calcTransformedPoint(anchorPoint,	 s_utilPoint3);

			m_flashGraphicsObject.cubicCurveTo(s_utilPoint1.getX(), s_utilPoint1.getY(), s_utilPoint2.getX(), s_utilPoint2.getY(), s_utilPoint3.getX(), s_utilPoint3.getY());
		}
		
		public function drawQuadCurveTo(controlPoint:qb2I_DrawPoint, anchorPoint:qb2I_DrawPoint):void
		{
			this.calcTransformedPoint(controlPoint, s_utilPoint1);
			this.calcTransformedPoint(anchorPoint,	 s_utilPoint2);

			m_flashGraphicsObject.curveTo(s_utilPoint1.getX(), s_utilPoint1.getY(), s_utilPoint2.getX(), s_utilPoint2.getY());
		}
		
		public function drawCircle(point_nullable:qb2I_DrawPoint, radius:Number):void
		{
			point_nullable = point_nullable != null ? point_nullable : qb2S_Math.ORIGIN;
			
			this.calcTransformedPoint(point_nullable, s_utilPoint1);
			
			m_flashGraphicsObject.drawCircle(s_utilPoint1.getX(), s_utilPoint1.getY(), radius);
		}
		
		public function drawLine(point1:qb2I_DrawPoint, point2:qb2I_DrawPoint):void
		{
			this.moveTo(point1);
			this.drawLineTo(point2);
		}
	}
}