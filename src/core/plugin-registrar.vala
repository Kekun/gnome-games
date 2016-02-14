// This file is part of GNOME Games. License: GPLv3

private class Games.PluginRegistrar : TypeModule {
	private string path;
	private Type type;
	private Module module;
	private bool loaded;

	private delegate Type RegisterPluginFunc (TypeModule module);

	public PluginRegistrar (string name) {
		assert (Module.supported ());
		path = Module.build_path (PLUGINS_DIR, name);
		loaded = false;
	}

	public Plugin new_plugin () throws PluginError {
		if (!loaded)
			load ();

		var object = Object.new (type);
		if (object == null)
			throw new PluginError.NOT_A_PLUGIN ("Couldn't create a new instance of plugin in '%s'.", path);

		var plugin = object as Plugin;
		if (plugin == null)
			throw new PluginError.NOT_A_PLUGIN ("Couldn't create a new instance of plugin in '%s'.", path);

		return plugin;
	}

	public override bool load () {
		if (loaded)
			return true;

		module = Module.open (path, ModuleFlags.BIND_LAZY);
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
	NOT_A_PLUGIN,
}
