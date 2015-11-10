module engine.parser;

/+++
	Parse strings into structs
	
	Parser tries to math key=value pairs given to it as InputRanges into
	struct's fields. If throws when it couldn't find a match.
+++/
template parse(T, R)
{

	string parserImpl(args...)()
	{
		import std.traits;

		string str;
		auto arg = args[0];
		static if( !hasUDA!(__traits( getMember, T, args[0] ), "noparse") ){
			str ~= `case "`~arg~`":`;
			str ~= `obj.`~arg~` = to!(typeof( obj.`~arg~` ))( cap[2] );`;
			str ~= `break;`;
		}
		static if( args.length > 1 ){
			str ~= parserImpl!( args[1..$] )();
		}

		return str;
	}

	void parse(ref T obj, R input)
	{
		import std.conv;
		import std.format;
		import std.regex;
		import std.stdio;

		auto reg = ctRegex!(`(\w+)\s*?=\s*(.+)`);
		auto cap = input.matchFirst( reg );
		writeln( cap );
		if( cap.empty )
			throw new Exception( "Invalid input");

		switch(cap[1])
		{

			mixin( parserImpl!(__traits(allMembers, T ))() );

			default:
			throw new Exception( format( "unknown property %s", cap[1] ));
		}
	}
}

void parseFile(T)(ref T obj, string filename )
{
	import std.format;
	import std.stdio;

	auto file = File( filename, "r" );

	int c;

	foreach( line; file.byLine )
	{
		c++;

		try
			parse( obj, line );
		catch( Exception e )
			throw new Exception( format( "%s:%s - %s", filename, c, e.msg ) );
			//writefln( "%s:%s - %s", filename, c, e.msg );
			
	}
}