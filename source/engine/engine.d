/+++
	Engine core module
+++/
module engine.core;

import std.exception;
import std.format;
import std.stdio;
import std.string;

import derelict.sdl2.image;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

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

enum SDL_Released = 0; /// Useful SDL constant when dealing with input
enum SDL_Pressed = 1; /// ditto

/+++
	Initialize the engine.

	You can provide which subsystems should be enabled using Init enum.
+++/
void initialize( Init[] args ... )
{
	DerelictSDL2.load();
	DerelictSDL2ttf.load();
	DerelictSDL2Image.load();

	int sum;
	foreach( arg; args )
	{
		sum = sum | arg;
	}
	enforce( SDL_Init( sum ) == 0, format( "Couldn't initialize SDL, '%s'", SDL_GetError().fromStringz ) );
	enforce( TTF_Init() != -1, format( "Couldn't initialize SDL2_TTF, '%s'", TTF_GetError().fromStringz ));

	writeln( "Engine initialized..." );
}

/+++
	Shutdown the engine
+++/
void cleanUp()
{
	SDL_Quit();
}