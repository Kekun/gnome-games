// This file is part of GNOME Games. License: GPLv3

private class Games.DesktopGame: Object, Game {
	public string name {
		get { return app_info.get_name (); }
	}

	private DesktopAppInfo app_info;

	public DesktopGame (string uri) {
		var file = File.new_for_uri (uri);
		var path = file.get_path ();

		app_info = new DesktopAppInfo.from_filename (path);
	}

	public Icon get_icon () {
		return new DesktopIcon (app_info);
	}

	public Runner get_runner () throws Error {
		string[] args;
		try {
			var command = app_info.get_commandline ();
			if (!Shell.parse_argv (command, out args))
				throw new CommandError.INVALID_COMMAND ("Couldn't run '%s': invalid command '%s'".printf (name, command));
		}
		catch (ShellError e) {
			throw new CommandError.INVALID_COMMAND ("Couldn't run '%s': %s".printf (name, e.message));
		}

		return new CommandRunner (args, true);
	}
}
