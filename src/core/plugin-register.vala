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

	public PluginRegisterIterator iterator () {
		return new PluginRegisterIterator (this);
	}

	public PluginRegistrar get_plugin_registrar (string descriptor_filename) throws Error {
		if (plugin_registrars.contains (descriptor_filename))
			return plugin_registrars[descriptor_filename];

		var registrar = new PluginRegistrar (descriptor_filename);
		plugin_registrars[descriptor_filename] = registrar;

		return registrar;
	}
}
