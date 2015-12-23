module game.entity.particle;

import engine;
import game;

class Particle : Entity
{
	ParticleType* type;
	bool created = false; ///When the particle is created, on the first update it is going to call its "creation"
	int lifetime;
	int life;
	float anim_frame = 0;
	float anim_dir = 1;
	ubyte alpha;

	this( string typename )
	{
		if( auto ptr = typename in ParticleType.types )
		{
			this.type = ptr;
			this.lifetime = type.general.lifetime;
			this.alpha = type.general.color_alpha;
		}else{
			import std.format;
			throw new Exception( format("No particle type of '%s'", typename) );
		}
	}

	override void creation()
	{
		foreach( action; type.events.creation )
		{
			action.call( this );
		}
	}

	override void removal()
	{
		foreach( action; type.events.removal )
		{
			action.call( this );
		}
	}

	void bounce()
	{
		foreach( action; type.events.bounce )
		{
			action.call( this );
		}
	}

	override void draw() const
	{
		import std.math;
		Vector2f drawposition = position;
		drawposition.x = floor( position.x );
		drawposition.y = floor( position.y );

		graphics.setColor( Color(type.general.color_red, 
								 type.general.color_green,
								 type.general.color_blue,
								 alpha ) );
		if( type.general.image == "" )
		{
			graphics.drawPoint( drawposition );
		}
		else
		{
			graphics.draw( texture_manager[type.general.image], cast(int)anim_frame, drawposition );
		}
		//graphics.drawLine( drawposition, drawposition + Vector2f(sin(angle), cos(angle))*10);
	}

	override void update( double dt )
	{
		import std.math;

		if(!created){
			creation();
			created = true;
		}
		if( type.physics.enable )
		{
			Vector2f nextvel = velocity;
			nextvel+=Gravity_Acceleration*type.physics.gravity*dt;
			nextvel-=velocity*type.physics.air_friction*dt;
			nextvel+=Vector2f( sin(angle)*type.physics.acceleration, cos(angle)*type.physics.acceleration)*dt;
			angle = angle + type.physics.angular_acceleration/180*PI*dt;

			if( isSolid( Vector2f( position.x+nextvel.x*dt, position.y ) ))
			{
				nextvel.x*=-type.physics.bouncyness;
				bounce();
			}

			if( isSolid( Vector2f( position.x, position.y+nextvel.y*dt ) ))
			{
				nextvel.y*=-type.physics.bouncyness;
				bounce();
			}

			velocity=nextvel;
			position+=velocity*dt;
		}
		if(type.general.lifetime)
		{
			lifetime--;
			if(lifetime<=0)
			{
				entity_manager.remove( this );
			}
		}
		if( type.events.update && type.events.update.length > 0 )
		{
			foreach( key, actions; type.events.update )
			{
				if( life%key == 0 )
				{
					foreach( action; actions )
						action.call( this );
				}
			}
		}

		with(ParticleType.Animation.Type)
		{
			if( type.animation.type != None )
			{
				int framecount = texture_manager[type.general.image].atlas.frame_count;
				switch( type.animation.type )
				{
					case Repeat:
						anim_frame = (anim_frame+type.animation.speed*anim_dir*dt+framecount).fmod(framecount);
					break;

					case Once:
						anim_frame = clamp( anim_frame+type.animation.speed*dt, 0, framecount-0.0001f );
					break;

					default:
					break;
				}
			}
		}
		life++;
	}
}