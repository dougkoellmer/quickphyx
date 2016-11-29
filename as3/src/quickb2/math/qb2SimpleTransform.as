package quickb2.math 
{
	import quickb2.lang.foundation.qb2A_Object;
	import quickb2.lang.types.qb2U_Type;
	import quickb2.math.geo.coords.qb2GeoPoint;
	import quickb2.math.geo.coords.qb2GeoVector;
	
	/**
	 * ...
	 * @author 
	 */
	public class qb2SimpleTransform extends qb2A_Object
	{
		private const m_translation:qb2GeoVector = new qb2GeoVector();
		private var m_rotation:Number;
		
		public function qb2SimpleTransform() 
		{
			
		}
		
		protected override function copy_protected(source:*):void
		{
			if ( qb2U_Type.isKindOf(source, qb2SimpleTransform) )
			{
				var asTransform:qb2SimpleTransform = source as qb2SimpleTransform;
				this.m_translation.copy(asTransform.m_translation);
				this.m_rotation = asTransform.m_rotation;
			}
		}
		
		public function getTranslation():qb2GeoVector
		{
			return m_translation;
		}
		
		public function getRotation():Number
		{
			return m_rotation;
		}
		
		public function setRotation(value:Number):void
		{
			m_rotation = value;
		}
		
		public function concatRotation(value:Number):void
		{
			m_rotation += value;
		}
		
		public function concatRotationInverse(value:Number):void
		{
			m_rotation -= value;
		}
		
		public function concat(transform:qb2SimpleTransform):void
		{
			m_translation.add(transform.m_translation);
			m_rotation += transform.m_rotation;
		}
		
		public function concatInverse(transform:qb2SimpleTransform):void
		{
			m_translation.subtract(transform.m_translation);
			m_rotation -= transform.m_rotation;
		}
	}
}