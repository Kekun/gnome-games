// This file is part of GNOME Games. License: GPLv3

public class Games.RetroRunner : Object, Runner {
	public bool can_fullscreen {
		get { return true; }
	}

	public bool can_quit_safely {
		get { return !should_save; }
	}

	public bool can_resume {
		get {
			if (!core_supports_snapshotting)
				return false;

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

	private MediaSet _media_set;
	public MediaSet? media_set {
		get { return _media_set; }
	}

	private Retro.Core core;
	private RetroGtk.CairoDisplay video;
	private RetroGtk.PaPlayer audio;
	private RetroInputManager input_manager;
	private Retro.Options options;
	private RetroLog log;
	private Retro.Loop loop;

	private Gtk.EventBox widget;

	private string save_path;
	private string snapshot_path;
	private string screenshot_path;

	private string module_basename;
	private string[] mime_types;
	private Uid uid;
	private bool core_supports_snapshotting;

	private bool _running;
	private bool running {
		set {
			_running = value;

			if (running)
				should_save = true;

			video.sensitive = running;
		}
		get { return _running; }
	}

	private bool is_initialized;
	private bool is_ready;
	private bool should_save;

	public RetroRunner (string module_basename, string uri, Uid uid, bool core_supports_snapshotting) {
		is_initialized = false;
		is_ready = false;
		should_save = false;

		var game_media = new Media (uri);
		_media_set = new MediaSet ({ game_media });

		this.module_basename = module_basename;
		this.uid = uid;
		this.core_supports_snapshotting = core_supports_snapshotting;
	}

	public RetroRunner.with_mime_types (string uri, Uid uid, string[] mime_types, string module_basename, bool core_supports_snapshotting) {
		is_initialized = false;
		is_ready = false;
		should_save = false;

		var game_media = new Media (uri);
		_media_set = new MediaSet ({ game_media });

		this.mime_types = mime_types;
		this.module_basename = module_basename;
		this.uid = uid;
		this.core_supports_snapshotting = core_supports_snapshotting;
	}

	public RetroRunner.for_media_set (MediaSet media_set, Uid uid, string[] mime_types, string module_basename, bool core_supports_snapshotting) {
		is_initialized = false;
		is_ready = false;
		should_save = false;

		this._media_set = media_set;
		this.mime_types = mime_types;
		this.module_basename = module_basename;
		this.uid = uid;
		this.core_supports_snapshotting = core_supports_snapshotting;

		_media_set.notify["selected-media-number"].connect (on_media_number_changed);
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

	public void check_is_valid () throws Error {
		load_media_data ();
		init ();
	}

	public Gtk.Widget get_display () {
		return widget;
	}

	public void start () throws Error {
		load_media_data ();

		if (!is_initialized)
			init();

		loop.stop ();

		if (!is_ready) {
			load_ram ();
			is_ready = true;
		}
		core.reset ();

		loop.start ();
		running = true;
	}

	public void resume () throws Error {
		if (!is_initialized)
			init();

		loop.stop ();

		if (!is_ready) {
			load_ram ();
			core.reset ();
			load_snapshot ();
			is_ready = true;
		}

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
		input_manager = new RetroInputManager (widget);

		var media_number = media_set.selected_media_number;
		var media = media_set.get_selected_media (media_number);
		var uri = media.uri;

		prepare_core (module_basename, uri);
		core.shutdown.connect (on_shutdown);

		core.run (); // Needed to finish preparing some cores.

		loop = new Retro.MainLoop (core);
		running = false;

		load_screenshot ();

		is_initialized = true;
	}

	private void deinit () {
		if (!is_initialized)
			return;

		core = null;
		video = null;
		audio = null;
		widget = null;
		input_manager = null;
		options = null;
		log = null;
		loop = null;

		_running = false;
		is_initialized = false;
		is_ready = false;
		should_save = false;
	}

	private void prepare_core (string module_basename, string uri) throws Error {
		var module_path = get_module_path ();
		core = new Retro.Core (module_path);
		audio = new RetroGtk.PaPlayer ();
		options = new Retro.Options ();
		log = new RetroLog ();

		core.variables_interface = options;
		core.log_interface = log;

		core.video_interface = video;
		core.audio_interface = audio;
		core.input_interface = input_manager.input;

		core.init ();

		if (!try_load_game (core, uri))
			throw new RetroError.INVALID_GAME_FILE (_("Invalid game file: '%s'."), uri);
	}

	private string get_module_path () throws Error {
		var module_path = Retro.search_module (module_basename);

		if (FileUtils.test (module_path, FileTest.EXISTS))
			return module_path;

		if (mime_types.length == 0)
			throw new RetroError.MODULE_NOT_FOUND (_("Couldn't run game: module '%s' not found."), module_basename);

		module_path = Retro.ModuleQuery.lookup_module_for_info (check_module_info);

		if (FileUtils.test (module_path, FileTest.EXISTS))
			return module_path;

		throw new RetroError.MODULE_NOT_FOUND (_("Couldn't run game: module '%s' not found and no module found for MIME types %s."), module_basename, string.joinv (" ", mime_types));
	}

	private bool check_module_info (HashTable<string, string> module_info) {
		if (!module_info.contains ("supported_mimetypes"))
			return false;

		if (!module_info.contains ("supports_serialization"))
			return false;

		var supported_mime_types = module_info["supported_mimetypes"];
		foreach (var mime_type in mime_types)
			if (!(mime_type in supported_mime_types))
				return false;

		var supports_serialization = false;
		switch (module_info["supports_serialization"]) {
		case "true":
			supports_serialization = true;

			break;
		case "false":
			supports_serialization = false;

			break;
		default:
			return false;
		}

		core_supports_snapshotting = supports_serialization;

		return true;
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

	public void stop () {
		if (!is_initialized)
			return;

		pause ();
		deinit ();

		stopped ();
	}

	private void on_media_number_changed () {
		if (!is_initialized)
			return;

		var media_number = media_set.selected_media_number;

		Media media = null;
		try {
			media = media_set.get_selected_media (media_number);
		}
		catch (Error e) {
			warning (e.message);

			return;
		}

		var uri = media.uri;

		try_load_game (core, uri);

		try {
			save_media_data ();
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	private void save () throws Error {
		if (!should_save)
			return;

		save_ram ();

		if (media_set.get_size () > 1)
			save_media_data ();

		if (!core_supports_snapshotting)
			return;

		save_snapshot ();
		save_screenshot ();

		should_save = false;
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
		if (!core_supports_snapshotting)
			return;

		var size = core.serialize_size ();
		var buffer = new uint8[size];

		if (!core.serialize (buffer))
			throw new RetroError.COULDNT_WRITE_SNAPSHOT (_("Couldn't write snapshot."));

		var dir = Application.get_snapshots_dir ();
		try_make_dir (dir);

		var snapshot_path = get_snapshot_path ();

		FileUtils.set_data (snapshot_path, buffer);
	}

	private void load_snapshot () throws Error {
		if (!core_supports_snapshotting)
			return;

		var snapshot_path = get_snapshot_path ();

		if (!FileUtils.test (snapshot_path, FileTest.EXISTS))
			return;

		uint8[] data = null;
		FileUtils.get_data (snapshot_path, out data);

		var expected_size = core.serialize_size ();
		if (data.length != expected_size)
			/* Not translated as this is not presented to the user */
			throw new RetroError.COULDNT_LOAD_SNAPSHOT ("[%s] Unexpected serialization data size: got %lu, expected %lu\n", core.file_name, data.length, expected_size);

		if (!core.unserialize (data))
			/* Not translated as this is not presented to the user */
			throw new RetroError.COULDNT_LOAD_SNAPSHOT ("Could not load snapshot");
	}

	private void save_media_data () throws Error {
		var dir = Application.get_medias_dir ();
		try_make_dir (dir);

		var medias_path = get_medias_path ();

		string contents = media_set.selected_media_number.to_string();

		FileUtils.set_contents (medias_path, contents, contents.length);
	}

	private void load_media_data () throws Error {
		var medias_path = get_medias_path ();

		if (!FileUtils.test (medias_path, FileTest.EXISTS))
			return;

		string contents;
		FileUtils.get_contents (medias_path, out contents);

		int disc_num = int.parse(contents);
		media_set.selected_media_number = disc_num;
	}

	private string get_medias_path () throws Error {
		var dir = Application.get_medias_dir ();
		var uid = uid.get_uid ();

		return @"$dir/$uid.media";
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
		if (!core_supports_snapshotting)
			return;

		var pixbuf = video.pixbuf;
		if (pixbuf == null)
			return;

		var screenshot_path = get_screenshot_path ();

		pixbuf.save (screenshot_path, "png");
	}

	private void load_screenshot () throws Error {
		if (!core_supports_snapshotting)
			return;

		var screenshot_path = get_screenshot_path ();

		if (!FileUtils.test (screenshot_path, FileTest.EXISTS))
			return;

		var pixbuf = new Gdk.Pixbuf.from_file (screenshot_path);
		video.pixbuf = pixbuf;
	}

	private bool on_shutdown () {
		stop ();

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
