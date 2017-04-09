// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PluginRegistrar : TypeModule {
	public string name { private set; get; }
	public string description { private set; get; }

	private Plugin plugin;
	private string module_path;
	private Type type;
	private Module module;
	private bool loaded;

	private delegate Type RegisterPluginFunc (TypeModule module);

	public PluginRegistrar (string plugin_filename) throws PluginError {
		assert (Module.supported ());

		try {
			var keyfile = new KeyFile ();
			keyfile.load_from_file (plugin_filename, KeyFileFlags.NONE);
			var module_name = keyfile.get_string ("Plugin", "Module");
			module_path = Module.build_path (PLUGINS_DIR, module_name);
			name = keyfile.get_string ("Plugin", "Name");
			description = keyfile.get_string ("Plugin", "Description");
		}
		catch (Error e) {
			throw new PluginError.INVALID_PLUGIN_DESCRIPTOR (_("Invalid plugin descriptor: %s"), e.message);
		}

		loaded = false;
	}

	public Plugin get_plugin () throws PluginError {
		if (plugin != null)
			return plugin;

		plugin = new_plugin ();

		return plugin;
	}

	private Plugin new_plugin () throws PluginError {
		if (!loaded)
			load ();

		var object = Object.new (type);
		if (object == null)
			throw new PluginError.NOT_A_PLUGIN (_("Couldn’t create a new instance of plugin in “%s”."), module_path);

		var plugin = object as Plugin;
		if (plugin == null)
			throw new PluginError.NOT_A_PLUGIN (_("Couldn’t create a new instance of plugin in “%s”."), module_path);

		return plugin;
	}

	public override bool load () {
		if (loaded)
			return true;

		module = Module.open (module_path, ModuleFlags.BIND_LAZY);
		if (module == null)
			return false;

		void* function;
		module.symbol ("register_games_plugin", out function);
		if (function == null)
			return false;

		unowned RegisterPluginFunc register_plugin = (RegisterPluginFunc) function;

		type = register_plugin (this);

		loaded = true;

		return true;
	}
}

private errordomain Games.PluginError {
	INVALID_PLUGIN_DESCRIPTOR,
	NOT_A_PLUGIN,
}
