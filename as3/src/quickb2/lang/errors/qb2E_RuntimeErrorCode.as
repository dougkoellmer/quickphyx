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
	import quickb2.lang.foundation.qb2Enum;
	
	/**
	 * A collection of runtime error codes.
	 * 
	 * @author Doug Koellmer
	 */
	public final class qb2E_RuntimeErrorCode extends qb2Enum implements qb2I_ErrorCode
	{
		include "../macros/QB2_ENUM";
		
		public static const ASSERTION_FAILED:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode("Assertion failed.");
		
		public static const NOT_IMPLEMENTED:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode("This feature is currently not implemented.");

		public static const POOL_ERROR:qb2E_RuntimeErrorCode				= new qb2E_RuntimeErrorCode();
		
		public static const BAD_CLONE:qb2E_RuntimeErrorCode					= new qb2E_RuntimeErrorCode();
		
		public static const ALREADY_IN_USE:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode();
		
		public static const ALREADY_DEFINED:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode();
		
		public static const CONSTRUCTOR_UNDEFINED:qb2E_RuntimeErrorCode		= new qb2E_RuntimeErrorCode();
		
		public static const ILLEGAL_ACCESS:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode();
		
		public static const ILLEGAL_STATE:qb2E_RuntimeErrorCode				= new qb2E_RuntimeErrorCode();
		
		public static const ILLEGAL_ARGUMENT:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode();
		
		public static const BAD_ASSIGNMENT:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode();
		
		public static const MODULE_NOT_LOADED:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode("You may have forgotten to startUp() a required module.");
		
		public static const UNSUPPORTED:qb2E_RuntimeErrorCode				= new qb2E_RuntimeErrorCode("This feature is not supported.");
		
		public static const MISSING_DEPENDENCY:qb2E_RuntimeErrorCode		= new qb2E_RuntimeErrorCode();
		
		public static const SELF_REFERENCE:qb2E_RuntimeErrorCode			= new qb2E_RuntimeErrorCode();
		
		public static const INVALID_RELATIONSHIP:qb2E_RuntimeErrorCode		= new qb2E_RuntimeErrorCode();
		
		public static const OUT_OF_BOUNDS:qb2E_RuntimeErrorCode				= new qb2E_RuntimeErrorCode();
		
		public static const READ_ONLY:qb2E_RuntimeErrorCode					= new qb2E_RuntimeErrorCode();
		
		public static const INVALID_TYPE:qb2E_RuntimeErrorCode				= new qb2E_RuntimeErrorCode();
		
		
		private var m_message:String
		
		public function qb2E_RuntimeErrorCode(message:String = null)
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
			return this.getOrdinal() + 1500;
		}
	}
}