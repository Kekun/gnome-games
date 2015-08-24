// This file is part of GNOME Games. License: GPLv3

private interface Games.Runner : Object {
	public signal void stopped ();

	public abstract Gtk.Widget get_display ();
	public abstract void start () throws RunError;
	public abstract void pause ();
}

private errordomain Games.RunError {
	EXECUTION_FAILED,
	INVALID_COMMAND,
	INVALID_GAME_FILE,
	MODULE_NOT_FOUND,
}
