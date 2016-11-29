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

package quickb2.physics.core.events 
{
	import flash.events.*;
	import quickb2.lang.*
	import quickb2.debugging.*;
	import quickb2.debugging.logging.qb2U_ToString;
	
	import quickb2.physics.core.qb2A_PhysicsObject;
	import quickb2.physics.core.tangibles.*;
	import quickb2.event.qb2Event;
	import quickb2.event.qb2EventMultiType;
	import quickb2.event.qb2EventType;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class qb2ContainerEvent extends qb2Event
	{
		public static const ADDED_OBJECT:qb2EventType						= new qb2EventType("ADDED_OBJECT", 				qb2ContainerEvent);
		public static const REMOVED_OBJECT:qb2EventType						= new qb2EventType("REMOVED_OBJECT", 			qb2ContainerEvent);
		public static const DESCENDANT_ADDED_OBJECT:qb2EventType			= new qb2EventType("DESCENDANT_ADDED_OBJECT", 	qb2ContainerEvent);
		public static const DESCENDANT_REMOVED_OBJECT:qb2EventType			= new qb2EventType("DESCENDANT_REMOVED_OBJECT", qb2ContainerEvent);
		public static const ADDED_TO_WORLD:qb2EventType            			= new qb2EventType("ADDED_TO_WORLD", 			qb2ContainerEvent);
		public static const REMOVED_FROM_WORLD:qb2EventType        			= new qb2EventType("REMOVED_FROM_WORLD", 		qb2ContainerEvent);
		public static const ADDED_TO_CONTAINER:qb2EventType       			= new qb2EventType("ADDED_TO_OBJECT", 			qb2ContainerEvent);
		public static const REMOVED_FROM_CONTAINER:qb2EventType   			= new qb2EventType("REMOVED_FROM_OBJECT", 		qb2ContainerEvent);
		public static const ORDER_CHANGED:qb2EventType            			= new qb2EventType("ORDER_CHANGED", 			qb2ContainerEvent);
		
		//public static const ADDED_OR_REMOVED_TO_FROM_WORLD:qb2EventMultiType = new qb2EventMultiType(ADDED_TO_WORLD, REMOVED_FROM_WORLD);
		
		// TODO: Not sure if we need these.
		//public static const parent_ADDED_TO_CONTAINER:qb2EventType        = new qb2EventType("PARENT_ADDED_TO_CONTAINER", 			qb2ContainerEvent);
		//public static const parent_REMOVED_FROM_CONTAINER:qb2EventType    = new qb2EventType("PARENT_REMOVED_FROM_CONTAINER", 		qb2ContainerEvent);
		
		private var m_child:qb2A_PhysicsObject;
		private var m_parent:qb2A_PhysicsObjectContainer;
		private var m_world:qb2World;
		
		public function qb2ContainerEvent(type_nullable:qb2EventType = null) 
		{
			super(type_nullable);
		}
		
		public function initialize(child:qb2A_PhysicsObject, parent:qb2A_PhysicsObjectContainer, world:qb2World):void
		{
			m_child = child;
			m_parent = parent;
			m_world = world;
		}

		protected override function copy_protected(otherObject:*):void
		{
			super.copy_protected(otherObject);
				
			if ( otherObject as qb2ContainerEvent )
			{
				this.m_child    = otherObject.m_child;
				this.m_parent = otherObject.m_parent;
				this.m_world = otherObject.m_world;
			}
		}
		
		protected override function clean():void
		{
			super.clean();
			
			m_child = null;
			m_parent = null;
			m_world = null;
		}
		
		public function getChildObject():qb2A_PhysicsObject
		{
			return m_child;
		}
		
		public function getParentObject():qb2A_PhysicsObjectContainer
		{
			return m_parent;
		}
		
		public function getWorldObject():qb2World
		{
			return m_world;
		}
	}
}