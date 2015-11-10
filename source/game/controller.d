module game.controller;

import engine;
import engine.keycode;
import game;

Hook!(KeyboardController, "keyEvent", KeyboardEvent ) Hook_KeyEvent;

enum Action
{
	Up,
	Down,
	Left,
	Right,
	Fire,
	Jump,
	Change
}

/// Interface of a generic Controller
interface Controller
{
	double getAngle();
	bool getAction( Action action );
}

///Interface required for a controllable enttiy
interface Controllable
{
	void setAngle( double angle );
	void performAction( Action action );
	void setController( Controller controller );
}

class KeyboardController : Controller
{

	Player player;

	double ang;
	bool[Action] state;

	this( Player player )
	{
		Hook_KeyEvent.add( this );
		foreach( key; Action.min .. Action.max )
		{
			state[key] = false;
		}
		this.player = player;
	}

	~this()
	{
		Hook_KeyEvent.remove( this );
	}

	void keyEvent( KeyboardEvent ev )
	{
		import std.stdio;
		if( ev.repeat )
			return;
		auto sym = ev.keysym.sym;
		bool value = ev.state == SDL_Pressed;
		Action key;
		switch( sym ) with(Action)
		{
			case SDLK_a:
				key = Left;
			break;
			case SDLK_d:
				key = Right;
			break;
			case SDLK_w:
				key = Up;
			break;
			case SDLK_s:
				key = Down;
			break;
			case SDLK_g:
				key = Jump;
			break;
			default:
			return;
		}
		state[key] = value;
		if( value )
			player.performAction( key );
	}

	double getAngle()
	{
		return ang;
	}

	bool getAction( Action action )
	{
		return state[action];
	}
}