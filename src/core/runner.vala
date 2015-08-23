// This file is part of GNOME Games. License: GPLv3

private interface Games.Runner : Object {
	public abstract Gtk.Widget get_display ();
	public abstract void run () throws RunError;
}

private errordomain Games.RunError {
	EXECUTION_FAILED,
	INVALID_COMMAND,
	INVALID_GAME_FILE,
	ALREADY_RUNNING,
}
