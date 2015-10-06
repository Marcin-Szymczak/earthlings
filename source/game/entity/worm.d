module game.entity.worm;

import std.stdio;

import engine;
import game.core;
import game.defines;
import game.entity.entity;
import game.level;

enum Action
{
	Left,
	Right,
	Up,
	Down,
	Jump,
	Change,
}

class Worm : Entity
{
	Texture tex;
	int repeat;
	
	bool[] actions;

	static float aim_height = 6;

	this()
	{
		tex = texture_manager["human.png"];
		actions.length = Action.max +1;
		actions[] = false;
	}

	void action( Action act )
	{
		with(Action) switch(act)
		{
			default: break;
		}
	}

	override void update( double delta )
	{
		Vector2f nextvel = velocity;
		nextvel.y += Gravity_Acceleration*delta;


		if( isSolid( position + Vector2f(nextvel.x, 0 )) )
			nextvel.x *= 0;
		if( isSolid( position + Vector2f(0, nextvel.y)) )
			nextvel.y *= 0;

		velocity = nextvel;
		position += velocity;
	}

	override void draw() const
	{
		import std.math;
		double angle = TIME/2;
		graphics.draw( tex, tex.atlas.getAngleFrame( angle, 4 + cast(int)((TIME*4)%2f) ), position );

		Vector2f aimpos = position - Vector2f( 0, aim_height );
		graphics.drawLine( aimpos, aimpos + Vector2f( cos( angle ), sin( angle ) )*100 );
	}
}