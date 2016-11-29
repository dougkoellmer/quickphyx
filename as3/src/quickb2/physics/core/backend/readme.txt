For the most part, end-users don't need to worry about this sub-package at all - only if you want to plug in a new physics engine.

It contains the interfaces that a back-end physics engine must implement.

For now, there is only one implementation, for box2d.  It is expected that some interfaces will have to be adjusted to fit the needs/designs of other physics engines.