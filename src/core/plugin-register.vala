// This file is part of GNOME Games. License: GPLv3

private class Games.PluginRegister : Object {
	public delegate void PluginFunc (Plugin plugin);

	private HashTable<string, PluginRegistrar> plugin_registrars;

	public void foreach_plugin (PluginFunc func) {
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
					var plugin = registrar.get_plugin ();
					func (plugin);
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
