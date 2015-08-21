/+++
	Basic bitmap font support

	Authors: Marcin Szymczak
+++/
module engine.graphics.font;

import std.exception;
import std.format;
import std.string;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import engine.graphics.core;
import engine.graphics.image;

interface Font
{
	//void generateGlyphs();
	void loadFromFile( string path, int size );
	Texture render( string text );
}

class TTFFont : Font
{
	TTF_Font* font;

	this(){}

	void loadFromFile( string path, int size )
	{
		font = TTF_OpenFont( path.toStringz, size );
		if(!font)
			throw new Exception( format( "Couldn't open font file '%s' (%s)", path, TTF_GetError().fromStringz ) );
	}

	Texture render( string text )
	{
		SDL_Surface* surface = TTF_RenderUTF8_Blended( font, text.toStringz, current_color.toSDL_Color );
		Texture tex = new Texture( surface );
		SDL_FreeSurface( surface );
		return tex;
	}
}

/++
class Font
{
	Image image;

	int[string] letters;
	Texture[string] glyphs;

	this(){}
	this( string path )
	{
		loadFromFile( path );
	}

	void loadFromFile( string path )
	{

	}

	void generateGlyphs()
	{
		foreach( letter; letters )
		{

		}
	}

	alias letters this;
}
++/