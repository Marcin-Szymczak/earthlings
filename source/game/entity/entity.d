module game.entity.entity;

import engine;

class Entity
{
public:
	Vector2f position = Vector2f(0,0);
	Vector2f velocity = Vector2f(0,0);

	abstract void draw() const;
	abstract void update( double delta );
}