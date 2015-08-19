/+++
	Engine core module
+++/
module engine.core;

import std.format;
import std.stdio;

import derelict.sdl2.image;
import derelict.sdl2.sdl;

/+++
	Modules which can be initialized on startup
+++/
enum Init : int
{
	Timer = SDL_INIT_TIMER, ///
	Audio = SDL_INIT_AUDIO, ///
	Video = SDL_INIT_VIDEO, ///
	Joystick = SDL_INIT_JOYSTICK, ///
	Haptic = SDL_INIT_HAPTIC, ///
	GameController = SDL_INIT_GAMECONTROLLER, ///
	Events = SDL_INIT_EVENTS, ///
	Everything = SDL_INIT_EVERYTHING ///
}

/+++
	Initialize the engine.

	You can provide which subsystems should be enabled using Init enum.
+++/
void initialize( Init[] args ... )
{
	DerelictSDL2.load();
	//DerelictSDL2ttf.load();
	DerelictSDL2Image.load();

	int sum;
	foreach( arg; args )
	{
		sum = sum | arg;
	}
	if(SDL_Init(sum))
		throw new Exception( format( "Couldn't initialize SDL, '%s'", SDL_GetError() ) );
}

/+++
	Shutdown the engine
+++/
void cleanUp()
{
	SDL_Quit();
}