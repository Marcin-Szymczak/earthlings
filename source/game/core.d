module game.core;

import std.range;
import std.stdio;

import engine;
import game.resource_manager;

TextureManager texman;
double TIME=0;


void initialize()
{
	texman = new TextureManager;
	texman.setBasePath( "data/graphics/" );
	texman.setTransparentColor( Color.magenta );
	writeln( Color.magenta );
	/++auto img = new Image;
	img.loadFromFile( "data/graphics/test.bmp" );
	img.setTransparentColor( Color.white );
	img.generateAtlas();
	tex = new Texture( img );
	++/
	texman.register( "test.bmp" );
	texman.register( "worm.bmp" );
}

void update(double delta)
{
	TIME += delta;
}

void draw()
{
	graphics.setColor( Color.hex!"#C0ECF7" );
	graphics.clear();

	graphics.setColor( Color.white );
	graphics.draw( texman["test.bmp"], 50, 50 );
	graphics.draw( texman["worm.bmp"], cast(int)TIME, 20, 20 );
}
