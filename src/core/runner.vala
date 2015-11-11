// This file is part of GNOME Games. License: GPLv3

public interface Games.Runner : Object {
	public signal void stopped ();

	public abstract bool can_resume { get; }

	public abstract Gtk.Widget get_display ();
	public abstract void start () throws Error;
	public abstract void resume () throws Error;
	public abstract void pause ();
}

private errordomain Games.RunError {
	EXECUTION_FAILED,
	INVALID_COMMAND,
	INVALID_GAME_FILE,
	MODULE_NOT_FOUND,
	COULDNT_GET_UID,
	COULDNT_WRITE_SNAPSHOT,
	COULDNT_LOAD_SNAPSHOT,
	COULDNT_WRITE_SCREENSHOT,
	COULDNT_LOAD_SCREENSHOT,
}
