// This file is part of GNOME Games. License: GPLv3

private class Games.RetroRunner : Object, Runner {
	private Retro.Core core;
	private RetroGtk.CairoDisplay video;
	private RetroGtk.PaPlayer audio;
	private RetroGtk.VirtualGamepad gamepad;
	private RetroGtk.InputDeviceManager input;
	private Retro.Loop loop;

	private string module_path;
	private string game_path;

	private bool running;

	public RetroRunner (string module_basename, string game_path) {
		var modules_dir = Retro.get_plugins_dir ();
		this.module_path = @"$modules_dir/$module_basename";
		this.game_path = game_path;
	}

	construct {
		video = new RetroGtk.CairoDisplay ();
		gamepad = new RetroGtk.VirtualGamepad (video);
	}

	~RetroRunner () {
		if (loop != null)
			loop.stop ();
		running = false;
	}

	public Gtk.Widget get_display () {
		return video;
	}

	public void start () throws RunError {
		if (core == null) {
			run ();

			return;
		}

		loop.stop ();
		core.reset ();
		loop.start ();

		running = true;
	}

	public void resume () throws RunError {
		if (core == null) {
			run ();

			return;
		}

		loop.start ();
		running = true;
	}

	public void run () throws RunError {
		if (core == null)
			prepare_core ();

		if (loop == null)
			loop = new Retro.MainLoop (core);

		if (!running)
			loop.start ();
		running = true;
	}

	public void prepare_core () throws RunError {
		var module = File.new_for_path (module_path);
		if (!module.query_exists ()) {
			var msg = @"Couldn't run game: module '$module_path' not found.";

			throw new RunError.MODULE_NOT_FOUND (msg);
		}

		core = new Retro.Core (module_path);
		audio = new RetroGtk.PaPlayer ();
		input = new RetroGtk.InputDeviceManager ();

		input.set_controller_device (0, gamepad);

		core.video_interface = video;
		core.audio_interface = audio;
		core.input_interface = input;

		core.init ();

		if (!try_load_game (core, game_path))
			throw new RunError.INVALID_GAME_FILE (@"Invalid game file: $game_path");
	}

	private bool try_load_game (Retro.Core core, string game_name) {
		try {
			var fullpath = core.system_info.need_fullpath;
			if (core.load_game (fullpath ? Retro.GameInfo (game_name) : Retro.GameInfo.with_data (game_name))) {
				if (core.disk_control_interface != null) {
					var disk = core.disk_control_interface;

					disk.set_eject_state (true);

					while (disk.get_num_images () < 1)
						disk.add_image_index ();

					var index = disk.get_num_images () - 1;

					disk.replace_image_index (index, fullpath ? Retro.GameInfo (game_name) : Retro.GameInfo.with_data (game_name));

					disk.set_eject_state (false);
				}
				return true;
			}
		}
		catch (GLib.FileError e) {
			stderr.printf ("Error: %s\n", e.message);
		}
		catch (Retro.CbError e) {
			stderr.printf ("Error: %s\n", e.message);
		}

		return false;
	}

	public void pause () {
		if (loop != null)
			loop.stop ();
		running = false;
	}
}

