/+++
	Window's core functions
+++/
module engine.window.core;

import std.string;

import derelict.sdl2.sdl;

import engine.graphics.image;

/+++
	A window
+++/
class Window
{
	SDL_Window* _window;

	/+++
		Where should the window be created
	+++/
	enum Position : int
	{
		Undefined = SDL_WINDOWPOS_UNDEFINED, ///
		Centered = SDL_WINDOWPOS_CENTERED, ///
	};
	/+++
		Create a window.

		title is the window's title
		x,y are top-left coordinates of the window. You can also use Position enum
		w,h are the dimensions of the window
	+++/
	this( string title, int x, int y, int w, int h, uint flags=0 )
	{
		_window = SDL_CreateWindow( title.toStringz, x, y, w, h, flags );
		if( !_window )
			throw new Exception( "Couldn't create a renderer" );
	}
	///Window's destructor
	~this()
	{
		SDL_DestroyWindow( _window );
	}
	/+++
		Set the window's icon from a SDL_Surface
	+++/
	void setIcon( SDL_Surface* icon )
	{
		SDL_SetWindowIcon( _window, icon );
	}
	/// Set the window's icon from an Image
	void setIcon( Image img )
	{
		SDL_SetWindowIcon( _window, img );
	}
	/+++
		Set the window's icon from a file name
	+++/
	void setIcon( string path )
	{
		auto img = new Image;
		img.loadFromFile( path );
		setIcon( img );
	}

	alias _window this;
}