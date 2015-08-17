// This file is part of GNOME Games. License: GPLv3

private class Games.DesktopTrackerQuery : Object, TrackerQuery {
	public string get_query () {
		return "SELECT ?soft WHERE { ?soft nie:isLogicalPartOf 'urn:software-category:Game' . }";
	}

	public Game game_for_cursor (Tracker.Sparql.Cursor cursor) {
			var uri = cursor.get_string (0);

			return new DesktopGame (uri);
	}
}
