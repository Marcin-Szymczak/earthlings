/+++
	Resource manager

	Authors: Marcin Szymczak
+++/
module game.resource_manager;

import std.range;
import std.typecons;

import derelict.sdl2.sdl;

import engine;

class ResourceManager(T)
{
	T[string] resource;
	abstract void register( string );
	abstract void free( string );
	alias resource this;
}

class TextureManager : ResourceManager!Texture
{
	string base_path;
	Color transparent;

	void setTransparentColor( Color color )
	{
		transparent = color;
	}
	void setBasePath( string path )
	{
		base_path = path;
	}
	override void register( string path )
	{
		string full_path = base_path ~ path;
		Image img = scoped!Image(full_path);

		if( transparent != Color.blank )
			SDL_SetColorKey( img, true, SDL_MapRGB( img.format, transparent.r, transparent.g, transparent.b ) );

		img.generateAtlas();
		Texture tex = new Texture(img);
		resource[path] = tex;
	}
	override void free( string path )
	{

	}
	alias resource this;
}