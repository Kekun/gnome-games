// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.CommandRunner : Object, Runner {
	public bool can_fullscreen {
		get { return false; }
	}

	public bool can_quit_safely {
		get { return true; }
	}

	public bool can_resume {
		get { return false; }
	}

	public MediaSet? media_set {
		get { return null; }
	}

	private string[] args;
	private bool watch_child;

	public CommandRunner (string[] args, bool watch_child) {
		this.args = args;
		this.watch_child = watch_child;
	}

	public bool check_is_valid (out string error_message) throws Error {
		if (args.length > 0)
			return true;

		debug ("Invalid command: it doesn’t have any argument.");
		error_message = _("The game doesn’t have a valid command.");

		return false;
	}

	public Gtk.Widget get_display () {
		return new RemoteDisplay ();
	}

	private bool running;

	public void start () throws Error {
		if (running && watch_child)
			return;

		string? working_directory = null;
		string[]? envp = null;
		var flags = SpawnFlags.SEARCH_PATH;
		if (watch_child)
			flags |= SpawnFlags.DO_NOT_REAP_CHILD; // Necessary to watch the child ourselves.
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
				throw new CommandError.EXECUTION_FAILED (_("Couldn’t run “%s”: execution failed."), args[0]);
		}
		catch (SpawnError e) {
			warning ("%s\n", e.message);

			if (watch_child)
				return;
		}

		if (!watch_child)
			return;

		ChildWatch.add (pid, (() => { on_process_stopped (); }));

		running = true;
	}

	public void resume () throws Error {
	}

	public void pause () {
	}

	public void stop () {
	}

	private void on_process_stopped () {
		running = false;
		stopped ();
	}
}
