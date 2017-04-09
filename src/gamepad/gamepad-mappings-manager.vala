// This file is part of GNOME Games. License: GPL-3.0+.

/**
 * This class gives methods to set/update the mappings
 *
 * The client interfaces with this class primarily
 */
private class Games.GamepadMappingsManager : Object {
	private const string MAPPINGS_FILE_NAME = "gamecontrollerdb.txt";

	private HashTable<string, string> names;
	private HashTable<string, string> mappings;

	private static GamepadMappingsManager? instance;

	private GamepadMappingsManager () {
		if (names == null)
			names = new HashTable<string, string> (str_hash, str_equal);
		if (mappings == null)
			mappings = new HashTable<string, string> (str_hash, str_equal);
		try {
			add_from_resource ("/org/gnome/Games/gamepads/gamecontrollerdb.txt");
		}
		catch (Error e) {
			warning ("GamepadMappingsManager: Can’t find gamecontrollerdb.txt: %s", e.message);
		}
		try {
			var dir = Application.get_config_dir ();
			var path = @"$dir/$MAPPINGS_FILE_NAME";
			var file = File.new_for_path (path);
			if (file.query_exists ())
				add_from_file (path);
		}
		catch (Error e) {
			warning ("GamepadMappingsManager: Can’t add from user’s config dir’s %s: %s", MAPPINGS_FILE_NAME, e.message);
		}
	}

	public static GamepadMappingsManager get_instance () {
		if (instance == null)
			instance = new GamepadMappingsManager ();
		return instance;
	}

	public void add_from_resource (string path) throws Error {
		add_from_input_stream (resources_open_stream (path, ResourceLookupFlags.NONE));
	}

	public void add_from_file (string file_name) throws Error {
		var file = File.new_for_path (file_name);
		add_from_input_stream (file.read ());
	}

	public void add_from_input_stream (InputStream input_stream) throws IOError {
		var data_stream = new DataInputStream (input_stream);
		var mapping_string = data_stream.read_line ();
		while (mapping_string != null) {
			add_mapping (mapping_string);
			mapping_string = data_stream.read_line ();
		}
	}

	/**
	 * Adds a mapping from a SDL2 mapping string (only one gamepad)
	 */
	public void add_mapping (string mapping_string) {
		if (mapping_string == "" || mapping_string[0] == '#')
			return;

		if (mapping_string.index_of ("platform") == -1 || mapping_string.index_of ("platform:Linux") != -1) {
			var split = mapping_string.split (",", 3);
			names[split[0]] = split[1];
			mappings[split[0]] = split[2];
		}
	}

	/**
	 * Gets the current mapping from the databse
	 * @param  guid          The guid of the wanted gamepad
	 * @return The mapping if present in the database
	 */
	public string? get_mapping (string guid) {
		return mappings[guid];
	}
}
