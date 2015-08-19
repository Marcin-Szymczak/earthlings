/+++
	Resource manager

	Authors: Marcin Szymczak
+++/
module game.image_manager;

import std.stdio;
import std.typecons;

import derelict.sdl2.sdl;

import engine;

class TextureManager : ResourceManager!Texture
{
	Color transparent;

	this()
	{
		pattern = "*.{bmp,png}";

		// Create a surface with default R, G, B mask.
		SDL_Surface* surface = SDL_CreateRGBSurface( 0, 64, 64, 24, 0xff000000, 0x00ff0000, 0x0000ff00, 0x000000ff );
		SDL_FillRect( surface, null, SDL_MapRGB( surface.format, 255, 0, 255 ) );
		unavailable = new Texture( surface );
		SDL_FreeSurface( surface );
	}

	void setTransparentColor( Color color )
	{
		transparent = color;
	}
	override void load( string path )
	{
		Image img = scoped!Image(path);
		if( transparent != Color.blank )
			SDL_SetColorKey( img, true, SDL_MapRGB( img.format, transparent.r, transparent.g, transparent.b ) );
		writef( "Loading %s ", path);
		if( Atlas.isValid( img ) ){
			write( "with texture atlas");
			img.generateAtlas();
		}
		write("\n");
		Texture tex = new Texture(img);
		resource[path] = tex;
	}
	override void free( string path )
	{

	}
	alias resource this;
}