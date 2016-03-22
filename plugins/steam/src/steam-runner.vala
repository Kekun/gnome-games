// This file is part of GNOME Games. License: GPLv3

private class Games.SteamRunner : Object, Runner {
	public bool can_resume {
		get { return false; }
	}

	private string game_id;

	public SteamRunner (string game_id) {
		this.game_id = game_id;
	}

	public void check_is_valid () throws Error {
	}

	public Gtk.Widget get_display () {
		return new RemoteDisplay ();
	}

	public void start () throws Error {
		string? working_directory = null;

		string[] args = { "steam", @"steam://rungameid/$game_id" };
		string[]? envp = null;
		var flags = SpawnFlags.SEARCH_PATH;
		SpawnChildSetupFunc? child_setup = null;
		Pid pid;
		int? standard_input = null;
		int? standard_output = null;
		int? standard_error = null;

		try {
			var result = Process.spawn_async_with_pipes (
				working_directory, args, envp, flags, child_setup, out pid,
				out standard_input, out standard_output, out standard_error);
			if (!result)
				throw new CommandError.EXECUTION_FAILED ("Couldn't run '%s': execution failed\n".printf (args[0]));
		}
		catch (SpawnError e) {
			warning ("%s\n", e.message);
		}
	}

	public void resume () throws Error {
	}

	public void pause () {
	}
}

