// This file is part of GNOME Games. License: GPLv3

public class Games.RetroRunner : Object, Runner {
	public bool can_resume {
		get {
			try {
				var snapshot_path = get_snapshot_path ();
				var file = File.new_for_path (snapshot_path);

				return file.query_exists ();
			}
			catch (Error e) {
				warning (e.message);
			}

			return false;
		}
	}

	private Retro.Core core;
	private RetroGtk.CairoDisplay video;
	private RetroGtk.PaPlayer audio;
	private RetroGtk.VirtualGamepad gamepad;
	private RetroGtk.Keyboard keyboard;
	private RetroGtk.InputDeviceManager input;
	private Retro.Options options;
	private RetroLog log;
	private Retro.Loop loop;

	private Gtk.EventBox widget;

	private string save_path;
	private string snapshot_path;
	private string screenshot_path;

	private string module_basename;
	private string uri;
	private Uid uid;

	private bool _running;
	private bool running {
		set {
			_running = value;

			video.sensitive = running;
		}
		get { return _running; }
	}

	private bool is_initialized;

	public RetroRunner (string module_basename, string uri, Uid uid) throws Error {
		is_initialized = false;

		this.module_basename = module_basename;
		this.uri = uri;
		this.uid = uid;
	}

	~RetroRunner () {
		if (!is_initialized)
			return;

		loop.stop ();
		running = false;

		try {
			save ();
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	public Gtk.Widget get_display () {
		return widget;
	}

	public void start () throws Error {
		if (!is_initialized)
			init();

		loop.stop ();

		load_ram ();
		core.reset ();

		loop.start ();
		running = true;
	}

	public void resume () throws Error {
		if (!is_initialized)
			init();

		loop.stop ();

		load_ram ();
		core.reset ();
		load_snapshot ();

		loop.start ();
		running = true;
	}

	private void init () throws Error {
		if (is_initialized)
			return;

		video = new RetroGtk.CairoDisplay ();

		widget = new Gtk.EventBox ();
		widget.add (video);
		video.visible = true;

		gamepad = new RetroGtk.VirtualGamepad (widget);
		keyboard = new RetroGtk.Keyboard (widget);

		prepare_core (module_basename, uri);
		core.shutdown.connect (on_shutdown);

		core.run (); // Needed to finish preparing some cores.

		loop = new Retro.MainLoop (core);
		running = false;

		load_screenshot ();

		is_initialized = true;
	}

	private void prepare_core (string module_basename, string uri) throws Error {
		var module_path = Retro.search_module (module_basename);
		var module = File.new_for_path (module_path);
		if (!module.query_exists ()) {
			var msg = @"Couldn't run game: module '$module_basename' not found.";

			throw new RetroError.MODULE_NOT_FOUND (msg);
		}

		core = new Retro.Core (module_path);
		audio = new RetroGtk.PaPlayer ();
		input = new RetroGtk.InputDeviceManager ();
		options = new Retro.Options ();
		log = new RetroLog ();

		input.set_controller_device (0, gamepad);
		input.set_keyboard (keyboard);

		core.variables_interface = options;
		core.log_interface = log;

		core.video_interface = video;
		core.audio_interface = audio;
		core.input_interface = input;

		core.init ();

		if (!try_load_game (core, uri))
			throw new RetroError.INVALID_GAME_FILE (@"Invalid game file: $uri");
	}

	private bool try_load_game (Retro.Core core, string uri) {
		var file = File.new_for_uri (uri);
		var path = file.get_path ();

		try {
			var fullpath = core.system_info.need_fullpath;
			if (core.load_game (fullpath ? Retro.GameInfo (path) : Retro.GameInfo.with_data (path))) {
				if (core.disk_control_interface != null) {
					var disk = core.disk_control_interface;

					disk.set_eject_state (true);

					while (disk.get_num_images () < 1)
						disk.add_image_index ();

					var index = disk.get_num_images () - 1;

					disk.replace_image_index (index, fullpath ? Retro.GameInfo (path) : Retro.GameInfo.with_data (path));

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
		if (!is_initialized)
			return;

		loop.stop ();
		running = false;


		try {
			save ();
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	private void save () throws Error {
		save_ram ();
		save_snapshot ();
		save_screenshot ();
	}

	private string get_save_path () throws Error {
		if (save_path != null)
			return save_path;

		var dir = Application.get_saves_dir ();
		var uid = uid.get_uid ();
		save_path = @"$dir/$uid.save";

		return save_path;
	}

	private void save_ram () throws Error{
		var save = core.get_memory (Retro.MemoryType.SAVE_RAM);
		if (save.length == 0)
			return;

		var dir = Application.get_saves_dir ();
		try_make_dir (dir);

		var save_path = get_save_path ();

		FileUtils.set_data (save_path, save);
	}

	private void load_ram () throws Error {
		var save_path = get_save_path ();

		if (!FileUtils.test (save_path, FileTest.EXISTS))
			return;

		uint8[] data = null;
		FileUtils.get_data (save_path, out data);

		var expected_size = core.get_memory_size (Retro.MemoryType.SAVE_RAM);
		if (data.length != expected_size)
			warning ("Unexpected RAM data size: got %lu, expected %lu\n", data.length, expected_size);

		core.set_memory (Retro.MemoryType.SAVE_RAM, data);
	}

	private string get_snapshot_path () throws Error {
		if (snapshot_path != null)
			return snapshot_path;

		var dir = Application.get_snapshots_dir ();
		var uid = uid.get_uid ();
		snapshot_path = @"$dir/$uid.snapshot";

		return snapshot_path;
	}

	private void save_snapshot () throws Error {
		var size = core.serialize_size ();
		var buffer = new uint8[size];

		if (!core.serialize (buffer))
			throw new RetroError.COULDNT_WRITE_SNAPSHOT ("Couldn't write snapshot.");

		var dir = Application.get_snapshots_dir ();
		try_make_dir (dir);

		var snapshot_path = get_snapshot_path ();

		FileUtils.set_data (snapshot_path, buffer);
	}

	private void load_snapshot () throws Error {
		var snapshot_path = get_snapshot_path ();

		if (!FileUtils.test (snapshot_path, FileTest.EXISTS))
			return;

		uint8[] data = null;
		FileUtils.get_data (snapshot_path, out data);

		var expected_size = core.serialize_size ();
		if (data.length != expected_size)
			warning ("Unexpected serialization data size: got %lu, expected %lu\n", data.length, expected_size);

		if (!core.unserialize (data))
			throw new RetroError.COULDNT_LOAD_SNAPSHOT ("Couldn't load snapshot.");
	}

	private string get_screenshot_path () throws Error {
		if (screenshot_path != null)
			return screenshot_path;

		var dir = Application.get_snapshots_dir ();
		var uid = uid.get_uid ();
		screenshot_path = @"$dir/$uid.png";

		return screenshot_path;
	}

	private void save_screenshot () throws Error {
		var pixbuf = video.pixbuf;
		if (pixbuf == null)
			return;

		var screenshot_path = get_screenshot_path ();

		pixbuf.save (screenshot_path, "png");
	}

	private void load_screenshot () throws Error {
		var screenshot_path = get_screenshot_path ();

		if (!FileUtils.test (screenshot_path, FileTest.EXISTS))
			return;

		var pixbuf = new Gdk.Pixbuf.from_file (screenshot_path);
		video.pixbuf = pixbuf;
	}

	private bool on_shutdown () {
		pause ();
		stopped ();

		return true;
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
}

