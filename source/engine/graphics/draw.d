module engine.graphics.draw;

import std.range;

import derelict.sdl2.sdl;

import engine.graphics.core;
import engine.graphics.image;
import engine.math;



/+++
	Clear the screen
+++/
void clear()
{
	SDL_RenderClear( current_renderer );
}
/+++
	Internal: swap the frame buffers to present the drawings
+++/
void present()
{
	SDL_RenderPresent( current_renderer );
}
/+++
	draw a point
+++/
void drawPoint( float x, float y )
{
	SDL_RenderDrawPoint( current_renderer, cast(int)x, cast(int)y );
}
///
void drawPoint( Vector2f pos )
{
	pos = current_transformation.get( pos );
	SDL_RenderDrawPoint( current_renderer, cast(int)pos.x, cast(int)pos.y );
}

void drawPoints( float[] coords ... )
{
	if( coords.length%2 != 0){
		throw new Exception( "graphics.drawPoints invalid number of arguments (uneven)" );
	}

	auto chunk = chunks( coords, 2 );
	while( !chunk.empty )
	{
		drawPoint( chunk.front[0], chunk.front[1] );
		chunk.popFront;
	}

}

void drawPoints( Vector2f[] positions ... )
{
	foreach( position; positions )
	{
		//drawPoint( position.x, position.y );
		SDL_RenderDrawPoint( current_renderer, cast(int)position.x, cast(int)position.y );
	}
}
/+++
	Draw a line
+++/
void drawLine( float x, float y, float x2, float y2 )
{
	SDL_RenderDrawLine( current_renderer, cast(int)x, cast(int)y, cast(int)x2, cast(int)y2 );
}
///
void drawLine( Vector2f start, Vector2f end )
{
	start = current_transformation.get( start );
	end = current_transformation.get( end );

	SDL_RenderDrawLine( current_renderer, cast(int)start.x, cast(int)start.y, cast(int)end.x, cast(int)end.y );
}

void drawRectangle( float x, float y, float w, float h )
{
	SDL_Rect dest;

	dest.x = cast(int)x;
	dest.y = cast(int)y;
	dest.w = cast(int)w;
	dest.h = cast(int)h;

	SDL_RenderFillRect( current_renderer, &dest );
}