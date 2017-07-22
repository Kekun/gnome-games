// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.Database : Object {
	private Sqlite.Database database;

	private const string CREATE_TABLE_QUERY = """
		CREATE TABLE IF NOT EXISTS game_resources (
			id INTEGER PRIMARY KEY NOT NULL,
			uri TEXT NOT NULL
		);
	""";

	private const string ADD_GAME_RESOURCE_QUERY = """
		INSERT INTO game_resources (id, uri) VALUES (NULL, $URI);
	""";

	private const string HAS_URI_QUERY = """
		SELECT EXISTS (SELECT 1 FROM game_resources WHERE uri=$URI LIMIT 1);
	""";

	public Database (string path) throws Error {
		if (Sqlite.Database.open (path, out database) != Sqlite.OK)
			throw new DatabaseError.COULDNT_OPEN ("Couldn’t open the database for “%s”.", path);

		create_tables ();
	}

	public void add_uri (Uri uri) throws Error {
		if (has_uri (uri))
			return;

		var statement = prepare (database, ADD_GAME_RESOURCE_QUERY);

		bind_text (statement, "$URI", uri.to_string ());

		if (statement.step () != Sqlite.DONE)
			throw new DatabaseError.EXECUTION_FAILED ("Execution failed.");
	}

	public bool has_uri (Uri uri) throws Error {
		var statement = prepare (database, HAS_URI_QUERY);

		bind_text (statement, "$URI", uri.to_string ());

		switch (statement.step ()) {
		case Sqlite.ROW:
			return statement.column_text (0) == "1";
		default:
			debug ("Execution failed.");

			return false;
		}
	}

	public DatabaseUriSource get_uri_source () {
		return new DatabaseUriSource (database);
	}

	private void create_tables () throws Error {
		exec (CREATE_TABLE_QUERY, null);
	}

	private void exec (string query, Sqlite.Callback? callback) throws Error {
		string error_message;

		if (database.exec (query, callback, out error_message) != Sqlite.OK)
			throw new DatabaseError.EXECUTION_FAILED ("Execution failed: %s", error_message);
	}

	internal static Sqlite.Statement prepare (Sqlite.Database database, string query) throws Error {
		Sqlite.Statement statement;
		if (database.prepare_v2 (query, query.length, out statement) != Sqlite.OK)
			throw new DatabaseError.PREPARATION_FAILED ("Preparation failed: %s", database.errmsg ());

		return statement;
	}

	internal static void bind_text (Sqlite.Statement statement, string parameter, string text) throws Error {
		var position = statement.bind_parameter_index (parameter);
		if (position <= 0)
			throw new DatabaseError.BINDING_FAILED ("Couldn't bind text to the parameter “%s”, unexpected position: %d.", parameter, position);

		statement.bind_text (position, text);
	}
}
