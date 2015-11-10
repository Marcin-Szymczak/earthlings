module game.core;

import core.memory;
import std.format;
import std.math;
import std.range;
import std.stdio;

import engine;
import game;
import game.entity.particle;


TextureManager texture_manager;
EntityManager entity_manager;
Player local_player;
Texture simple_text;

double TIME=0;

void initialize()
{
	texture_manager = new TextureManager;
	texture_manager.setBasePath( path_graphics );
	texture_manager.loadDirectory( "." );

	current_level = new Level( "movementtest1" );

	entity_manager = new EntityManager;

	local_player = new Player;
	local_player.name = "Local Player";

	auto ent = new Human();
	entity_manager.register( ent );

	local_player.controller = new KeyboardController( local_player );
	local_player.takeControl( ent );
	local_player.entity.position = Vector2f( 150, 150 );
}

void keyEvent( KeyboardEvent ev )
{
	Hook_KeyEvent.call( ev );
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
