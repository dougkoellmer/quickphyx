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

package quickb2.lang.errors
{
	import quickb2.debugging.gui.components.qb2DebugGuiCheckBox;
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * A collection of error codes that in a better world could be raised at compile-time.
	 * 
	 * @author Doug Koellmer
	 */
	public final class qb2E_CompilerErrorCode extends qb2Enum implements qb2I_ErrorCode
	{
		include "../macros/QB2_ENUM";
		
		private var m_message:String;
		
		public function qb2E_CompilerErrorCode(message:String = null)
		{
			super(AUTO_INCREMENT);
			
			m_message = message;
		}
		
		public function getMessage():String
		{
			return m_message;
		}
		
		public function getId():int
		{
			return this.getOrdinal() + 1000;
		}
		
		/// Thrown when you try to instantiate a base class that should never be instantiated directly.
		public static const ABSTRACT_CLASS:qb2E_CompilerErrorCode				= new qb2E_CompilerErrorCode("An abstract class cannot be instantiated.");
		
		public static const ABSTRACT_METHOD:qb2E_CompilerErrorCode				= new qb2E_CompilerErrorCode("An abstract method must be implemented by a subclass.");
		
		public static const ILLEGAL_FLAG_ASSIGNMENT:qb2E_CompilerErrorCode		= new qb2E_CompilerErrorCode("The created flag wasn't within the proper range of bits.");
		
		public static const PRIVATE_CONSTRUCTOR:qb2E_CompilerErrorCode			= new qb2E_CompilerErrorCode("This class has a constructor that cannot be directly invoked.");
		
		public static const SETTINGS_CLASS:qb2E_CompilerErrorCode				= new qb2E_CompilerErrorCode("A static class cannot be instantiated.");
		
		public static const UTILITY_CLASS:qb2E_CompilerErrorCode				= new qb2E_CompilerErrorCode("A utility class cannot be instantiated.");
		
		public static const MODULE_CLASS:qb2E_CompilerErrorCode					= new qb2E_CompilerErrorCode("A module class cannot be instantiated.");
		
		public static const POOL_ERROR:qb2E_CompilerErrorCode					= new qb2E_CompilerErrorCode();
		
		public static const TYPE_MISMATCH:qb2E_CompilerErrorCode				= new qb2E_CompilerErrorCode();
		
		public static const ENUM_ALLOCATION:qb2E_CompilerErrorCode				= new qb2E_CompilerErrorCode("Enums cannot be created dynamically.");
		
		public static const BAD_ASSIGNMENT:qb2E_CompilerErrorCode				= new qb2E_CompilerErrorCode();
		
		public static const IMMUTABLE:qb2E_CompilerErrorCode					= new qb2E_CompilerErrorCode("Attempted to modify an immutable object's data.");
	}
}