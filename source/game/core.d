module game.core;

import core.memory;
import std.format;
import std.math;
import std.range;
import std.stdio;

import engine;
import game;

TextureManager texture_manager;
double TIME=0;

Player local_player;

Texture simple_text;

Font mono;

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

	local_player = new Player;
	local_player.name = "Local Player";

	auto worm = new Worm();
	local_player.entity = worm;

	local_player.entity.position = Vector2f( 500, 50 );


	mono = new TTFFont( "data/fonts/ubuntu_mono.ttf", 14 );

	/+ test the speed of rendering textures +/

	GC.collect();

	Benchmark bench;
	bench.start( "Rendering 100 000 Hello World!s");
	for( int i = 0; i<100_000; i++ )
	{
		auto texture = mono.createTexture( "Hello World!" );
	}
	writeln( bench.end() );

	GC.collect();

	bench.start( "Creating 100 000 Images of Hello World!" );
	Image image = new Image( 512, 512 );
	
	for( int i =0; i<100_000; i++ )
	{
		auto text = mono.createImage( "Hello World!" );
		image.blit( text, Vector2f( 0, 0 ), Vector2f( text.w, text.h ), Vector2f( 0, 0 ) );
		
	}
	writeln( bench.end() );

	GC.enable();
}

void update(double delta)
{
	TIME += delta;

	current_level.update( delta );
	local_player.entity.update( delta );
}

void draw()
{	
	current_transformation.origin;

	translate( getSize()/2 );
	graphics.setScale( Vector2f( 2, 2 ) );
	translate( -local_player.entity.position );

	float angle = TIME;

	current_level.draw();
	local_player.entity.draw();
}
