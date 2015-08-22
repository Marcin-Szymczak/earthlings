module game.core;

import std.digest.sha;
import std.format;
import std.math;
import std.range;
import std.stdio;

import engine;
import game;

TextureManager texture_manager;
double TIME=0;

Worm worm;

Font testfont;
Font testbitmap;
Texture simple_text;

/+++
	Get the frame closest to the desired angle

	provided the vertical frames represent 180 degrees
+++/
int getAngleFrame( float angle, int vertical_frames )
{
	float ang_per_fr = PI/vertical_frames;
	int frame = cast(int)( (angle+PI_2)/ang_per_fr );

	return frame;
}

void initialize()
{
	texture_manager = new TextureManager;
	texture_manager.setBasePath( path_graphics );
	texture_manager.loadDirectory( "." );


	current_level = new Level( "mars" );

	worm = new Worm();
	worm.position = Vector2f( 500, 50 );

	testfont = new TTFFont;
	testfont.loadFromFile( "data/fonts/UbuntuMono-Regular.ttf", 24 );

	testbitmap = new BMPFont;
	testbitmap.loadFromFile( "data/fonts/small.png", 24 );
}

void update(double delta)
{
	TIME += delta;
	current_level.update( delta );
	worm.update( delta );
	simple_text = testfont.render( format( "FPS: %s", 1/delta ) );
}

void draw()
{	
	current_transformation.origin;

	translate( getSize()/2 );
	graphics.setScale( Vector2f( 2, 2 ) );
	translate( -worm.position );

	float angle = TIME;

	current_level.draw();
	worm.draw();

	Vector2f scale = getScale();
	graphics.setScale( Vector2f( 1, 1 ) );
	graphics.setColor( Color.black );
	graphics.draw( simple_text, 0, 0 );

	graphics.draw( testbitmap.render("HELLO BITMAP! 1234567890 1337 ELITE abcdefghijklmnoprstuvwxyz"), 0, 36 );

	graphics.setScale( scale );
}
