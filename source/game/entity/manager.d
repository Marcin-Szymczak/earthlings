module game.entity.manager;

import std.container.slist;
import game.entity.entity;

class EntityManager
{
	//SList!Entity list;
	Entity[] list;
	int count;

	T create(T, Args...)( Args args )
		
		if( is( T : Entity ) )
	{
		T ent = new T( args );
		register( ent );
		return ent;
	}

	void register( Entity ent )
	{
		list ~= ent ;
		count++;
	}

	void remove( Entity ent )
	{
		import std.algorithm;
		auto index = list.countUntil( ent );
		list = list.remove(index);
	}

	void update( double delta )
	{
		foreach( ent; list )
		{
			ent.update( delta );
		}
	}

	void draw()
	{
		foreach( ent; list )
		{
			ent.draw();
		}
	}
}