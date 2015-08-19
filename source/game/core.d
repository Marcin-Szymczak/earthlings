module game.core;

import std.math;
import std.range;
import std.stdio;

import engine;
import game;

TextureManager texman;
double TIME=0;

Level level;

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
	texman = new TextureManager;
	texman.setBasePath( path_graphics );
	texman.loadDirectory( "." );

	graphics.setScale( 2, 2 );

	level = new Level( "first" );

}

void update(double delta)
{
	TIME += delta;
	level.update( delta );
}

void draw()
{
	float angle = TIME;

	Vector2f pos = {100, 100};
	Vector2f aimpos = pos + Vector2f( 0, -5 );

	graphics.setColor( Color.hex!"#C0ECF7" );
	graphics.clear();

	level.draw();
}
