/+++
	Particle Types and loading from file
+++/
module game.particle_type;

import engine.parser;
import game;

/+++
	An action of a particle
+++/
struct Action
{
	///Action Type
	enum Type
	{
		Shoot, ///
		Remove, ///
	}
	///Shoot an particle of name obj
	static struct ActionShoot
	{
		string obj;

		static void call( Entity ent );
	}
	///Remove itself
	static struct ActionRemove
	{
		static void call( Entity ent );
	}

	union Contents
	{
		ActionShoot shoot;
		ActionRemove remove;
	}

	Type type;	///The type of stored Action
	Contents contents;	///Union of all Actions
}

struct Animation
{
	string type;
	int duration;
}

/+++
	A Particle's Type

	Holds all properties and actions that should be performed on specific events
+++/
struct ParticleType
{
	///General Properties
	static struct General
	{
		string name; ///
		string image; ///Path to the image
		int lifetime=0; ///Lifetime of 0 means that the particle doesn't decay over time
		/+++
			Can be a binary sum of all layers that this particle should collide with
		+++/
		int collision_layer=0; 
		/+++
			The draw layer of the particle specifies when is it drawn

			0-2 background
			3 players
			4-7 objects occluding players, all big occluders should occupy draw layer 7
		+++/
		int draw_layer=0;
	}
	///Physical properties
	static struct Physics
	{
		bool enable=true; ///Enable motion?
		float gravity=0; ///Gravity multiplier
		float bouncyness=0; ///How much of velocity is retained after each bounce (0..1)
		float air_friction=0; ///The strength of air friction
		float friction=0; ///The strength of ground friction
	}
	static struct Events
	{
		enum Type
		{
			None,
			Creation,
			Removal,
			Update,
		}

		Action[] update;
		Action[] creation;
		Action[] removal;
	}
	@DontParse 
	{
		General general;
		Physics physics;

		Events events;

		static string base_path;
		static ParticleType[string] types;
	}

	static void register( ParticleType pt )
	{
		import std.stdio;

		types[pt.general.name] = pt;
		"Particle '%s' registered!".writefln( pt.general.name );
	}

	static void loadAll()
	{
		import std.file;
		import std.range;
		import std.stdio;

		string path = base_path;
		
		"Loading all particles from '%s'".writefln( path );
		
		foreach( entry; dirEntries( path, SpanMode.breadth ) )
		{
			if( !entry.isDir() )
			{
				entry.name.writeln;
				load( entry.name );
			}
		}
	}

	static struct LoaderData
	{
		Events.Type event_type = Events.Type.None;
	}

	static void load( string path )
	{
		import std.format;
		import std.regex;
		import std.stdio;
		import std.string;

		enum Category
		{
			None,
			General,
			Physics,
			Behaviour,
		}

		auto file = File( path, "r" );
		static reg_category = ctRegex!("^#(.+)");

		ParticleType newtype;
		LoaderData data;

		bool ignore = false;
		auto fileline = file.byLine;
		int linec;
		Category category;

		try
		{

			while(!fileline.empty)
			{
				string line = cast(string)fileline.front();
				linec++;
				if( auto cap = line.matchFirst( reg_category ) )
				{
					switch( cap[1] )
					{
						case "General":
							category = Category.General;
						break;
						case "Physics":
							category = Category.Physics;
						break;
						case "Behaviour":
							category = Category.Behaviour;
						break;
						default:
							throw new Exception( format("Unknown category \"%s\"", cap[1] ) );
					}
				}
				else if( line.strip().length > 0 )
				{
					final switch( category ) with( Category )
					{
						case General:
							parse( newtype.general, line );
						break;
						case Physics:
							parse( newtype.physics, line );
						break;
						case Behaviour:
							parseBehaviour( newtype, line, data );
						break;
						case None:
							throw new Exception("Error! No category set");
					}
				}

				fileline.popFront();
			}
		}
		catch( Exception e )
		{
			e.msg = format( "Object definition error in file '%s'(l:%s): '%s'", path, linec, e.msg );
			throw e;
		}

		ParticleType.register( newtype );
	}

	static void parseBehaviour( ref ParticleType newtype, string line, ref LoaderData data )
	{
		import std.format;
		import std.regex;
		import std.stdio;
		import std.string;

		static event_reg = ctRegex!`on (\w+)\((.*)\)`;
		static action_reg = ctRegex!`(\w+)\((.+)\)`;

		if( auto cap = line.matchFirst( event_reg ) )
		{
			switch( cap[1] ) with(Events.Type)
			{
				case "creation":
					data.event_type = Creation;
				break;
				case "removal":
					data.event_type = Removal;
				break;
				case "update":
					data.event_type = Update;
				break;

				default:
					throw new Exception( format( "Unknown event \"%s\"!", cap[1] ) );
			}
		}
		else if( line.strip() == "{" )
		{

		}
		else if( line.strip() == "}" )
		{
			data.event_type = Events.Type.None;
		}
		else if( auto cap = line.matchFirst( action_reg ) )
		{
			switch( cap[1] )
			{
				case "shoot":

				break;
				
				default:
					throw new Exception( format("Unknown action \"%s\"", cap[1]) );
			}
		}
		else
			throw new Exception( format("Unknown input \"%s\"", line ));

	}
	/+
	static void loadOld( string path )
	{
		import std.algorithm;
		import std.format;
		import std.range;
		import std.regex;
		import std.stdio;
		import std.string;

		auto file = File( path, "r" );

		static categoryreg = ctRegex!("^#(.+)");
		string category;

		ParticleType newtype;

		bool ignore=false;
		
		auto fileline = file.byLine;
		int linec;

		foreach( line; fileline )
		{
			linec++;

			if( line.length == 0 ){
				continue;
			}
			if( line.startsWith( `/+` ) ){
				ignore=true;
				continue;
			}
			if( line.startsWith( `+/` ) ){
				ignore=false;
				continue;
			}
			if(ignore)
				continue;
			
			auto cap = line.matchFirst( categoryreg );	
			if( cap ){
				category = cap[1].idup;
				continue;
			}

			try
			{
				switch( category )
				{
					case "General":
						parse(newtype.general,line);
					break;

					case "Physics":
						parse(newtype.physics,line);
					break;
					case "Behaviour":
						parseBehaviour( newtype, fileline );
					break;

					default:
						throw new Exception(format( "Unknown category %s", category ) );
				}
			}
			catch( Exception e )
			{
				e.msg = format( "Object definition error in file '%s'(l:%s): '%s'", path, linec, e.msg );
				throw e;
			}
			if( fileline.empty() )
				break;
		}

		ParticleType.register( newtype );
	}
	+/

	static void loadAllResources()
	{
		foreach( k, pt; types )
		{
			if( pt.general.image.length > 0 ){
				texture_manager.loadFromFile( pt.general.image );
			}
		}
	}

	static void freeAllResources()
	{

	} 
}

