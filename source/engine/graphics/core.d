module engine.graphics.core;

import std.algorithm;
import std.conv;
import std.format;
import std.functional;
import std.range;

import derelict.sdl2.sdl;

import engine.window.core;

Renderer current_renderer;

enum BlendMode
{
	None = SDL_BLENDMODE_NONE,
	Blend = SDL_BLENDMODE_BLEND,
	Additive = SDL_BLENDMODE_ADD,
	Modulate = SDL_BLENDMODE_MOD,
}

enum Flip : SDL_RendererFlip
{
	None = SDL_FLIP_NONE,
	Horizontal = SDL_FLIP_HORIZONTAL,
	Vertical = SDL_FLIP_VERTICAL,
	Both = SDL_FLIP_HORIZONTAL | SDL_FLIP_VERTICAL,
}

class Renderer
{
	SDL_Renderer* _renderer;

	this( Window window, int index=0, uint flags=0 )
	{
		_renderer = SDL_CreateRenderer( window, index, flags );
		if( !_renderer )
			throw new Exception( "Couldn't create a window" );
	}

	~this()
	{
		SDL_DestroyRenderer( _renderer );
	}

	alias _renderer this;
}

struct Transformation
{
	
}

struct Color
{
	ubyte r,g,b,a;

	this( ubyte r, ubyte g, ubyte b, ubyte a )
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	this( ubyte r, ubyte g, ubyte b )
	{
		this( r, g, b, 255 );
	}

	this( string hex_string )
	{
		this = fromHex( hex_string );
	}

	static Color _fromHex( string str )
	{
		if( str.length != 7 || str[0] != '#' )
			throw new Exception( format( "Color.hex malformed input '%s'", str ) );

		Color color;
		color.r = to!ubyte( str[1..3], 16 );
		color.g = to!ubyte( str[3..5], 16 );
		color.b = to!ubyte( str[5..7], 16 );
		color.a = 255;

		return color;
	}

	alias fromHex = memoize!_fromHex;

	static Color hex(string str)()
	{
		return _fromHex( str );
	}

	void toString( scope void delegate( const(char)[] ) sink )
	{
		sink( format( "(%s,%s,%s,%s)", r, g, b, a ) );
	}

	enum Color blank = Color( 0, 0, 0, 0 );
	enum Color black = hex!("#000000");
	enum Color white = hex!("#FFFFFF");
	enum Color red = hex!("#FF0000");
	enum Color green = hex!("#00FF00");
	enum Color blue = hex!("#0000FF");
	enum Color yellow = hex!("#FFFF00");
	enum Color cyan = hex!("#00FFFF");
	enum Color magenta = hex!("#FF00FF");
}