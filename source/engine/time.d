/+++
	Time management

	Authors: Marcin Szymczak
+++/
module engine.time;

import core.thread;

void sleep( double time )
{
	time = time < 0 ? 0 : time;
	Thread.sleep( dur!"nsecs"( cast(int)(time*10^^9) ) );
}

struct Timer
{
	MonoTime measurement;

	void start()
	{
		measurement = MonoTime.currTime;
	}

	Duration measure()
	{
		return MonoTime.currTime - measurement;
	}
}