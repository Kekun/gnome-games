// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.DesktopTitle : Object, Title {
	private DesktopAppInfo app_info;

	public DesktopTitle (DesktopAppInfo app_info) {
		this.app_info = app_info;
	}

	public string get_title () throws Error {
		return app_info.get_name ();
	}
}
