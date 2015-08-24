// This file is part of GNOME Games. License: GPLv3

private class Games.DesktopRunner : Object, Runner {
	private string name {
		get { return app_info.get_name (); }
	}

	private DesktopAppInfo app_info;

	public Gtk.Widget get_display () {
		return new RemoteDisplay ();
	}

	public DesktopRunner (DesktopAppInfo app_info) {
		this.app_info = app_info;
	}

	private bool running;

	public void start () throws RunError {
		if (running)
			return;

		string[] argv;
		try {
			var command = app_info.get_commandline ();
			if (!Shell.parse_argv (command, out argv))
				throw new RunError.INVALID_COMMAND ("Couldn't run '%s': invalid command '%s'".printf (name, command));
		}
		catch (ShellError e) {
			throw new RunError.INVALID_COMMAND ("Couldn't run '%s': %s".printf (name, e.message));
		}

		string? working_directory = null;
		string[]? envp = null;
		var flags = SpawnFlags.SEARCH_PATH |
		            SpawnFlags.DO_NOT_REAP_CHILD; // Necessary to watch the child ourselves.
		SpawnChildSetupFunc? child_setup = null;
		Pid pid;
		int? standard_input = null;
		int? standard_output = null;
		int? standard_error = null;

		try {
			var result = Process.spawn_async_with_pipes (
				working_directory, argv, envp, flags, child_setup, out pid,
				out standard_input, out standard_output, out standard_error);
			if (!result)
				throw new RunError.EXECUTION_FAILED ("Couldn't run '%s': execution failed\n".printf (name));
		}
		catch (SpawnError e) {
			warning ("%s\n", e.message);

			return;
		}

		ChildWatch.add (pid, (() => { on_process_stopped (); }));

		running = true;
	}

	public void pause () {
	}

	private void on_process_stopped () {
		running = false;
		stopped ();
	}
}

