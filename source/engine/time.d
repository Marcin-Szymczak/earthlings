/+++
	Time management

	Authors: Marcin Szymczak
+++/
module engine.time;

import core.thread;
import std.conv;
import std.format;
import std.stdio;

void sleep( double time )
{
	time = time < 0 ? 0 : time;
	Thread.sleep( dur!"nsecs"( cast(int)(time*(10^^9)) ));
}

struct Timer
{
	alias system_ticks = long;

	system_ticks _start;

	void start()
	{
		_start = MonoTime.currTime.ticks;
	}

	system_ticks measure()
	{
		return MonoTime.currTime.ticks - _start;
	}

	real seconds()
	{
		//return cast(double)( measure().total!"nsecs"/(10.0^^9) );
		return measure()/cast(real)(MonoTime.ticksPerSecond);
	}
}

struct Benchmark
{
	Timer timer;
	string name;

	void start( string name )
	{
		this.name = name;
		timer.start();
	}

	string end()
	{
		real time = timer.seconds();
		return format( "%s took %s seconds", name, time );
	}
}