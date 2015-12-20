/+++
	Particle Types and loading from file
+++/
module game.particle_type;

import engine.math;
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
		AddVelocity, ///
		AddAngularVelocity, ///
		Remove, ///
	}
	///Shoot an particle of name obj
	static struct ActionShoot
	{
		string particle_name;
		int count=0;
		float velocity = 0;
		float angle_spread = 0;
		float angle_offset = 0;

		void call( Particle ent )
		{
			import std.math;
			import std.random;
			import std.stdio;

			foreach( i; 0..count )
			{
				auto p = entity_manager.create!Particle( particle_name );
				p.position = ent.position;
				p.angle = (ent.angle+2*PI).fmod(2*PI) + (angle_offset+2*PI).fmod(2*PI);
				p.angle = (p.angle+uniform( 0.00f, angle_spread )+2*PI).fmod(2*PI);
				p.velocity = Vector2f( cos(p.angle), sin(p.angle) )*velocity;
			}
		}

		void parse(R)(R input)
		{
			parseArguments(input,
				particle_name, count,
				velocity,
				angle_spread, angle_offset );
		}
	}
	///Remove itself
	static struct ActionRemove
	{
		void call( Particle ent )
		{
			entity_manager.remove( ent );
		}

		void parse(R)(R input)
		{
			
		}
	}

	union ///Union of all Actions
	{
		ActionShoot shoot;
		ActionRemove remove;
	}

	Type type;	///The type of stored Action
	
	void call( Particle ent )
	{
		switch( type ) with(Type)
		{
			case Shoot:
				shoot.call( ent );
			break;
			case Remove:
				remove.call( ent );
			break;

			default:
				throw new Exception("Undefined action!");
		}
	}
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

		ubyte color_red = 255;
		ubyte color_green = 255;
		ubyte color_blue = 255;
		ubyte color_alpha = 255; // Opacity of the particle to be drawn with
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
		Action[] bounce;
		Action[][int] update;
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
		Action[]* storage_pointer;
	}

	static void load( string path )
	{
		import std.algorithm;
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
				
				if( line.strip == "/+" )
					ignore = true;
				else if( line.strip == "+/" ){
					ignore = false;
					fileline.popFront();
					continue;
				}
				else if( line.strip.startsWith("//") )
				{
					fileline.popFront();
					continue;
				}

				if( ignore ){
					writefln("Ignoring \"%s\"", line );
					fileline.popFront();
					continue;
				}
				
				//Changing of the current category
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
				//Relaying the line to category-specific function
				else if( line.strip().length > 0 )
				{
					final switch( category ) with( Category )
					{
						case General:
							parseStructure( newtype.general, line );
						break;
						case Physics:
							parseStructure( newtype.physics, line );
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
		import std.conv;
		import std.format;
		import std.regex;
		import std.stdio;
		import std.string;

		static event_reg = ctRegex!`on (\w+)\((.*)\)`;
		static action_reg = ctRegex!`(\w+)\((.*)\)`;

		if( auto cap = line.matchFirst( event_reg ) )
		{
			switch( cap[1] )
			{
				case "creation":
					data.storage_pointer = &newtype.events.creation;
				break;
				case "removal":
					data.storage_pointer = &newtype.events.removal;
				break;
				case "update":
					int frequency = to!int( cap[2] );
					if( frequency !in newtype.events.update )
						newtype.events.update[frequency] = [];

					data.storage_pointer = &newtype.events.update[frequency];
				break;
				case "bounce":
					data.storage_pointer = &newtype.events.bounce;
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
			data.storage_pointer = null;
		}
		else if( auto cap = line.matchFirst( action_reg ) )
		{
			Action act;
			switch( cap[1] )
			{
				case "shoot":
					act.type = Action.Type.Shoot;
					act.shoot.parse( cap[2] );
				break;
				case "remove":
					act.type = Action.Type.Remove;
					act.remove.parse( cap[2] );
				break;
				default:
					throw new Exception( format("Unknown action \"%s\"", cap[1]) );
			}
			*data.storage_pointer ~= act;

		}
		else
			throw new Exception( format("Malformed or misplaced input \"%s\"", line ));

	}

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

template parseArgument(R,T)
{
	void parseArgument(ref R input, ref T value )
	{
		import std.conv;
		import std.string;
		import std.stdio;

		if( !input.empty )
		{
			auto str = input.front.strip;
			value = to!T( input.front.strip.idup );
			input.popFront;
		}	
	}
}

template parseArguments(R,Args...)
{
	void parseArgumentsImpl(Y, Args2... )( ref Y input, ref Args2 args )
	{
		parseArgument( input, args[0] );
		static if( args.length > 1 )
			parseArgumentsImpl( input, args[1..$] );
	}
	void parseArguments(R input, ref Args args )
	{
		import std.algorithm;
		import std.string;
		alias stringstrip = std.string.strip;
		import std.stdio;
		auto split = input.splitter(",");
		parseArgumentsImpl( split, args );
	}
}

