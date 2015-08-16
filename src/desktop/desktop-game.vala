// This file is part of GNOME Games. License: GPLv3

private class Games.DesktopGame: Object, Game {
	public string name {
		get { return app_info.get_name (); }
	}

	public Icon? icon {
		get { return app_info.get_icon (); }
	}

	private DesktopAppInfo app_info;

	public DesktopGame (string uri) {
		var file = File.new_for_uri (uri);
		var path = file.get_path ();

		app_info = new DesktopAppInfo.from_filename (path);
	}
}
