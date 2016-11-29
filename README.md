quickphyx is a high-level game physics engine with an extensible, event-driven DOM-style API, CSS-inspired property system, and several built-in modules for simulating car physics, soft bodies, force effect fields, and much more. It grew out of a simpler Flash library called quickb2 by the same author and is still in a transitional period as it's being revamped and ported to other languages. In the mean time check out these resources to stoke your interest:

* [http://quickb2.dougkoellmer.com/bin/qb2DemoReel.swf](http://quickb2.dougkoellmer.com/bin/qb2DemoReel.swf) - Demo of the abstractions quickphyx provides.
* [https://code.google.com/p/quickb2/](https://code.google.com/p/quickb2/) - Code repository for original quickb2 library.
* [http://quickb2.dougkoellmer.com/forum/](http://quickb2.dougkoellmer.com/forum/) - Original forum for quickb2, but many questions are still applicable to quickphyx.
  
  
  
Here's a quick look at the features quickphyx provides over other popular physics engines:

* Soft-bodies simulated with rigid-body decomposition.
* Top-down car physics.
* Top-down friction.
* Driven through simple DOM-like events.
* Retain mode that doesn't require destroying/remaking objects.
* Exact same API for both 2d and 3d physics (how is that possible?!?!).
* Extensible architecture.
* Nested tree API similar to popular GUI frameworks.
* Cloneable objects.
* Highly customizable immediate-mode rendering for both debug and production purposes.
* Hooks for integration with any typical retain-mode rendering engine (e.g. the Flash display list).
* Various debugging tools including color-coded visualizations, mouse dragging, warnings, notifications, asserts, exceptions, and runtime GUIs.
* Pixel-based units.
* AABB and circular bounding representations.
* Large suite of stock functions and classes to create common objects.
* Individual polygons may be concave and have any number of vertices.
* Physics world is completely changeable within contact callbacks.
* Built-in system for handling your game loop and time steps.
* Easy API for beginners - lower-level optimizations through cleanly leaked abstraction available for advanced users.
