module game.level.core;

import std.file;
import std.stdio;
import std.typecons;

import engine;
import game.defines;

Level current_level;

struct Material
{
	enum Property : uint
	{
		None = 0,
		Solid = 1<<0,
		Destructible = 1<<1,
	}

	enum Type
	{
		Air,
		Rock,
		Dirt,
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

	int w,h;
	string name;

	bool dirty = true;

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

		this.name = name;

		string path = path_levels ~ name ~ "/";

		/+ Load available images -> foreground, material and optionally background +/
		fg_img = new Image( path ~ "fg.png" );
		fg = new Texture( fg_img );
		if( exists( path ~ "bg.png" ) ){
			bg_img = new Image( path ~ "bg.png" );
			bg = new Texture( bg_img );
		}
		auto mat_img = scoped!Image( path ~ "mat.png" );

		/+ Calculate material types out of mat file +/
		mat.length = mat_img.w*mat_img.h;
		for( int y; y < mat_img.h; y++ )
			for( int x; x < mat_img.w; x++ )
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

		w = mat_img.w;
		h = mat_img.h;


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

	bool inBounds( Vector2f pos )
	{
		int x,y;
		x = cast(int)pos.x;
		y = cast(int)pos.y;

		return x >= 0 && x < w && y >= 0 && y < h;
	}

	bool isSolid( Vector2f pos )
	{
		int x,y;
		x = cast(int)pos.x;
		y = cast(int)pos.y;

		//Beyond the level it is always solid
		if( !inBounds(pos) ){
			return true;		
		}
		Material pixel = Material.types[ mat[x + y*w] ];
		if( (pixel.property & Material.Property.Solid) == Material.Property.Solid ){
			return true;
		}else{
			return false;
		}
	}

	void erase( Vector2f pos )
	{
		fg_img.setPixel( cast(int)pos.x, cast(int)pos.y, Color( 0, 0, 0, 0 ) );
		mat[cast(int)pos.x + cast(int)pos.y*w] = Material.Type.Air;
		dirty=true;
	}

	void eraseSquare( Vector2f pos, Vector2f size )
	{
		for( float x=pos.x-size.x/2; x<=pos.x+size.x/2; x++ )
		{
			for( float y=pos.y-size.y/2; y<=pos.y+size.y/2; y++ )
			{
				if( inBounds( Vector2f( x,y ) ) )
				{
					erase( Vector2f( x, y ) );
				}
			}
		}
	}

	void eraseCircle( Vector2f pos, float radius )
	{
		import std.math;

		for( float x=pos.x-radius; x<=pos.x+radius; x++ )
		{
			for( float y=pos.y-radius; y<=pos.y+radius; y++ )
			{
				if( inBounds( Vector2f(x,y) ) && sqrt( (x-pos.x)^^2 + (y-pos.y)^^2 ) <= radius )
					erase( Vector2f( x, y ) );
			}
		}
	}

	void damage( Vector2f pos )
	{

	}

	Vector2f dropDown( Vector2f pos )
	{
		while( !isSolid( pos ) )
		{
			pos.y++;
		}	
		pos.y--;
		return pos;
	}

}

bool isSolid( Vector2f position )
{
	return current_level.isSolid( position );
}

Vector2f dropDown( Vector2f position )
{
	return current_level.dropDown( position );
}