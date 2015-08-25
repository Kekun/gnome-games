// This file is part of GNOME Games. License: GPLv3

private class Games.RetroRunner : Object, Runner {
	public bool can_resume {
		get {
			var file = File.new_for_path (snapshot_path);

			return file.query_exists ();
		}
	}

	private string _save_path;
	private string save_path {
		get {
			if (_save_path != null)
				return _save_path;

			var dir = Application.get_saves_dir ();
			_save_path = @"$dir/$uid.save";

			return _save_path;
		}
	}

	private string _snapshot_path;
	private string snapshot_path {
		get {
			if (_snapshot_path != null)
				return _snapshot_path;

			var dir = Application.get_snapshots_dir ();
			_snapshot_path = @"$dir/$uid.snapshot";

			return _snapshot_path;
		}
	}

	private Retro.Core core;
	private RetroGtk.CairoDisplay video;
	private RetroGtk.PaPlayer audio;
	private RetroGtk.VirtualGamepad gamepad;
	private RetroGtk.InputDeviceManager input;
	private Retro.Loop loop;

	private Gtk.EventBox widget;

	private string module_path;
	private string game_path;
	private string uid;

	private bool running;

	public RetroRunner (string module_basename, string game_path, string uid) {
		var modules_dir = Retro.get_plugins_dir ();
		this.module_path = @"$modules_dir/$module_basename";
		this.game_path = game_path;
		this.uid = uid;
	}

	construct {
		video = new RetroGtk.CairoDisplay ();

		widget = new Gtk.EventBox ();
		widget.add (video);
		video.visible = true;

		gamepad = new RetroGtk.VirtualGamepad (widget);
	}

	~RetroRunner () {
		if (loop != null)
			loop.stop ();
		running = false;

		save ();
	}

	public Gtk.Widget get_display () {
		return widget;
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
			load_snapshot ();

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

		load_ram ();
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

		save ();
	}

	private void save () {
		save_ram ();
		save_snapshot ();
	}

	private void save_ram () {
		var save = core.get_memory (Retro.MemoryType.SAVE_RAM);
		if (save.length == 0)
			return;

		var dir = Application.get_saves_dir ();
		try_make_dir (dir);

		save_to_file (save_path, save);
	}

	private void load_ram () {
		var size = core.get_memory_size (Retro.MemoryType.SAVE_RAM);
		if (size == 0)
			return;

		var data = load_from_file (save_path, size);
		if (data == null)
			return;

		core.set_memory (Retro.MemoryType.SAVE_RAM, data);
	}

	private void save_snapshot () {
		var size = core.serialize_size ();
		var buffer = new uint8[size];

		if (!core.serialize (buffer))
			return; // FIXME: Should throw error rather that returning.

		var dir = Application.get_snapshots_dir ();
		try_make_dir (dir);

		save_to_file (snapshot_path, buffer);
	}

	private void load_snapshot () {
		var size = core.serialize_size ();
		if (size == 0)
			return;

		var data = load_from_file (snapshot_path, size);
		if (data == null)
			return;

		if (!core.unserialize (data))
			return; // FIXME: Should throw error rather that returning.
	}

	private static void try_make_dir (string path) {
		var file = File.new_for_path (path);
		try {
			if (!file.query_exists ())
				file.make_directory_with_parents ();
		}
		catch (Error e) {
			warning (@"$(e.message)\n");

			return;
		}
	}

	private static uint8[]? load_from_file (string path, size_t size) {
		var file = File.new_for_path (path);

		if (!file.query_exists ())
			return null;

		FileInputStream stream;
		try {
			stream = file.read ();
		}
		catch (Error e) {
			warning (@"$(e.message)\n");

			return null;
		}

		var buffer = new uint8[size];

		try {
			stream.read (buffer);
		}
		catch (IOError e) {
			warning (@"$(e.message)\n");

			return null;
		}

		return buffer;
	}

	private static void save_to_file (string path, uint8[] data) {
		var file = File.new_for_path (path);

		FileOutputStream stream;
		try {
			stream = file.replace (null, false, FileCreateFlags.NONE);
		}
		catch (Error e) {
			warning (@"$(e.message)\n");

			return;
		}

		try {
			stream.write (data);
		}
		catch (IOError e) {
			warning (@"$(e.message)\n");

			return;
		}
	}
}

