module engine.graphics.core;

import std.algorithm;
import std.conv;
import std.format;
import std.functional;
import std.range;

import derelict.sdl2.sdl;

import engine.math;
import engine.window.core;




Renderer current_renderer;
Color current_color;
Transformation current_transformation;

///The Blend Modes with which you can draw
enum BlendMode
{
	None = SDL_BLENDMODE_NONE, ///No blending
	Blend = SDL_BLENDMODE_BLEND, ///Simple alpha blending
	Add = SDL_BLENDMODE_ADD, ///Additive blending
	Modulate = SDL_BLENDMODE_MOD, ///Modulative blending
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

	int w, h;

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

	@property Vector2f size()
	{
		int w, h;
		SDL_GetRendererOutputSize( _renderer, &w, &h );
		return Vector2f( cast(float)w, cast(float)h );
	}

	alias _renderer this;
}

/+++
	Graphical transformation
+++/
struct Transformation
{
	Vector2f _translation = {0,0};
	Vector2f _scale = {1,1};

	void scale( Vector2f scale )
	{
		_scale = scale;
		_translation /= scale;
	}

	void translate( Vector2f translation )
	{
		_translation += translation;
	}

	Vector2f get(bool scale=true)( Vector2f point )
	{
		static if(scale == true)
			return (point + _translation)*scale;
		else
			return point + _translation;
	}

	void origin()
	{
		_translation = Vector2f(0,0);
		_scale = Vector2f(1,1);
	}
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

	SDL_Color toSDL_Color()
	{
		return SDL_Color( this.r, this.g, this.b, this.a );
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

/+++
	Set the currently used renderer

	NOTE: You shouldn't need to call it more than once
+++/
void setRenderer( Renderer renderer )
{
	current_renderer = renderer;
}
/+++
	Set the current renderer's Blend mode
+++/
void setBlendMode( BlendMode blendmode )
{
	SDL_SetRenderDrawBlendMode( current_renderer, blendmode );
}
/+++
	Set the drawing color
+++/
void setColor( ubyte r, ubyte g, ubyte b, ubyte a )
{
	SDL_SetRenderDrawColor( current_renderer, r, g, b, a );
	
	current_color.r = r;
	current_color.g = g;
	current_color.b = b;
	current_color.a = a;
}
///
void setColor( Color color )
{
	setColor( color.r, color.g, color.b, color.a );
}
void translate( Vector2f translation )
{
	current_transformation.translate( translation );
}
/+++
	Set the drawing scale
+++/
void setScale( Vector2f scale )
{
	current_transformation.scale( scale );
	SDL_RenderSetScale( current_renderer, scale.x, scale.y );
}
/+++
	Get the available drawing area ( size of the screen )
+++/
Vector2f getSize()
{
	return current_renderer.size;
}
/+++
	Get current drawing scale
+++/
Vector2f getScale()
{
	Vector2f scale;
	SDL_RenderGetScale( current_renderer, &scale.x, &scale.y );
	return scale;
}