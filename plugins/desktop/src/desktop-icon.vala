// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.DesktopIcon : Object, Icon {
	private DesktopAppInfo app_info;

	public DesktopIcon (DesktopAppInfo app_info) {
		this.app_info = app_info;
	}

	public GLib.Icon? get_icon () {
		return app_info.get_icon ();
	}
}
