module game.entity.entity;

import engine;
import game.controller;

abstract class Entity
{
public:
	Vector2f position = Vector2f(0,0);
	Vector2f velocity = Vector2f(0,0);
	double angle = 0;
	

	abstract void draw() const;
	abstract void update( double delta );
}

abstract class ControllableEntity : Entity, Controllable
{
	override void draw() const;
	override void update( double delta );

	abstract void setAngle( double angle );
	abstract void performAction( Action action );
	abstract void setController( Controller controller );
}