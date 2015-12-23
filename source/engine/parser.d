module engine.parser;

/+++
	Struct members having this UDA won't be considered in parsing

	Allows to restrict the access for the parser
+++/
struct DontParse
{

}

/+++
	
+++/
struct ParseHandler(T)
{
	T function(string input) handler;
}

/+++
	Parse strings into structs


	Parser tries to math key=value pairs given to it as InputRanges into
	struct's fields. It throws when it couldn't find a match.
+++/
template parseStructure(T, R)
{

	string parserImpl(args...)()
	{
		import std.traits;

		string str;
		auto arg = args[0];
		static if( !hasUDA!(__traits( getMember, T, args[0] ), DontParse) ){
			str ~= `case "`~arg~`":`;
			//static if( hasUDA!(__traits( getMember, T, args[0] ), ParseHandler ) )
			str ~= `obj.`~arg~` = to!(typeof( obj.`~arg~` ))( cap[2].idup );`;
			str ~= `break;`;
		}
		static if( args.length > 1 ){
			str ~= parserImpl!( args[1..$] )();
		}

		return str;
	}
	/+++
		Parse an InputRange to fill the obj's member
	+++/
	void parseStructure(ref T obj, R input)
	{
		import std.conv;
		import std.format;
		import std.regex;
		import std.stdio;

		auto reg = ctRegex!(`(\w+)\s*?=\s*(.+)`);
		auto cap = input.matchFirst( reg );

		if( cap.empty )
			throw new Exception( format("'%s' does not match the scheme \"key=value\" to be parsed", input) );

		switch(cap[1])
		{
			mixin( parserImpl!(__traits(allMembers, T ))() );

			default:
			throw new Exception( format( "Unknown property %s", cap[1] ));
		}
	}
}

/+++
	Parse a file using parser and byLine
+++/
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
			parseStructure( obj, line );
		catch( Exception e )
			throw new Exception( format( "%s:%s - %s", filename, c, e.msg ) );
			//writefln( "%s:%s - %s", filename, c, e.msg );
			
	}
}