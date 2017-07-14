// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DatabaseUriSource : Object, UriSource {
	private unowned Sqlite.Database database;

	public DatabaseUriSource (Sqlite.Database database) {
		this.database = database;
	}

	public UriIterator iterator () {
		return new DatabaseUriIterator (database);
	}
}
