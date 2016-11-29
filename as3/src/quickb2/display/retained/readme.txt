Contains a number of interfaces that users can implement in order to hook a typical retain-mode display engine into quickb2, e.g. the Flash display list.

qb2I_Actors can be given to any qb2I_PhysicsObject.  Generally you should give your qb2World a qb2I_ActorContainer implementation that corresponds to a top level in your display hierarchy, e.g. the Flash Stage.

The cool thing about these interfaces is that you could even hook a 3d engine into quickb2, translating 2d coordinates to 3d in your implementation.