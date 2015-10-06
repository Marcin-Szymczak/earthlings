module game.core;

import core.memory;
import std.format;
import std.math;
import std.range;
import std.stdio;

import engine;
import game;

TextureManager texture_manager;
EntityManager entity_manager;
double TIME=0;

Player local_player;

Texture simple_text;
void initialize()
{
	texture_manager = new TextureManager;
	texture_manager.setBasePath( path_graphics );
	texture_manager.loadDirectory( "." );

	current_level = new Level( "mars" );

	entity_manager = new EntityManager;

	local_player = new Player;
	local_player.name = "Local Player";

	auto ent = new Human();
	entity_manager.register( ent );
	local_player.entity = ent;

	local_player.entity.position = Vector2f( 500, 50 );
}

void update(double delta)
{
	TIME += delta;

	current_level.update( delta );
	entity_manager.update( delta );
}

void draw()
{	
	current_transformation.origin;

	translate( getSize()/2 );
	graphics.setScale( Vector2f( 3, 3 ) );
	translate( -local_player.entity.position );

	current_level.draw();
	entity_manager.draw();
}
