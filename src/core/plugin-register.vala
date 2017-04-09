// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PluginRegister : Object {
	public delegate void PluginRegistrarFunc (PluginRegistrar plugin_registrar);

	private static PluginRegister instance;
	private HashTable<string, PluginRegistrar> plugin_registrars;

	private PluginRegister () {
		plugin_registrars = new HashTable<string, PluginRegistrar> (str_hash, str_equal);
	}

	public static PluginRegister get_register () {
		if (instance == null)
			instance = new PluginRegister ();

		return instance;
	}

	public void foreach_plugin_registrar (PluginRegistrarFunc func) {
		var directory = File.new_for_path (PLUGINS_DIR);
		try {
			var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

			FileInfo info;
			while ((info = enumerator.next_file ()) != null) {
				var name = info.get_name ();
				if (name.has_suffix (".plugin")) {
					var descriptor = directory.get_child (name);
					var descriptor_path = descriptor.get_path ();

					var registrar = get_plugin_registrar (descriptor_path);
					func (registrar);
				}
			}

		}
		catch (Error e) {
			debug ("Error: %s", e.message);
		}
	}

	public PluginRegistrar get_plugin_registrar (string descriptor_filename) throws Error {
		if (plugin_registrars.contains (descriptor_filename))
			return plugin_registrars[descriptor_filename];

		var registrar = new PluginRegistrar (descriptor_filename);
		plugin_registrars[descriptor_filename] = registrar;

		return registrar;
	}
}
