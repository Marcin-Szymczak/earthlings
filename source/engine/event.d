module engine.event;

import derelict.sdl2.sdl;

struct Event
{
	SDL_Event _event;
	alias _event this;

	/+++
		Various event types available

		Window* events are only available in event.window.event
	+++/
	enum Type
	{
		Quit = SDL_QUIT,

		Window = SDL_WINDOWEVENT,
		WindowNone = SDL_WINDOWEVENT_NONE,
		WindowShown = SDL_WINDOWEVENT_SHOWN,
		WindowHidden = SDL_WINDOWEVENT_HIDDEN,
		WindowExposed = SDL_WINDOWEVENT_EXPOSED,
		WindowMoved = SDL_WINDOWEVENT_MOVED,
		WindowResized = SDL_WINDOWEVENT_RESIZED,
		WindowSizeChanged = SDL_WINDOWEVENT_SIZE_CHANGED,
		WindowMinimized = SDL_WINDOWEVENT_MINIMIZED,
		WindowMaximized = SDL_WINDOWEVENT_MAXIMIZED,
		WindowRestored = SDL_WINDOWEVENT_RESTORED,
		WindowMouseEntered = SDL_WINDOWEVENT_ENTER,
		WindowMouseLeft = SDL_WINDOWEVENT_LEAVE,
		WindowFocused = SDL_WINDOWEVENT_FOCUS_GAINED,
		WindowUnfocused = SDL_WINDOWEVENT_FOCUS_LOST,
		WindowClosed = SDL_WINDOWEVENT_CLOSE,

		System = SDL_SYSWMEVENT,

		KeyPressed = SDL_KEYDOWN,
		KeyReleased = SDL_KEYUP,
		TextEditing = SDL_TEXTEDITING,
		TextInput = SDL_TEXTINPUT,

		MouseMotion = SDL_MOUSEMOTION,
		MousePressed = SDL_MOUSEBUTTONDOWN,
		MouseReleased = SDL_MOUSEBUTTONUP,
		MouseWheel = SDL_MOUSEWHEEL,

		ClipboardUpdate = SDL_CLIPBOARDUPDATE,
		DropFile = SDL_DROPFILE,

	}
}

int poll( ref Event event )
{
	return SDL_PollEvent( &event._event );
}