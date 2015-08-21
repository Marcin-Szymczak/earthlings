module game.level.core;

import std.file;
import std.stdio;
import std.typecons;

import engine;
import game.defines;


struct Material
{
	enum Property : uint
	{
		None = 0,
		Solid = 1<<0,
		Destructible = 1<<1,
	}

	string name;
	Color color;
	Property property;

	static Material[] types = [
		{"air", Color(255,255,255), Property.None},
		{"rock", Color(0,0,0), Property.Solid},
		{"dirt", Color(128,64,0), Property.Solid | Property.Destructible}
	];
}

class Level
{

private:
	ubyte[] mat;

	Image fg_img;
	Image bg_img;

	Texture fg;
	Texture bg;

	bool dirty = false;

public:

	this(){}

	this( string path )
	{
		loadFromFile( path );
	}

	void loadFromFile( string name )
	{
		fg_img = null;
		bg_img = null;
		fg = null;
		bg = null;

		string path = path_levels ~ name ~ "/";
		fg_img = new Image( path ~ "fg.png" );
		fg = new Texture( fg_img );

		if( exists( path ~ "bg.png" ) ){
			bg_img = new Image( path ~ "bg.png" );
			bg = new Texture( bg_img );
		}
		auto mat_img = scoped!Image( path ~ "mat.png" );

		mat.length = mat_img.w*mat_img.h;

		for( int y; y < mat_img.h; y++ )
			for( int x; x< mat_img.w; x++ )
			{
				Color color = mat_img.getPixel( x, y );

				foreach( index, material; Material.types )
				{
					if( material.color == color ){
						mat[x+y*mat_img.w] = cast(ubyte)index;
						break;
					}
				}
			}

		//writefln( "Level '%s' loaded!", path );

		dirty = true;
	}

	void refresh()
	{
		fg = new Texture( fg_img );
		dirty = false;
	}

	void update( double time )
	{
		if(dirty)
			refresh();
	}

	void draw()
	{
		setColor( Color.white );
		if( bg !is null )
			graphics.draw( bg, Vector2f( 0, 0 ) );

		if( fg !is null )
			graphics.draw( fg, Vector2f( 0, 0 ) );
	}

}