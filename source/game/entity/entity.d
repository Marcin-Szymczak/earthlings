module game.entity.entity;

import engine;

class Entity
{
public:
	Vector2f position;
	Vector2f velocity;

	abstract void draw() const;
	abstract void update( double delta );
}