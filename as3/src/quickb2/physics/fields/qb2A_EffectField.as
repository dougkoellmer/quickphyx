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
	import flash.display.*;
	import flash.utils.*;
	import quickb2.lang.*;
	
	import quickb2.debugging.*;
	import quickb2.debugging.drawing.*;
	import quickb2.debugging.gui.components.qb2DebugGuiCheckBox;
	import quickb2.debugging.logging.*;
	import quickb2.event.*;
	import quickb2.lang.operators.qb2_throw;
	import quickb2.lang.operators.qb2U_Error.throwCode;
	import quickb2.physics.core.iterators.qb2TreeIterator;
	import quickb2.display.immediate.graphics.qb2I_Graphics2d;
	import quickb2.event.qb2EventMultiType;
	
	
	import quickb2.physics.core.*;
	import quickb2.physics.core.tangibles.*;
	
	
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	[qb2_abstract] public class qb2A_EffectField extends qb2Group
	{
		private var instanceFilter:Dictionary = null;
		private var typeFilter:Dictionary = null;
		
		public var applyPerShape:Boolean = false;
		
		public function qb2A_EffectField()
		{
			super();
			init();
		}
		
		private static const CONTAINER_EVENTS:qb2EventMultiType = new qb2EventMultiType
		(
			qb2ContainerEvent.DESCENDANT_ADDED_OBJECT,
			qb2ContainerEvent.DESCENDANT_REMOVED_OBJECT,
			qb2ContainerEvent.ADDED_OBJECT,
			qb2ContainerEvent.REMOVED_OBJECT
		);
		
		private static const CONTAINER_WORLD_EVENTS:qb2EventMultiType = new qb2EventMultiType
		(
			qb2ContainerEvent.ADDED_TO_WORLD, qb2ContainerEvent.REMOVED_FROM_WORLD
		);
		
		private function init():void
		{
			include "../../lang/macros/QB2_ABSTRACT_CLASS";
			
			setPhysicsBoolean(qb2S_PhysicsProps.IS_GHOST, true);
			
			addEventListener(CONTAINER_EVENTS, childrenChanged, null, true);
			
			addContainerEventListeners();
		}
		
		public function apply(toTangible:qb2I_TangibleObject):void
		{
			// TODO: don't think this will work now.
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(toTangible as qb2A_PhysicsObjectContainer, qb2I_TangibleObject);
			for ( var tang:qb2I_TangibleObject; tang = iterator.next() as qb2I_TangibleObject; )
			{
				if ( isDisabledFor(tang) )
				{
					iterator.skipBranch();
				}
				
				if ( tang is qb2I_RigidObject )
				{
					var asRigid:qb2I_RigidObject = tang as qb2I_RigidObject;
					var isBody:Boolean = asRigid is qb2Body;
					
					if ( isBody && !applyPerShape || !isBody /*(isShape)*/ && applyPerShape )
					{
						applyToRigid(asRigid);
					}
				}
			}
		}
		
		[qb2_abstract] public function applyToRigid(rigid:qb2I_RigidObject):void
		{
			include "../../lang/macros/QB2_ABSTRACT_METHOD";
		}
		
		protected function postUpdate(evt:qb2StepEvent):void
		{
			if ( !_shapeCount )  return;
			
			var contactDict:Dictionary = applyPerShape ? shapeContactDict : bodyContactDict;
			
			for ( var key:* in contactDict )
			{
				var rigid:qb2I_RigidObject = key as qb2I_RigidObject;
				
				if ( !this.isDisabledFor(rigid, true) )
				{
					this.applyToRigid(rigid);
				}
			}
		}
		
		private var _shapeCount:uint = 0;
		
		private function childrenChanged(evt:qb2ContainerEvent):void
		{
			var addEvent:Boolean = evt.getType() == qb2ContainerEvent.ADDED_OBJECT || evt.getType() == qb2ContainerEvent.DESCENDANT_ADDED_OBJECT;
			
			var iterator:qb2TreeIterator = qb2TreeIterator.getInstance(evt.getChild() as qb2A_PhysicsObjectContainer);
			for ( var shape:qb2Shape; shape = iterator.next() as qb2Shape; )
			{
				if ( addEvent )
				{
					if ( _shapeCount == 0 )
					{
						removeContaineqb2EventListeners();
						addContactEventListeners();
					}
					
					_shapeCount++;
				}
				else
				{
					if ( _shapeCount == 1 )
					{
						addContainerEventListeners();
						removeContactEventListeners();
					}
					
					_shapeCount--;
				}
			}
		}
		
		private static const WEAK_KEYS:Boolean = true;
		
		public function disableFor(instanceOrClass:*):void
		{
			if ( instanceOrClass is Class )
			{
				typeFilter = typeFilter ? typeFilter : new Dictionary(WEAK_KEYS);
				typeFilter[instanceOrClass] = true;
			}
			else
			{
				instanceFilter = instanceFilter ? instanceFilter : new Dictionary(WEAK_KEYS);
				instanceFilter[instanceOrClass] = true;
			}
		}
		
		public function enableFor(instanceOrClass:*):void
		{
			if ( instanceOrClass is Class )
			{
				if ( !typeFilter )  return;
				
				if ( typeFilter[instanceOrClass] )
				{
					delete typeFilter[instanceOrClass];
				}
			}
			else
			{
				instanceFilter = instanceFilter ? instanceFilter : new Dictionary(WEAK_KEYS);
				instanceFilter[instanceOrClass] = false;
			}
		}
		
		public final function isDisabledFor(tang:qb2I_TangibleObject, checkAncestry:Boolean = true):Boolean
		{
			if ( !instanceFilter && !typeFilter )  return false;
			
			var currObject:qb2A_PhysicsObject = tang as qb2A_PhysicsObject;
			do
			{
				if ( instanceFilter && instanceFilter[currObject] != null )
				{
					return instanceFilter[currObject] as Boolean;
				}
				
				if ( typeFilter )
				{
					for ( var key:* in typeFilter )
					{
						if ( currObject is (key as Class) )
						{
							return typeFilter[key] as Boolean
						}
					}
				}
				
				currObject = currObject.getParent();
			}
			while (checkAncestry && currObject)
			
			return false;
		}
		
		private function addSelfToSystem():void
		{
			if ( getParent() && getWorld() )
			{
				//getParent()._effectFields = getParent()._effectFields ? getParent()._effectFields : new Vector.<qb2A_EffectField>();
				//getParent()._effectFields.push(this);
			}
		}
		
		private function removeSelfFromSystem(thisParent:qb2A_PhysicsObjectContainer, thisWorld:qb2World):void
		{
			if ( !thisParent )  return;
			
			//if ( thisParent._effectFields )
			{
				//var index:int = thisParent._effectFields.indexOf(this);
				var index:int = 0;
				
				if ( index >= 0 )
				{
					//thisParent._effectFields.splice(index, 1);
				}
			}
		}
		
		private function addedOrRemoved(evt:qb2ContainerEvent):void
		{
			if ( evt.getType() == qb2ContainerEvent.ADDED_TO_WORLD )
			{
				addSelfToSystem();
			}
			else
			{
				removeSelfFromSystem(getParent() ? getParent() : evt.getAncestor(), evt.getAncestor().getWorld());
			}
		}
			
		private function addContainerEventListeners():void
		{
			addSelfToSystem();
			
			addEventListener(CONTAINER_WORLD_EVENTS, addedOrRemoved, null, true);
		}
		
		private function removeContaineqb2EventListeners():void
		{
			removeSelfFromSystem(getParent(), getWorld());
			
			removeEventListener(CONTAINER_WORLD_EVENTS, addedOrRemoved);
		}
		
		private function addContactEventListeners():void
		{
			addEventListener(qb2StepEvent.POST_STEP, postUpdate, null, true);
			
			//--- Create (and fill) contact dictionary.
			shapeContactDict = new Dictionary(WEAK_KEYS);
			bodyContactDict  = new Dictionary(WEAK_KEYS);
			
			if ( getWorld() )
			{
				/*var worldB2:b2World = getWorld().getBox2dWorld();
				
				var contactB2:b2Contact = worldB2.GetContactList();
				while ( contactB2 )
				{
					if ( contactB2.IsTouching() )
					{
						var shape1:qb2Shape = contactB2.GetFixtureA().m_userData as qb2Shape;
						var shape2:qb2Shape = contactB2.GetFixtureB().m_userData as qb2Shape;
						
						if ( shape1 && shape2 )
						{
							var otherShape:qb2Shape = null;
							
							if ( qb2U_Family.isDescendantOf(shape1, this) )
							{
								otherShape = shape2;
							}
							else if ( qb2U_Family.isDescendantOf(shape2, this) )
							{
								otherShape = shape1;
							}
							
							if ( otherShape )
							{
								shapeContactDict[otherShape] = shapeContactDict[otherShape] ? shapeContactDict[otherShape] :  0 as int;
								shapeContactDict[otherShape]++;
								
								var otherBody:qb2I_RigidObject = otherShape.m_ancestorBody ? otherShape.m_ancestorBody : otherShape;
								bodyContactDict[otherBody] = bodyContactDict[otherBody] ? bodyContactDict[otherBody] :  0 as int;
								bodyContactDict[otherBody]++;
							}
						}
					}
					
					contactB2 = contactB2.GetNext();
				}*/
			}
			
			addEventListener(qb2ContactEvent.CONTACT_STARTED, contact, null, true);
			addEventListener(qb2ContactEvent.CONTACT_ENDED,   contact, null, true);
		}
		
		private function removeContactEventListeners():void
		{			
			removeEventListener(qb2StepEvent.POST_STEP, postUpdate);
			
			//--- Clean up contact dictionary, removing this effects from all shapes in contact.
			if ( shapeContactDict )
			{
				for ( var key:* in shapeContactDict )
				{
					delete shapeContactDict[key];
				}
			}
			
			if ( bodyContactDict )
			{
				for ( key in bodyContactDict )
				{
					delete bodyContactDict[key];
				}
			}
			
			shapeContactDict = bodyContactDict = null;
			
			removeEventListener(qb2ContactEvent.CONTACT_STARTED, contact);
			removeEventListener(qb2ContactEvent.CONTACT_ENDED,   contact);
		}
		
		private var shapeContactDict:Dictionary = null;
		private var bodyContactDict:Dictionary = null;
		
		private function contact(evt:qb2ContactEvent):void
		{
			var otherShape:qb2Shape = evt.getOtherShape();
			var otherBody:qb2I_RigidObject = otherShape.m_ancestorBody ? otherShape.m_ancestorBody : otherShape;
			
			if ( evt.getType() == qb2ContactEvent.CONTACT_STARTED )
			{
				if ( !shapeContactDict[otherShape] )
				{
					shapeContactDict[otherShape] = 0 as int;
					
					if ( !bodyContactDict[otherBody] )
					{
						bodyContactDict[otherBody] = 0 as int;
					}
					bodyContactDict[otherBody]++;
				}
				
				shapeContactDict[otherShape]++;
			}
			else
			{
				shapeContactDict[otherShape]--;
				
				if ( shapeContactDict[otherShape] == 0 ) 
				{
					delete shapeContactDict[otherShape];
					
					bodyContactDict[otherBody]--;
					if ( bodyContactDict[otherBody] == 0 )
					{
						delete bodyContactDict[otherBody];
					}
				}
			}
		}
		
		public override function clone():*
		{
			var cloned:qb2A_EffectField = super.clone() as qb2A_EffectField;
			
			cloned.applyPerShape = this.applyPerShape;
			
			if ( instanceFilter )
			{
				cloned.instanceFilter = new Dictionary(WEAK_KEYS);
				
				for ( var key:* in instanceFilter )
				{
					cloned.instanceFilter[key] = this.instanceFilter[this];
				}
			}
			
			if ( typeFilter )
			{
				cloned.typeFilter = new Dictionary(WEAK_KEYS);
				
				for ( key in typeFilter )
				{
					cloned.typeFilter[key] = this.typeFilter[key];
				}
			}
			
			return cloned;
		}
		
		/*public override function drawDebug(graphics:qb2I_Graphics2d):void
		{
			graphics.pushFillColor(qb2S_DebugDraw.effectFieldFillColor | qb2S_DebugDraw.fillAlpha);
			{
				super.drawDebug(graphics);
			}
			graphics.popFillColor();
		}*/

		public override function convertTo(T:Class):* 
		{
			if ( T === String )
			{
				return qb2U_ToString.auto(this);
			}
			
			return super.convertTo(T);
		}
	}
}