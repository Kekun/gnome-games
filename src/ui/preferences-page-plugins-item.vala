// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/preferences-page-plugins-item.ui")]
private class Games.PreferencesPagePluginsItem: Gtk.Box {
	[GtkChild]
	private Gtk.Label plugin_name;
	[GtkChild]
	private Gtk.Label plugin_description;

	public PreferencesPagePluginsItem (PluginRegistrar plugin_registrar) {
		plugin_name.label = plugin_registrar.name;
		plugin_description.label = plugin_registrar.description;
	}
}
