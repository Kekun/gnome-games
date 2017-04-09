// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.SteamCover : Object, Cover {
	private string game_id;
	private GLib.Icon icon;
	private bool resolving;

	public SteamCover (string game_id) {
		this.game_id = game_id;
		resolving = false;
	}

	public GLib.Icon? get_cover () {
		if (resolving)
			return icon;

		if (icon != null)
			return icon;

		load_cover ();
		if (icon != null)
			return icon;

		resolving = true;

		var uri = @"http://cdn.akamai.steamstatic.com/steam/apps/$game_id/header.jpg";
		fetch_cover.begin (uri);

		return null;
	}

	private string get_cover_path () {
		var dir = Application.get_covers_dir ();

		return @"$dir/steam-$game_id.jpg";
	}

	private async void fetch_cover (string uri) {
		var dir = Application.get_covers_dir ();
		Application.try_make_dir (dir);

		var cover_path = get_cover_path ();

		var src = File.new_for_uri (uri);
		var dst = File.new_for_path (cover_path);

		try {
			yield src.copy_async (dst, FileCopyFlags.OVERWRITE);
		}
		catch (Error e) {
			warning (e.message);

			return;
		}

		load_cover ();
	}

	private void load_cover () {
		var cover_path = get_cover_path ();

		if (!FileUtils.test (cover_path, FileTest.EXISTS))
			return;

		var file = File.new_for_path (cover_path);
		icon = new FileIcon (file);

		changed ();
	}
}
