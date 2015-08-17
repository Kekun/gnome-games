// This file is part of GNOME Games. License: GPLv3

private interface Games.TrackerQuery : Object {
	public abstract string get_query ();
	public abstract Game game_for_cursor (Tracker.Sparql.Cursor cursor);
}
