module game.level.core;

import std.stdio;

import engine;
import game.defines;

class Level
{
private:
	Image fg;
	Image mat;

	Texture fg_tex;

	bool dirty = false;

public:

	enum Material
	{
		Air = Color.white,
		Solid = Color.black,
	}

	this(){}

	this( string path )
	{
		loadFromFile( path );
	}

	void loadFromFile( string path )
	{
		fg = new Image( path_levels ~ path ~ "/fg.png" );
		mat = new Image( path_levels ~ path ~ "/mat.png" );

		writefln( "Level '%s' loaded!", path );

		dirty = true;
	}

	void refresh()
	{
		fg_tex = new Texture( fg );
		dirty = false;
	}

	void update( double time )
	{
		if(dirty)
			refresh();
	}

	void draw()
	{
		if( fg_tex is null )
			return;

		setColor( Color.white );
		graphics.draw( fg_tex, Vector2f( 0, 0 ) );
	}

}