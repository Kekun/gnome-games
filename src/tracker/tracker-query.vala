// This file is part of GNOME Games. License: GPLv3

public interface Games.TrackerQuery : Object {
	public abstract bool is_cursor_valid (Tracker.Sparql.Cursor cursor);
	public abstract string get_query ();
	public abstract void process_cursor (Tracker.Sparql.Cursor cursor);
	public abstract async void foreach_game (GameCallback game_callback);
}
