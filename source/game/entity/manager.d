module game.entity.manager;

import std.container.slist;
import game.entity.entity;

class EntityManager
{
	//SList!Entity list;
	Entity[] list;
	Entity[] cleanup_list;
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
		cleanup_list ~= ent;
	}

	void update( double delta )
	{
		foreach( ent; list )
		{
			ent.update( delta );
		}
	
		foreach( ent; cleanup_list )
		{
			import std.algorithm;
			ent.removal();
			auto index = list.countUntil( ent );
			
			//It can happen that the same entity is requested to be removed multiple times in a frame
			if( index != -1 )
				list = list.remove(index);
		}
		cleanup_list.length = 0;
	}

	void draw()
	{
		foreach( ent; list )
		{
			ent.draw();
		}
	}
}