module game.entity.entity;

import engine;
import game.controller;

abstract class Entity
{
public:
	Vector2f position = Vector2f(0,0);
	Vector2f velocity = Vector2f(0,0);
	double _angle = 0;

	@property
	inout(double) angle() inout
	{
		return _angle;
	}
	 
	@property
	void angle( double ang )
	{
		import std.math;

		_angle = (ang.fmod(2*PI) + 2*PI).fmod( 2*PI );
	}
	abstract void draw() const;
	abstract void update( double delta );
	void creation(){}
	void removal(){}
}

abstract class ControllableEntity : Entity, Controllable
{
	override void draw() const;
	override void update( double delta );

	abstract void setAngle( double angle );
	abstract void performAction( Action action );
	abstract void setController( Controller controller );
}