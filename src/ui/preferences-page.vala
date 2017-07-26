// This file is part of GNOME Games. License: GPL-3.0+.

private interface Games.PreferencesPage: Gtk.Widget {
	public abstract Gtk.HeaderBar header_bar { protected set; get; }
	public abstract bool immersive_mode { protected set; get; }
	public virtual void visible_page_changed () {}
}
