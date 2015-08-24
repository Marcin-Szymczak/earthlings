/+++
	Basic bitmap font support

	Authors: Marcin Szymczak
+++/
module engine.graphics.font;

import std.exception;
import std.file;
import std.format;
import std.path;
import std.stdio;
import std.string;
import std.typecons;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import engine.graphics.core;
import engine.graphics.image;



/+++
	Font interface

	Every font should implement these
+++/
interface Font
{
	void loadFromFile( string path, int size=11 );
	Texture createTexture( string text );
	Image createImage( string text );
}

class TTFFont : Font
{
	TTF_Font* font;

	this(){}
	this( string path, int size )
	{
		loadFromFile( path, size );
	}

	void loadFromFile( string path, int size )
	{
		font = TTF_OpenFont( path.toStringz, size );
		if(!font)
			throw new Exception( format( "Couldn't open font file '%s' (%s)", path, TTF_GetError().fromStringz ) );
	}

	Image createImage( string text )
	{
		return new Image( TTF_RenderUTF8_Blended( font, text.toStringz, current_color.toSDL_Color) );
	}

	Texture createTexture( string text )
	{
		SDL_Surface* surface = TTF_RenderUTF8_Blended( font, text.toStringz, current_color.toSDL_Color );
		Texture tex = new Texture( surface );
		SDL_FreeSurface( surface );
		return tex;		
	}
}

class BMPFont : Font
{
	//Texture font;
	Image font;
	int[dchar] chars;

	this(){}
	this( string path, int size )
	{
		loadFromFile( path, size );
	}

	void loadFromFile( string path, int size )
	{
		string configpath = path.setExtension( ".cfg" );
		enforce( exists( configpath ), format( "File %s not found!", configpath ));
		enforce( exists( path ), format( "File %s not found!", path ));

		//Image image = scoped!Image( path );
		font = new Image( path );
		font.generateAtlas();

		auto config = File( configpath, "r" );
		int counter;
		dchar ch;

		while( !config.eof )
		{
			config.readf( "%s", &ch );
			writefln( "%s is index %s", ch, counter );
			chars[ch] = counter++;
		}
	}

	Frame getFrame( dchar ch )
	{
		int index = chars.get( ch, 0 );
		return font.atlas.getFrame( index );
	}

	int getLength( string text )
	{
		int len;
		foreach( ch; text )
		{
			len += getFrame( cast(dchar)ch ).w;
		}

		return len;
	}

	int getHeight()
	{
		return getFrame( '?' ).h;
	}

	Image createImage( string text )
	{
		return new Image;
	}

	Texture createTexture( string text )
	{
		int w = getLength( text );
		int h = getHeight();

		SDL_Surface* surf = SDL_CreateRGBSurface( 0, w, h, 24, 0xff000000, 0x00ff0000, 0x0000ff00, 0x000000ff );

		int x = 0;

		foreach( ch; text )
		{

			Frame fr = getFrame( ch );
			SDL_Rect src;
			SDL_Rect dst;

			src.x = fr.x;
			src.y = fr.y;
			src.w = fr.w;
			src.h = fr.h;

			dst.x = x;
			dst.y = 0;
			dst.w = fr.w;
			dst.h = fr.h;
			
			x+=fr.w;

			SDL_BlitSurface( font, &src, surf, &dst );
		}
		return new Texture( surf );
	}
}