/+++
	Time management

	Authors: Marcin Szymczak
+++/
module engine.time;

import core.thread;
import std.conv;
import std.format;
import std.stdio;

/+++
	Sleep for the time specified in seconds
+++/
void sleep( double time )
{
	time = time < 0 ? 0 : time;
	Thread.sleep( dur!"nsecs"( cast(int)(time*(10^^9)) ));
}

/+++
	A stopwatch-like timer
+++/
struct Timer
{
	///
	alias system_ticks = long;

	system_ticks _start;

	///Start the time measurement
	void start()
	{
		_start = MonoTime.currTime.ticks;
	}

	///Measure the time since start (in system_ticks)
	system_ticks measure()
	{
		return MonoTime.currTime.ticks - _start;
	}

	///Measure the time since start (in seconds)
	real seconds()
	{
		//return cast(double)( measure().total!"nsecs"/(10.0^^9) );
		return measure()/cast(real)(MonoTime.ticksPerSecond);
	}
}

/+++
	Simplest form of benchmarking

	Uses timer to track the time, returns a nicely formatted string of result
+++/
struct Benchmark
{
	Timer timer;
	string name;

	///Start the benchmark and give it a name
	void start( string name )
	{
		this.name = name;
		timer.start();
	}

	///Finish the benchmark, get the results
	string end()
	{
		real time = timer.seconds();
		return format( "%s took %s seconds", name, time );
	}
}