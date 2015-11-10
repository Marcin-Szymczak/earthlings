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
	enum AIM_HEIGHT = 7f;
	enum WALK_ACCEL = 500f;
	enum WALK_SPEED = 100f;
	enum GROUND_FRICTION = 12f;
	enum AIR_FRICTION = 1.5f;
	enum AIR_ACCEL = 300f;
	enum AIR_SPEED = 20f;
	enum JUMP_FORCE = 40f;
	enum MAX_STEP = 2;
	enum AIM_ACCEL = 30f;
	enum AIM_SPEED = 50f;
	enum WALK_FRAMES = 2;

	enum Stance
	{
		None = 0,
		OneHanded = 4,
		DoubleHanded = 6,
	}

	Texture tex;
	int repeat;
	Controller controller;

	bool on_ground = false;
	int direction = 1;
	float walkframe = 0;
	float aimspeed = 0;
	float aimangle = 0;

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
	void processActions( double dt )
	{
		import std.math;
		import std.stdio;

		with(Action)
		{	
			if( controller.getAction( Left ) ){
				if(on_ground)
					velocity.x -= WALK_ACCEL*dt;
				else
					if( velocity.x > -AIR_SPEED )
						velocity.x -= AIR_ACCEL*dt;
				direction = -1;
			}
			if( controller.getAction( Right ) ){
				if( on_ground )
					velocity.x += WALK_ACCEL*dt;
				else
					if( velocity.x < AIR_SPEED )
						velocity.x += AIR_ACCEL*dt;
				direction = 1;
			}
			if( controller.getAction( Up ) && aimspeed > -AIM_SPEED )
				aimspeed-= AIM_ACCEL*dt;
			else if( controller.getAction( Down ) && aimspeed < AIM_SPEED )
				aimspeed += AIM_ACCEL*dt;
			else
				aimspeed=0;
			aimangle+=aimspeed*dt;

			enum epsilon = 1/100f;
			aimangle= aimangle.clamp( -PI_2+epsilon, PI_2-epsilon );

			import std.math;

			if( direction == 1 )
			{
				angle = (PI*2 + aimangle).fmod(PI*2);
			}else if( direction == -1 )
			{
				angle = (PI - aimangle).fmod(PI*2);
			}
		}
	}

	override void update( double dt )
	{
		import std.math;

		//pre
		if( controller !is null ){
			import std.stdio;
			processActions( dt );
		}

		Vector2f nextvel = velocity;
		nextvel += Gravity_Acceleration*dt;
		if(on_ground)
			nextvel.x -= nextvel.x*dt*GROUND_FRICTION;

		if( isSolid( position + Vector2f(nextvel.x*dt, 0 )) ){
			int can_step_over=0;
			for(int i=MAX_STEP; i>0; i-- )
			{
				if( !isSolid( position + Vector2f(nextvel.x*dt, -i)) )
					can_step_over=i;
			}
			if( can_step_over )
			{
				import std.stdio;
				//writefln("Can step over %s", can_step_over );
				position.y-=can_step_over;
			}
			else
				nextvel.x *= 0;
		}
		if( isSolid( position + Vector2f(0, nextvel.y)*dt) )
			nextvel.y *= 0;

		velocity = nextvel;
		position += velocity*dt;
		//post
		bool last_on_ground = on_ground;
		on_ground = false;
		if( isSolid( position + Vector2f(0,1) ) )
			on_ground = true;

		if(on_ground)
			if( last_on_ground == true )
				walkframe = (walkframe+dt*abs(velocity.x)/5f)%WALK_FRAMES;
			else
				walkframe = 0;
		else
			walkframe = 1;

	}

	override void draw() const
	{
		import std.math;

		Frame fr = tex.atlas.getAngleFrame( angle, Stance.DoubleHanded + cast(int)walkframe );
		Vector2f drawpos = position.floor;
		graphics.setColor( Color.white );
		graphics.draw( tex, fr, drawpos, 0, Vector2f(direction,1), Vector2f(0,0) );

		Vector2f aimpos = drawpos - Vector2f( 0, AIM_HEIGHT );
		
		graphics.setColor( Color.red );
		graphics.drawPoint( drawpos );
		graphics.drawPoint( aimpos + Vector2f(cos(angle),sin(angle))*25 );
	}
}