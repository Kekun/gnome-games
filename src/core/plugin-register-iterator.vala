// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PluginRegisterIterator {
	private PluginRegister plugin_register;
	private PluginRegistrar? plugins_registrar;
	private FileEnumerator enumerator;

	internal PluginRegisterIterator (PluginRegister plugin_register) {
		this.plugin_register = plugin_register;
		enumerator = null;
	}

	public new PluginRegistrar? get () {
		return plugins_registrar;
	}

	public bool next () {
		try {
			var directory = File.new_for_path (PLUGINS_DIR);
			if (enumerator == null) {
				enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
			}

			FileInfo info;
			while ((info = enumerator.next_file ()) != null) {
				var name = info.get_name ();
				if (!name.has_suffix (".plugin"))
					continue;

				var descriptor = directory.get_child (name);
				var descriptor_path = descriptor.get_path ();
				plugins_registrar = plugin_register.get_plugin_registrar (descriptor_path);

				return true;
			}
		}
		catch (Error e) {
			debug (e.message);
		}

		plugins_registrar = null;

		return false;
	}
}
