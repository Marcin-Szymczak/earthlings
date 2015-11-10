module game.entity.human;

import std.stdio;

import engine;
import game.controller;
import game.core;
import game.defines;
import game.entity.entity;
import game.level;

class Human : ControllableEntity
{
	enum AIM_HEIGHT = 6f;
	enum WALK_ACCEL = 250f;
	enum GROUND_FRICTION = 6f;
	enum AIR_FRICTION = 1f;
	enum AIR_ACCEL = 15f;
	enum JUMP_FORCE = 40f;
	enum MAX_STEP=3;

	Texture tex;
	int repeat;
	Controller controller;

	bool on_ground = false;

	this()
	{
		tex = texture_manager["human.png"];
	}

	override void setController( Controller controller )
	{
		this.controller = controller;
	}

	override void setAngle( double angle )
	{
		this.angle = angle;
	}
	// Perform an instantenous action
	override void performAction( Action act )
	{
		switch(act) with(Action)
		{
			case Jump:
				if(on_ground)
					velocity.y-=JUMP_FORCE;
			break;
			default: break;
		}

	}
	// Proces continous actions
	void processActions( double delta )
	{
		import std.stdio;

		with(Action)
		{	
			if( controller.getAction( Left ) ){
				if(on_ground)
					velocity.x -= WALK_ACCEL*delta;
				else
					velocity.x -= AIR_ACCEL*delta;
			}
			if( controller.getAction( Right ) ){
				if( on_ground )
					velocity.x += WALK_ACCEL*delta;
				else
					velocity.x += AIR_ACCEL*delta;
			}
		}
	}

	override void update( double delta )
	{
		//pre
		if( controller !is null ){
			import std.stdio;
			processActions( delta );
		}

		Vector2f nextvel = velocity;
		nextvel.y += Gravity_Acceleration*delta;
		if(on_ground)
			nextvel.x -= nextvel.x*delta*GROUND_FRICTION;

		if( isSolid( position + Vector2f(nextvel.x*delta, 0 )) ){
			int can_step_over=0;
			for(int i=MAX_STEP; i>0; i-- )
			{
				if( !isSolid( position + Vector2f(nextvel.x*delta, -i)) ){
					can_step_over=i;
				}else{
					writefln("%s height is solid", i );
				}
			}
			if( can_step_over )
			{
				import std.stdio;
				writefln("Can step over %s", can_step_over );
				position.y-=MAX_STEP;
			}
			else
			{
				nextvel.x *= 0;
			}
		}
		if( isSolid( position + Vector2f(0, nextvel.y)*delta) )
			nextvel.y *= 0;

		velocity = nextvel;
		position += velocity*delta;
		//post
		on_ground = false;
		if( isSolid( position + Vector2f(0,1) ) )
			on_ground = true;

	}

	override void draw() const
	{
		import std.math;
		double angle = TIME/2;
		Frame fr = tex.atlas.getAngleFrame( angle, 4 + cast(int)((TIME*4)%2f) );
		graphics.draw( tex, fr, position, 0, Vector2f(1,1), Vector2f(0,0) );

		Vector2f aimpos = position - Vector2f( 0, AIM_HEIGHT );
		graphics.drawLine( aimpos, aimpos + Vector2f( cos( angle ), sin( angle ) )*20 );
		graphics.drawPoint( position );
	}
}