module game.console;

import std.stdio;

struct ConsoleCommand
{
	void function( string command ) ptr;
	string name;
	string description;
}

ConsoleCommand[] commands;

static this()
{
	commands ~= ConsoleCommand(&hello,"hello","First ever concommand!");
}

void hello( string command )
{
	writefln("Hello command system! %s", command );
}

void run( string command )
{
	
}