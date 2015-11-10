module game.entity.particle;

import engine;
import game;

class Particle : Entity
{
	ParticleType* type;

	int lifetime;

	this( string typename )
	{
		if( auto ptr = typename in ParticleType.types )
		{
			this.type = ptr;
			this.lifetime = type.general.lifetime;
		}else{
			import std.format;
			throw new Exception( format("No particle type of '%s'", typename) );
		}
	}

	override void draw() const
	{
		import std.math;
		Vector2f drawposition = position;
		drawposition.x = floor( position.x );
		drawposition.y = floor( position.y );

		graphics.draw( texture_manager[type.general.image], 0, drawposition );
	}

	override void update( double dt )
	{
		if( type.physics.enable )
		{
			Vector2f nextvel = velocity;
			nextvel+=Gravity_Acceleration*type.physics.gravity*dt;
			
			if( isSolid( Vector2f( position.x+nextvel.x*dt, position.y ) ))
			{
				nextvel.x*=-type.physics.bouncyness;
			}

			if( isSolid( Vector2f( position.x, position.y+nextvel.y*dt ) ))
			{
				nextvel.y*=-type.physics.bouncyness;
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
	}
}