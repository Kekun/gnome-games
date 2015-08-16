// This file is part of GNOME Games. License: GPLv3

private class Games.DesktopGameSource: Object, GameSource {
	private const string games_query = "SELECT ?soft WHERE { ?soft nie:isLogicalPartOf 'urn:software-category:Game' . }";

	public void each_game (GameCallback callback) {
		var tracker = Tracker.Sparql.Connection.@get ();
		var cursor = tracker.query (games_query);

		// 'while', not 'do while': the cursor doesn't start on a valid row.
		while (cursor.next ()) {
			var uri = cursor.get_string (0);
			callback (new DesktopGame(uri));
		}
	}
}
