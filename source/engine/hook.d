/+++
	Hook module enables you to add callbacks to 
+++/
module engine.hook;

/+++
	Create a hook

	When you call the hook and supply its arguments, all objects hooked onto it
	will be called with them.

	It is important that the object added to hook be of the same common type.
+++/
struct Hook( T, string func, Args... )
{
	T[] data;

	void add( T obj ){
		data ~= obj;
	}

	void remove( T obj )
	{
		import std.algorithm;
		data = remove!(a => a == obj)( data );
	}
	
	void call( Args args )
	{
		foreach( obj; data )
		{
			__traits(getMember, obj, func)( args );
		}
	}
	
}