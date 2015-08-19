module game.entity.worm;

import engine;
import game.core;
import game.entity.entity;

class Worm : Entity
{
	Texture tex;

	this()
	{
		tex = texture_manager["worm.png"];
	}

	override void update( double delta )
	{

	}

	override void draw() const
	{
		graphics.draw( tex, 0, position );
	}
}