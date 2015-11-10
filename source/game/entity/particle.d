module game.entity.particle;

import engine;
import game.entity.entity;

struct Animation
{
	string type;
	int duration;
}

struct ParticleType
{
	string name;
	string image;
	int lifetime;
	float bouncyness;
	int collision_layer;
	int draw_layer;

	@("noparse") Animation* animation;
}

class Particle : Entity
{
	ParticleType* type;

	override void draw() const
	{

	}
	override void update( double delta )
	{

	}
}