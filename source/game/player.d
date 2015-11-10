module game.player;

import game.controller;
import game.entity.entity;

class Player
{	
public:
	ControllableEntity entity; /// The entity that player is controlling
	Controller controller; /// Player's controller
	string name; /// The name of the player

	void takeControl( ControllableEntity entity )
	{
		this.entity = entity;
		entity.setController( controller );
	}

	void loseControl()
	{
		entity.setController( null );
		this.entity = null; 
	}

	void performAction( Action act )
	in
	{
		assert( entity !is null );	
	}
	body
	{
		import std.exception;
		
		if( entity )
			(cast(Controllable)(entity)).performAction( act );
	}
}