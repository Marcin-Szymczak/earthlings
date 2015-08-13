import std.stdio;

import engine;
import game;

void main()
{
	with(Init)
	engine.initialize( Video, Timer );
	auto window = new Window( "Earthlings", Window.Position.Undefined, Window.Position.Undefined, 1024, 768, 0 );
	auto renderer = new Renderer( window );

	graphics.setRenderer( renderer );

	game.initialize();

	Event event;

	MainLoop:
	while( true )
	{
		while( event.poll )
		{
			switch( event.type ) with( Event.Type )
			{
				case Window:
					switch( event.window.event ) with( Event.Type )
					{
						case WindowClosed:
						break MainLoop;

						default: break;
					}
				break;
				default: break;
			}
		}
		game.update( 1/60f );
		game.draw();

		graphics.present();
		graphics.setColor( Color.black );
		graphics.clear();

		sleep( 1/60f );
	}

	engine.cleanUp();
}