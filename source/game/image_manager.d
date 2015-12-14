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
	}

	void setTransparentColor( Color color )
	{
		transparent = color;
	}

	override void loadFromFile( string path, bool relative=true )
	{
		string full_path = path;
		if( relative )
			full_path = base_path ~ path;
		Image img = scoped!Image(full_path);
		if( transparent != Color.blank )
			SDL_SetColorKey( img, true, SDL_MapRGB( img.format, transparent.r, transparent.g, transparent.b ) );
		writef( "Loading %s ", path);
		if( Atlas.isValid( img ) ){
			write( "with texture atlas");
			img.generateAtlas();
		}
		write("\n");
		Texture tex = new Texture(img);
		if( path in resource )
			free( path );

		resource[path] = tex;
	}
	override void free( string path )
	{

	}
}