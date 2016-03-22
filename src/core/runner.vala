// This file is part of GNOME Games. License: GPLv3

public interface Games.Runner : Object {
	public signal void stopped ();

	public abstract bool can_resume { get; }

	public abstract void check_is_valid () throws Error;
	public abstract Gtk.Widget get_display ();
	public abstract void start () throws Error;
	public abstract void resume () throws Error;
	public abstract void pause ();
}
