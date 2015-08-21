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

struct Atlas
{
	int[] framepx, framepy;
	int[] framecx, framecy;

	int columns, rows;
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
			}else if( col == Color.black || col == Color.blue ){
				framepx ~= x+1;
				columns++;
			}
		}

		framepy ~= 1;
		for( int y=1; y<image.h; y++ ){
			Color col = image.getPixel( 0, y );
			if( col == Color.red || col == Color.blue ){
				framecy ~= y;
			}else if( col == Color.black || col == Color.blue ){
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

	Frame opIndex( int index )
	{
		return getFrame( index );
	}
}

/+++
	Image containing surface which can be read pixel by pixel.
+++/
class Image
{
private:
	Atlas* atlas;

public:
	SDL_Surface* surface;
	string file_path;

	this(){}
	this( string path )
	{
		loadFromFile( path );
	}
	~this()
	{
		SDL_FreeSurface( surface );
	}
	/+++
		Load an image from file.
	+++/
	void loadFromFile( string path )
	{
		surface = IMG_Load( path.toStringz );//SDL_LoadBMP( path.toStringz );
		if( !surface )
			throw new Exception( format("Couldn't load image '%s', %s", path, SDL_GetError().fromStringz ));
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
	/+++
		Get color at specified coordinates.

		returns Color at specified coordinates.
	+++/
	Color getPixel( int x, int y )
	{
		auto format = surface.format;

		ubyte* ptr = cast(ubyte*)surface.pixels;
		ptr += y*surface.pitch;
		ptr += x*format.BytesPerPixel;

		uint pixel = *(cast(uint*)ptr);
		uint temp;
		Color col;

		/++
			Method of color extracting taken from SDL2's wiki
			https://wiki.libsdl.org/SDL_PixelFormat
		++/
		temp = pixel & format.Rmask;
		temp = temp >> format.Rshift;
		temp = temp << format.Rloss;
		col.r = cast(ubyte)temp;

		temp = pixel & format.Gmask;
		temp = temp >> format.Gshift;
		temp = temp << format.Gloss;
		col.g = cast(ubyte)temp;

		temp = pixel & format.Bmask;
		temp = temp >> format.Bshift;
		temp = temp << format.Bloss;
		col.b = cast(ubyte)temp;

		if( format.Amask == 0 ){
			col.a = 255;
		}else{
			temp = pixel & format.Amask;
			temp = temp >> format.Ashift;
			temp = temp << format.Aloss;
			col.a = cast(ubyte)temp;
		}
		return col;
	}

	alias surface this;
}

/+++
	Texture residing in GPU's memory

	It can not be modified
+++/
class Texture
{
public:
	SDL_Texture* texture;
	Atlas* atlas;
	int w, h;

	this(){}
	/+++
		Initialize a texture with a surface
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
	Draw a texture to the screen

	x,y is the top-left of the drawn texture
+++/
void draw( Texture tex, float x, float y )
{
	/+
	SDL_Rect src;
	src.x = 0;
	src.y = 0;
	src.w = tex.w;
	src.h = tex.h;
	+/
	SDL_Rect dest;
	dest.x = cast(int)x;
	dest.y = cast(int)y;
	dest.w = tex.w;
	dest.h = tex.h;

	SDL_RenderCopy( current_renderer, tex, null, &dest );
}

void draw( Texture tex, int fr, float x, float y )
{
	if(!tex.atlas){
		throw new Exception( "Can not draw a frame of Texture without an image atlas!");
		//draw( tex, x, y );
		//return;
	}

	Frame frame = tex.atlas.getFrame(fr);

	SDL_Rect src;
	src.x = frame.x;
	src.y = frame.y;
	src.w = frame.w;
	src.h = frame.h;

	SDL_Rect dest;
	dest.x = cast(int)x - frame.cx;
	dest.y = cast(int)y - frame.cy;
	dest.w = frame.w;
	dest.h = frame.h;

	SDL_RenderCopy( current_renderer, tex, &src, &dest );
}

/+++
	Draw an texture with additional options

	You can specify the rotation, scale and centerpoint around which it is rotated.
+++/
void draw(	Texture tex,
			Vector2f pos,
			float rotation = 0,
			Vector2f scale = Vector2f(1,1),
			Vector2f center = Vector2f(0,0),
			Flip flip = Flip.None )
{
	SDL_Rect dst;
	dst.x = cast(int)pos.x;
	dst.y = cast(int)pos.y;
	dst.w = cast(int)(tex.w*scale.x);
	dst.h = cast(int)(tex.h*scale.y);

	SDL_Point sdlcenter;
	sdlcenter.x = cast(int)center.x;
	sdlcenter.y = cast(int)center.y;

	SDL_RenderCopyEx( current_renderer, tex, null, &dst, rotation, &sdlcenter, flip );
}

void draw( 	const Texture tex,
			int frame,
			const Vector2f pos,
			float rotation = 0,
			Vector2f scale = Vector2f(1,1),
			Vector2f center = Vector2f(0,0),
			Flip flip = Flip.None )
{
	if( !tex.atlas )
		throw new Exception( "Can not draw a texture's frame if it has no atlas!");
	
	Frame fr = tex.atlas.getFrame(frame);
	SDL_Rect src;
	src.x = cast(int)fr.x;
	src.y = cast(int)fr.y;
	src.w = cast(int)fr.w;
	src.h = cast(int)fr.h;

	SDL_Rect dst;
	dst.x = cast(int)(pos.x-fr.cx+center.x);
	dst.y = cast(int)(pos.y-fr.cy+center.y);
	dst.w = cast(int)(fr.w*scale.x);
	dst.h = cast(int)(fr.h*scale.y);

	SDL_Point sdlcenter;
	sdlcenter.x = cast(int)(center.x-fr.cx);
	sdlcenter.y = cast(int)(center.y-fr.cy);

	SDL_RenderCopyEx( current_renderer, cast(SDL_Texture*)tex.texture, &src, &dst, rotation, &sdlcenter, flip );
}