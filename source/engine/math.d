module engine.math;

alias Vector2f = Vector2!float;
alias Vector2d = Vector2!double;

struct Vector2(T)
{
	T x;
	T y;

	@property
	T length()
	{
		import std.math;

		return sqrt( x^^2 + y^^2 );
	}
	@property
	Vector2f!T normalize()
	{
		T len = length;
		return Vector2f!T( x/length, y/length );
	}

	Vector2!T opUnary( string s )()
	if( s == "-")
	{
		return Vector2f( -x, -y );
	}

	Vector2!T opBinary( string op )( Vector2!T rhs ) const
	{
		static if( op == "+" || op == "-" || op == "*" || op == "/" ){
			mixin( "return Vector2!T( x "~op~" rhs.x, y "~op~" rhs.y );");
		}else
			static assert( 0, "Vector!T operation "~op~" not supported");
	}
	Vector2!T opBinary( string op )( T rhs ) const
	{
		static if( op == "*" || op == "/" ){
			mixin( "return Vector2!T( x "~op~" rhs, y "~op~" rhs );");
		}else
			static assert( 0, "Vector!T operation "~op~" not supported");
	}
	void opOpAssign( string op )( Vector2!T rhs )
	{
		this = opBinary!op( rhs );
	}
	void opOpAssign( string op )( T rhs )
	{
		this = opBinary!op( rhs );
	}
}

T clamp(T)(T value, T min, T max )
{
	if( value < min )
		return min;
	if( value > max )
		return max;
	return value;
}