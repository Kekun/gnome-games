// This file is part of GNOME Games. License: GPL-3.0+.

public interface Games.Runner : Object {
	public signal void stopped ();

	public abstract bool can_fullscreen { get; }
	public abstract bool can_quit_safely { get; }
	public abstract bool can_resume { get; }
	public abstract MediaSet? media_set { get; }

	public abstract bool check_is_valid (out string error_message) throws Error;
	public abstract Gtk.Widget get_display ();
	public abstract void start () throws Error;
	public abstract void resume () throws Error;
	public abstract void pause ();
	public abstract void stop ();
}
