module engine.resource;

import std.exception;
import std.file;
import std.format;
import std.stdio;

abstract class ResourceManager(T)
{
	T[string] resource;
	string base_path;
	T unavailable;
	string pattern;

	abstract void loadFromFile( string, bool = true );
	abstract void free( string );

	void setBasePath( string path )
	{
		base_path = path;
	}

	void loadDirectory( string path )
	{
		string cwd = getcwd();
		chdir( base_path );

		foreach( string name; dirEntries( path, pattern, SpanMode.breadth ) )
		{
			try
			{
			loadFromFile( name[2..$] );
			}
			catch( Exception exc )
			{
				writefln( "%s", exc.msg );
			}

		}
		chdir( cwd );
	}

	T opIndex( string index )
	{
		auto p = index in resource;
		if( !p )
			//return unavailable;
			throw new Exception( format( "Resource %s is not loaded!", index ) );
		return *p;
	}

	alias resource this;
}