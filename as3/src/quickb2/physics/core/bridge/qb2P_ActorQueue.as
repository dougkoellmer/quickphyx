package quickb2.physics.core.bridge 
{
	import quickb2.display.retained.qb2I_Actor;
	import quickb2.display.retained.qb2I_ActorContainer;
	import quickb2.lang.types.qb2ClosureConstructor;
	import quickb2.utils.qb2ObjectPool;
	import quickb2.utils.qb2OptVector;
	/**
	 * ...
	 * @author 
	 */
	public class qb2P_ActorQueue 
	{
		private const m_actorPairQueue:qb2OptVector = new qb2OptVector();
		private var m_currentActorPairQueueIndex:int = 0;
		
		private const m_actorPairPool:qb2ObjectPool = new qb2ObjectPool
		(
			new qb2ClosureConstructor(function():qb2P_ActorPair
			{
				return new qb2P_ActorPair();
			})
		);
		
		public function qb2P_ActorQueue() 
		{
			
		}
		
		public function pushAddition(parent:qb2I_ActorContainer, child:qb2I_Actor):void
		{
			var pair:qb2P_ActorPair = m_actorPairPool.checkOut();
			pair.parent = parent;
			pair.child = child;
			pair.adding = true;
			
			m_actorPairQueue.push(pair);
		}
		
		public function pushRemoval(parent:qb2I_ActorContainer, child:qb2I_Actor):void
		{
			var pair:qb2P_ActorPair = m_actorPairPool.checkOut();
			pair.parent = parent;
			pair.child = child;
			pair.adding = false;
			
			m_actorPairQueue.push(pair);
		}
		
		public function process():void
		{
			var actorPairQueueCount:int = m_actorPairQueue.getLength();
			var actorPairQueueData:Vector.<*> = m_actorPairQueue.getData();
			for ( ; m_currentActorPairQueueIndex < actorPairQueueCount; m_currentActorPairQueueIndex++ )
			{
				var actorPair:qb2P_ActorPair = actorPairQueueData[m_currentActorPairQueueIndex];
				
				if ( actorPair.adding )
				{
					actorPair.parent.addActorChild(actorPair.child);
				}
				else
				{
					actorPair.parent.removeActorChild(actorPair.child);
				}
				
				m_actorPairPool.checkIn(actorPair);
			}
			
			m_currentActorPairQueueIndex = 0;
			m_actorPairQueue.setLength(0, false);
		}
	}

}