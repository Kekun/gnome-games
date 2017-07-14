// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DatabaseUriIterator : Object, UriIterator {
	private const string SELECT_GAME_RESOURCE_QUERY = """
		SELECT uri FROM game_resources;
	""";

	private Sqlite.Statement statement;
	private Uri? uri;

	internal DatabaseUriIterator (Sqlite.Database database) {
		statement = Database.prepare (database, SELECT_GAME_RESOURCE_QUERY);
	}

	public new Uri? get () {
		return uri;
	}

	public bool next () {
		if (statement.step () != Sqlite.ROW)
			return false;

		uri = new Uri (statement.column_text (0));

		return true;
	}
}
