// This file is part of GNOME Games. License: GPLv3

public class Games.GriloCover : Object, Cover {
	private GriloMedia media;
	private Uid uid;
	private GLib.Icon icon;
	private bool resolving;
	private string cover_path;

	public GriloCover (GriloMedia media, Uid uid) {
		this.media = media;
		this.uid = uid;
		media.resolved.connect (on_media_resolved);
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

		media.try_resolve_media ();

		return icon;
	}

	private void on_media_resolved () {
		var grl_media = media.get_media ();

		return_if_fail (grl_media != null);

		return_if_fail (grl_media.length (Grl.MetadataKey.THUMBNAIL) != 0);

		var uri = grl_media.get_thumbnail_nth (0);
		fetch_cover.begin (uri);
	}

	private string get_cover_path () {
		if (cover_path != null)
			return cover_path;

		var dir = Application.get_covers_dir ();
		var uid = uid.get_uid ();
		cover_path = @"$dir/$uid.cover";

		return cover_path;
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
