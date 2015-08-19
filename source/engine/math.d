module engine.math;

alias Vector2f = Vector2!float;
alias Vector2d = Vector2!double;

struct Vector2(T)
{
	T x;
	T y;

	Vector2!T opBinary( string op )( Vector2!T rhs )
	{
		static if( op == "+" || op == "-" || op == "*" || op == "/" ){
			mixin( "return Vector2!T( x "~op~" rhs.x, y "~op~" rhs.y );");
		}else
			static assert( 0, "Vector!T operation "~op~" not supported");
	}
	Vector2!T opBinary( string op )( T rhs )
	{
		static if( op == "*" || op == "/" ){
			mixin( "return Vector2!T( x "~op~" rhs, y "~op~" rhs );");
		}else
			static assert( 0, "Vector!T operation "~op~" not supported");
	}
}