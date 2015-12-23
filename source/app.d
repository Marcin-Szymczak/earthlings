import core.memory;
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
	Timer timer;
	Timer frametimer;

	timer.start;

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

				case KeyPressed:
				case KeyReleased:
					game.keyEvent( event.key );
				break;


				default: break;
			}
		}
		
		double delta = timer.seconds();
		timer.start;

		frametimer.start;
		game.update( delta );
		game.draw();

		graphics.present();
		graphics.setColor( Color.black );
		graphics.clear();

		core.memory.GC.collect();
		double frametime = frametimer.seconds;
		sleep( 1/60f - frametime );
	}

	engine.cleanUp();
}