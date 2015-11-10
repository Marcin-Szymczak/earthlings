module engine.math;

import std.math;

alias Vector2f = Vector2!float;
alias Vector2d = Vector2!double;

struct Vector2(T)
{
	T x;
	T y;

	@property
	inout(T) length() inout
	{
		import std.math;

		return sqrt( x^^2 + y^^2 );
	}
	
	inout(Vector2!T) normalize() inout
	{
		inout(T) len = length;
		return Vector2!T( x/length, y/length );
	}

	inout(Vector2!T) floor() inout
	{
		return Vector2!T( .floor(x), .floor(y) );
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

	Vector2!C opCast(C)()
	{
		Vector2!C vec;
		vec.x = cast(C)x;
		vec.y = cast(C)y;

		return vec;
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