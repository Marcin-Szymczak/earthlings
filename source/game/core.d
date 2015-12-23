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
Player local_player;
Texture simple_text;

double TIME=0;

void initialize()
{
	texture_manager = new TextureManager;
	texture_manager.setBasePath( path_graphics );
	texture_manager.loadFromFile( "human.png" );
	ParticleType.base_path = path_objects;
	ParticleType.loadAll();
	ParticleType.loadAllResources();

	graphics.setBlendMode( BlendMode.Blend );

	entity_manager = new EntityManager;
	current_level = new Level( "mars" );

	local_player = new Player;
	local_player.name = "Local Player";

	auto ent = entity_manager.create!Human();

	local_player.controller = new KeyboardController( local_player );
	local_player.takeControl( ent );
	local_player.entity.position = Vector2f( 150, 150 ).dropDown;

	auto pt = entity_manager.create!Particle("grenade");
	pt.position.x = 100;
	pt.position.y = 500;
	pt.velocity.x = 10;
	pt.velocity.y = -50;

	auto banana = entity_manager.create!Particle("banana");
	banana.position.x = 200;
	banana.position.y = 500;
	
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

	//translate( Vector2f( -0.49, -0.49 ) );
	translate( getSize()/2 );
	graphics.setScale( Vector2f( 4, 4 ) );
	auto translation = -local_player.entity.position.floor;

	translate( translation );
	
	current_level.draw();
	entity_manager.draw();
}
