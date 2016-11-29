The global functions in this folder are meant to act as operators that AS3 either doesn't have built into the language, or that quickb2 abstracts for its own purposes.

For example, as regards abstraction, operators like qb2_print() are used internally (instead of trace()ing) so that the output can be piped to multiple places, e.g. console, gui, log, etc.

qb2_new() and qb2_delete() are perhaps the most interesting operators for end-users.  They provide a very advanced object-pooling system that
can simulate stack allocation and provide an efficient way to manage large numbers of objects that would otherwise thrash the heap.

