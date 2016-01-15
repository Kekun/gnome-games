// This file is part of GNOME Games. License: GPLv3

private class Games.PluginRegister : Object {
	public delegate void PluginFunc (Plugin plugin);

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

					for_plugin_descriptor (descriptor_path, func);
				}
			}

		}
		catch (Error e) {
			debug ("Error: %s", e.message);
		}
	}

	public void for_plugin_descriptor (string descriptor_filename, PluginFunc func) throws Error {
		var keyfile = new KeyFile ();
		keyfile.load_from_file (descriptor_filename, KeyFileFlags.NONE);
		var module_name = keyfile.get_string ("Plugin", "Module");

		var registrar = new PluginRegistrar (module_name);
		var plugin = registrar.new_plugin ();
		func (plugin);
	}
}