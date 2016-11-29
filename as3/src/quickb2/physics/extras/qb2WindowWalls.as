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

package quickb2.physics.extras 
{
	import quickb2.math.qb2U_Math;
	import quickb2.math.geo.*;
	import flash.display.*;
	import flash.events.*;
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.physics.utils.qb2U_Stock;
	import quickb2.platform.qb2I_Window;
	import quickb2.event.qb2Event;
	import quickb2.platform.qb2I_Window;
	import quickb2.platform.qb2WindowEvent;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.qb2Group;
	
	import quickb2.lang.*;
	
	
	
	//TODO: make this class cloneable, or enforce noncloneability.
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2WindowWalls extends qb2Group
	{
		private var m_leftWall:qb2FollowBody;
		private var m_rightWall:qb2FollowBody;
		private var m_upperWall:qb2FollowBody;
		private var m_lowerWall:qb2FollowBody;
		
		private var m_window:qb2I_Window;
		
		private const m_config:qb2WindowWallsConfig = new qb2WindowWallsConfig();
		private var m_followBodyConfig:qb2FollowBodyConfig;
		
		public function qb2WindowWalls(window:qb2I_Window, config_copied_nullable:qb2WindowWallsConfig = null, followBodyConfig_nullable:qb2FollowBodyConfig = null) 
		{
			init(window, config_copied_nullable, followBodyConfig_nullable);
		}
		
		private function init(window:qb2I_Window, config_copied_nullable:qb2WindowWallsConfig, followBodyConfig_nullable:qb2FollowBodyConfig):void
		{
			if ( config_copied_nullable != null )
			{
				m_config.copy(config_copied_nullable);
			}
			
			m_followBodyConfig = followBodyConfig_nullable != null ? followBodyConfig_nullable : new qb2FollowBodyConfig();
			
			m_window = window;
			m_window.addEventListener(qb2WindowEvent.RESIZED, onResize, true);
			
			makeWalls();
			
			updateWalls(true);
		}
		
		public function setConfig(config_copied:qb2WindowWallsConfig):void
		{
			m_config.copy(config_copied);
			
			updateWalls(false);
		}
		
		public function getFollowBodyConfig():qb2FollowBodyConfig
		{
			return m_followBodyConfig;
		}
		
		private function makeWalls():void
		{
			addChild(m_upperWall = makeWall(m_config.maxWidth, m_config.wallThickness ));
			addChild(m_lowerWall = makeWall(m_config.maxWidth, m_config.wallThickness ));
			addChild(m_leftWall  = makeWall(m_config.wallThickness, m_config.maxHeight));
			addChild(m_rightWall = makeWall(m_config.wallThickness, m_config.maxHeight));
		}
		
		private function updateWalls(instantly:Boolean):void
		{
			var screenHeight:Number = qb2U_Math.clamp(m_window.getWindowHeight(), m_config.minWidth, m_config.maxWidth);
			var screenWidth:Number = qb2U_Math.clamp(m_window.getWindowWidth(), m_config.minHeight, m_config.maxHeight);
			var screenLeft:Number = m_window.getWindowLeft();
			var screenTop:Number = m_window.getWindowTop();
			
			m_leftWall.getTargetPosition().setX(screenLeft - m_config.wallThickness / 2 + m_config.overhang);
			m_leftWall.getTargetPosition().setY(screenTop + screenHeight / 2)
			if ( instantly )
			{
				m_leftWall.getPosition().copy(m_leftWall.getTargetPosition());
			}
			
			m_rightWall.getTargetPosition().setX(screenLeft + screenWidth + m_config.wallThickness / 2 - m_config.overhang);
			m_rightWall.getTargetPosition().setY(screenTop + screenHeight / 2);
			if ( instantly )
			{
				m_rightWall.getPosition().copy(m_rightWall.getTargetPosition());
			}
			
			m_upperWall.getTargetPosition().setX(screenLeft + screenWidth / 2)
			m_upperWall.getTargetPosition().setY(screenTop - m_config.wallThickness / 2 + m_config.overhang);
			if ( instantly )
			{
				m_upperWall.getPosition().copy(m_upperWall.getTargetPosition());
			}
			
			m_lowerWall.getTargetPosition().setX(screenLeft + screenWidth / 2);
			m_lowerWall.getTargetPosition().setY(screenTop + screenHeight + m_config.wallThickness / 2 - m_config.overhang);
			if ( instantly )
			{
				m_lowerWall.getPosition().copy(m_lowerWall.getTargetPosition());
			}
		}
		
		private function onResize(evt:qb2WindowEvent):void
		{
			updateWalls(m_config.instantlyResize);
		}
		
		private function makeWall(width:Number, height:Number):qb2FollowBody
		{
			var body:qb2FollowBody = new qb2FollowBody(m_followBodyConfig);
			body.addChild(qb2U_Stock.newRectangleShape(width, height));
			
			return body;
		}
		
		private function getWindow():qb2I_Window
		{
			return m_window;
		}
	}
}