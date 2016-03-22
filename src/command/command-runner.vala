// This file is part of GNOME Games. License: GPLv3

public class Games.CommandRunner : Object, Runner {
	public bool can_resume {
		get { return false; }
	}

	private string[] args;

	public CommandRunner (string[] args) {
		this.args = args;
	}

	public void check_is_valid () throws Error {
		if (args.length < 1)
			throw new CommandError.INVALID_COMMAND ("Invalid command: it doesn't have any argument.");
	}

	public Gtk.Widget get_display () {
		return new RemoteDisplay ();
	}

	private bool running;

	public void start () throws Error {
		if (running)
			return;

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
				working_directory, args, envp, flags, child_setup, out pid,
				out standard_input, out standard_output, out standard_error);
			if (!result)
				throw new CommandError.EXECUTION_FAILED ("Couldn't run '%s': execution failed\n".printf (args[0]));
		}
		catch (SpawnError e) {
			warning ("%s\n", e.message);

			return;
		}

		ChildWatch.add (pid, (() => { on_process_stopped (); }));

		running = true;
	}

	public void resume () throws Error {
	}

	public void pause () {
	}

	private void on_process_stopped () {
		running = false;
		stopped ();
	}
}

