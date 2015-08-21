module game.core;

import std.format;
import std.math;
import std.range;
import std.stdio;

import engine;
import game;

TextureManager texture_manager;
double TIME=0;

Level level;

Worm worm;

Font testfont;
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


	level = new Level( "mars" );

	worm = new Worm();
	worm.position = Vector2f( 300, 300 );

	testfont = new TTFFont;
	testfont.loadFromFile( "data/fonts/UbuntuMono-Regular.ttf", 24 );

}

void update(double delta)
{
	TIME += delta;
	level.update( delta );
	simple_text = testfont.render( format( "FPS: %s", 1/delta ) );
}

void draw()
{
	float angle = TIME;

	Vector2f pos = {100, 100};
	Vector2f aimpos = pos + Vector2f( 0, -5 );

	graphics.setScale( Vector2f( 2, 2 ) );
	graphics.setColor( Color.hex!"#C0ECF7" );
	graphics.clear();

	level.draw();
	worm.draw();

	Vector2f scale = getScale();
	graphics.setScale( Vector2f( 1, 1 ) );
	graphics.setColor( Color.black );
	graphics.draw( simple_text, 0, 0 );

	graphics.setScale( scale );
}
