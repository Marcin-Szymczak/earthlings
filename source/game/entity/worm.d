module game.entity.worm;

import std.stdio;

import engine;
import game.core;
import game.defines;
import game.entity.entity;
import game.level;

class Worm : Entity
{
	Texture tex;
	int repeat;

	this()
	{
		tex = texture_manager["worm.png"];
	}

	override void update( double delta )
	{
		Vector2f nextvel = velocity;

		nextvel.y += Gravity_Acceleration*delta;

		if( isSolid( position + nextvel ) )
			nextvel *= 0;

		velocity = nextvel;
		position += velocity;
	}

	override void draw() const
	{
		graphics.draw( tex, 0, position );
	}
}