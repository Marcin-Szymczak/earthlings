module game.entity.manager;

import std.container.slist;
import game.entity.entity;

class EntityManager
{
	SList!Entity list;
	int count;

	void register( Entity ent )
	{
		list.insert( ent );
		count++;
	}

	void remove( Entity ent )
	{
		foreach( el; list )
		{
			if( el is ent )
			{
				
			}
		}
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