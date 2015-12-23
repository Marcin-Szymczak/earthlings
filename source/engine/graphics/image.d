/+++
	Basic image manipulating facilities

	Authors: Marcin Szymczak
+++/
module engine.graphics.image;

import std.format;
import std.stdio;
import std.string;

import derelict.sdl2.image;
import derelict.sdl2.sdl;

import engine.graphics.core;
import engine.math;




/+++
	Structure containing image atlas data
+++/
struct Frame
{
	int x;
	int y;
	int w;
	int h;
	int cx;
	int cy;

	void toString( scope void delegate(const(char[])) sink )
	{
		sink( format("[pos: %s,%s;size: %s,%s;center: %s,%s]", x,y,w,h,cx,cy) );
	}
}
/+++
	Atlas data used by Images and Textures
+++/
struct Atlas
{
	int[] framepx, framepy;
	int[] framecx, framecy;

	int columns, rows;

	@property
	int frame_count()
	{
		return columns*rows;
	}

	/+++
		Check if the image contains valid atlas data.
	+++/
	static bool isValid( Image image )
	{
		// Top left corner has to be white.
		if( image.getPixel( 0, 0 ) != Color.white )
			return false;

		int blackc;
		int redc;
		// Check if number of red dots matches the number of black ones in the first row
		for( int x = 1; x<image.w; x++ ){
			auto col = image.getPixel( x, 0 );
			if( col == Color.blue ){
				blackc++;
				redc++;
			}else if( col == Color.red ){
				redc++;
			}else if( col == Color.black ){
				blackc++;
				if( blackc != redc ){
					return false;
				}
			}
		}

		if( blackc == 0 || redc == 0 )
			return false;

		blackc = 0;
		redc = 0;
		// Check if the number of red dots matches the number of black ones in the first column
		for( int y = 1; y<image.h; y++ ){
			auto col = image.getPixel( 0, y );
			if( col == Color.blue ){
				blackc++;
				redc++;
			}else if( col == Color.red ){
				redc++;
			}else if( col == Color.black ){
				blackc++;
				if( blackc != redc ){
					return false;
				}
			}
		}

		if( blackc == 0 || redc == 0 )
			return false;

		return true;
	}
	/+++
		Generates an image atlas data

		The specified image's first row and first column are special.
		Top left corner HAS to be of color white( 255, 255, 255 )
		They should be mostly white( 255, 255, 255 ).
		Every black( 0,0,0 ) point specifies end of current frame
		Every red( 255,0,0 ) point specifies the center point of current frame
		If you want the center to be at the end of the frame, use blue( 0, 0, 255 ) instead.
		There should be only ONE center point for each frame ( duh )
	+++/
	void generate( Image image )
	{
		framepx ~= 1;
		for( int x = 1; x<image.w; x++ )
		{
			Color col = image.getPixel( x, 0 );
			if( col == Color.red || col == Color.blue ){
				framecx ~= x;
			}
			if( col == Color.black || col == Color.blue ){
				framepx ~= x+1;
				columns++;
			}
		}

		framepy ~= 1;
		for( int y=1; y<image.h; y++ ){
			Color col = image.getPixel( 0, y );
			if( col == Color.red || col == Color.blue ){
				framecy ~= y;
			}
			if( col == Color.black || col == Color.blue ){
				framepy ~= y+1;
				rows++;
			}
		}

		if( framecx.length != columns || framecy.length != rows ){
			if( image.file_path )
				throw new Exception( format(
					"Atlas.generate malformed image '%s'. Not every frame has a centerpoint specified!
					(c:%s, r:%s, cx:%s, cy:%s)",
					image.file_path, columns, rows, framecx.length, framecy.length ) );
			else
				throw new Exception( "Atlas.generate malformed image. Not every frame has a centerpoint specified!" );
		}
	}

	/+++
		Retrieve a frame from the image atlas
	
		The frames are ordered left to right, row after row

		Returns:
			A frame object of the desired frame id
	+++/
	Frame getFrame( int index ) const
	{
		int x = index%columns;
		int y = index/columns%rows;

		Frame fr;
		fr.x = framepx[x];
		fr.y = framepy[y];
		fr.w = framepx[x+1] - fr.x;
		fr.h = framepy[y+1] - fr.y;
		fr.cx = framecx[x] - fr.x;
		fr.cy = framecy[y] - fr.y;

		return fr;
	}

	/+++
		Get the frame closest to the desired angle

		provided all the rows represent 180 degrees
	+++/
	Frame getAngleFrame( double angle, int offset=0 ) const
	{
		import std.math;
		import std.stdio;

		if( angle >= PI_2 && angle <= 3*PI_2 ){
			angle = PI - angle; 
		}else{
			angle = angle%PI;
		}
		
		double ang_per_frame = PI/rows;
		int row = cast(int)( (angle+PI_2)/ang_per_frame );
		int id = row*columns;

		id += offset%columns;
		return getFrame( id );
	}

	Frame opIndex( int index ) const
	{
		return getFrame( index );
	}
}

/+++
	Image containing surface which can be read pixel by pixel.
+++/
class Image
{
public:
	SDL_Surface* surface;
	Atlas* atlas;
	string file_path;

	///
	this(){}
	/// Create an image from filename
	this( string path )
	{
		loadFromFile( path );
	}
	/// Create an image from SDL_Surface
	this( SDL_Surface* surface )
	{
		this.surface = surface;
	}
	/// Create a blank image
	this( int w, int h )
	{
		create( w, h );
	}
	~this()
	{
		SDL_FreeSurface( surface );
	}

	void create( int w, int h )
	{
		surface = SDL_CreateRGBSurface( 0, w, h, 32, 
			0xff000000, 0x00ff0000, 0x0000ff00, 0x000000ff );
	}
	/+++
		Load an image from file.
	+++/
	void loadFromFile( string path )
	{
		surface = IMG_Load( path.toStringz );
		if( !surface )
			throw new Exception( format("Couldn't load image '%s', %s", path, IMG_GetError().fromStringz ));
		file_path = path.idup;
	}
	/+++
		Generate an image atlas to be used with image
	+++/
	void generateAtlas()
	{
		atlas = new Atlas;
		atlas.generate( this );
	}
	/+++
		Enable/Disable transparency on specified color.

		In example: you can make color black appear invisible by calling
		image.setTransparentColor( Color.black )

		To make it visible
		image.setTransparentColor( Color.black, false )
	+++/
	void setTransparentColor( Color color, bool transparent=true )
	{
		SDL_SetColorKey( surface, transparent, SDL_MapRGB( surface.format, color.r, color.g, color.b ) );
	}

	mixin template pixelComponent( string component )
	{
		static if( component == "red" )
		{
			uint mask = format.Rmask;
			uint shift = format.Rshift;
			uint loss = format.Rloss;
		}
		else static if( component == "green" )
		{
			uint mask = format.Gmask;
			uint shift = format.Gshift;
			uint loss = format.Gloss;
		}
		else static if( component == "blue" )
		{
			uint mask = format.Bmask;
			uint shift = format.Bshift;
			uint loss = format.Bloss;
		}
		else static if( component == "alpha" )
		{
			uint mask = format.Amask;
			uint shift = format.Ashift;
			uint loss = format.Aloss;
		}
		else
		{
			static assert(0, "unknown color component!");
		}
	}

	/+
		Method of color extracting taken from SDL2's wiki
		https://wiki.libsdl.org/SDL_PixelFormat
	+/
	pragma(inline,true)
	ubyte getPixelComponent(string component)( uint pixel, SDL_PixelFormat* format )
	{
		mixin pixelComponent!( component );

		uint temp = pixel & mask;
		temp >>= shift;
		temp <<= loss;
		return cast(ubyte) temp;
	}

	pragma(inline,true)
	uint getRawPixel( int x, int y, SDL_PixelFormat* format )
	{
		ubyte* ptr = cast(ubyte*)surface.pixels;
		ptr += y*surface.pitch;
		ptr += x*format.BytesPerPixel;

		return *(cast(uint*)ptr);
	}
	/+
		Method of color extracting taken from SDL2's wiki
		https://wiki.libsdl.org/SDL_PixelFormat
	+/
	/+++
		Get color at specified coordinates.

		returns Color at specified coordinates.
	+++/
	pragma(inline,true)
	Color getPixel( int x, int y )
	{
		auto format = surface.format;

		uint pixel = getRawPixel( x, y, format );
		uint temp;
		Color col;

		col.r = getPixelComponent!"red"( pixel, format );
		col.g = getPixelComponent!"green"( pixel, format );
		col.b = getPixelComponent!"blue"( pixel, format );
		if( format.Amask == 0 )
			col.a = 255;
		else
			col.a = getPixelComponent!"alpha"( pixel, format );

		return col;
	}

	pragma(inline,true)
	void setPixel( int x, int y, Color color )
	{
		auto format = surface.format;
		uint r = color.r >> format.Rshift;
		uint g = color.g >> format.Gshift;
		uint b = color.b >> format.Bshift;
		uint a = color.a >> format.Ashift;
		uint pixel = r + g + b + a ;

		ubyte* ptr = cast(ubyte*)surface.pixels;
		ptr += y*surface.pitch;
		ptr += x*format.BytesPerPixel;

		uint* intptr = cast(uint*)ptr;
		*intptr = pixel;
	}

	/+++
		Blit a image onto this one
	+++/
	void blit( Image image, Vector2f srcpos, Vector2f size, Vector2f destpos )
	{
		SDL_Rect src;
		src.x = cast(int)srcpos.x;
		src.y = cast(int)srcpos.y;
		src.w = cast(int)size.x;
		src.h = cast(int)size.y;

		SDL_Rect dst;
		dst.x = cast(int)destpos.x;
		dst.y = cast(int)destpos.y;
		dst.w = src.w;
		dst.h = src.h;

		SDL_BlitSurface( image.surface, &src, this.surface, &dst );
	}
	alias surface this;
}

/+++
	Texture residing in GPU's memory

	It can not be modified easily
+++/
class Texture
{
public:
	SDL_Texture* texture; /// Internal SDL_Texture*
	Atlas* atlas; /// The atlas inherited from image
	int w, h; /// Its width and height

	///
	this(){}
	/+++
		Initialize a texture with an image
	+++/
	this( Image img )
	{
		texture = SDL_CreateTextureFromSurface( current_renderer, img );
		if(!texture)
			throw new Exception( "Texture.this couldn't create a texture from image");
		atlas = img.atlas;
		w = img.w;
		h = img.h;
	}
	/+++
		Initialize a texture with a SDL surface
	+++/
	this( SDL_Surface* surface )
	{
		texture = SDL_CreateTextureFromSurface( current_renderer, surface );
		if(!texture)
			throw new Exception( "Texture.this couldn't create a texture from surface");
		w = surface.w;
		h = surface.h;
	}
	~this(){
		SDL_DestroyTexture( texture );
	}
	alias texture this;
}

/+++
	Draw a texture

	You can specify the rotation, scale and centerpoint around which it is rotated.
+++/
void draw(	Texture tex,
			Vector2f pos,
			float rotation = 0,
			Vector2f scale = Vector2f(1,1),
			Vector2f center = Vector2f(0,0),
			Flip flip = Flip.None )
{
	/+ Apply current transformations +/
	pos = current_transformation.get( pos );

	SDL_Rect dst;
	dst.x = cast(int)pos.x;
	dst.y = cast(int)pos.y;
	dst.w = cast(int)(tex.w*scale.x);
	dst.h = cast(int)(tex.h*scale.y);

	SDL_Point sdlcenter;
	sdlcenter.x = cast(int)center.x;
	sdlcenter.y = cast(int)center.y;

	int blendmode;
	SDL_GetRenderDrawBlendMode( current_renderer, &blendmode );
	SDL_SetTextureBlendMode( tex, blendmode );

	SDL_RenderCopyEx( current_renderer, tex, null, &dst, rotation, &sdlcenter, flip );
}
/+++
	Draw a texture's frame from its atlas
+++/
void draw( 	const Texture tex,
			int frame,
			Vector2f position,
			float rotation = 0,
			Vector2f scale = Vector2f(1,1),
			Vector2f center = Vector2f(0,0),
			Flip flip = Flip.None )
{
	if( !tex.atlas )
		throw new Exception( "Can not draw a texture's frame if it has no atlas!");
	
	draw( tex, tex.atlas.getFrame( frame ), position, rotation, scale, center, flip );
}

/+++
	Draw a texture's frame from its atlas

	Params:
		tex = the texture to be drawn
		frame = the portion of texture to be drawn
		position = the position
		rotation = angle in radians
		scale = scale
		center = rotation-axis and the center of image
		flip = should the image be flipped?
+++/
void draw( 	const Texture tex,
			const Frame frame,
			Vector2f position,
			float rotation = 0,
			Vector2f scale = Vector2f(1,1),
			Vector2f center = Vector2f(0,0),
			Flip flip = Flip.None )
{
	import std.math;

	if( !tex.atlas )
		throw new Exception( "Can not draw a texture's frame if it has no atlas!");
	
	/+ Apply current transformations +/
	position = current_transformation.get( position );
	
	SDL_Rect src;
	src.x = cast(int)frame.x;
	src.y = cast(int)frame.y;
	src.w = cast(int)frame.w;
	src.h = cast(int)frame.h;

	SDL_Rect dst;
	dst.x = cast(int)(position.x-(frame.cx+center.x)*abs(scale.x));
	dst.y = cast(int)(position.y-(frame.cy+center.y)*abs(scale.y));
	dst.w = cast(int)(frame.w*abs(scale.x));
	dst.h = cast(int)(frame.h*abs(scale.y));

	if( scale.x < 0 )
	{
		dst.x--; //Image after flipping should be located around the same point
		flip += Flip.Horizontal;
	}
	if( scale.y < 0 )
	{
		dst.y--;
		flip += Flip.Vertical;
	}

	SDL_Point sdlcenter;
	sdlcenter.x = cast(int)(center.x+frame.cx);
	sdlcenter.y = cast(int)(center.y+frame.cy);

	int blendmode;
	SDL_Texture* texture = cast(SDL_Texture*)tex.texture;
	SDL_GetRenderDrawBlendMode( current_renderer, &blendmode );
	SDL_SetTextureBlendMode( texture, blendmode );
	SDL_SetTextureColorMod( texture, current_color.r, current_color.g, current_color.b );
	SDL_SetTextureAlphaMod( texture, current_color.a );
	SDL_RenderCopyEx( current_renderer, cast(SDL_Texture*)tex.texture, &src, &dst, rotation, &sdlcenter, flip );
}