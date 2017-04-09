// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.LocalCover : Object, Cover {
	private string uri;
	private bool resolved;
	private GLib.Icon? icon;

	public LocalCover (string uri) {
		this.uri = uri;
	}

	public GLib.Icon? get_cover () {
		if (resolved)
			return icon;

		resolved = true;

		string? cover_path;
		try {
			cover_path = get_cover_path ();
		}
		catch (Error e) {
			debug (e.message);

			return null;
		}

		if (cover_path == null)
			return null;

		var file = File.new_for_path (cover_path);
		icon = new FileIcon (file);

		return icon;
	}

	private string? get_cover_path () throws Error {
		var cover_path = get_sibbling_cover_path ();
		if (FileUtils.test (cover_path, FileTest.EXISTS))
			return cover_path;

		cover_path = get_directory_cover_path ();
		if (FileUtils.test (cover_path, FileTest.EXISTS))
			return cover_path;

		return null;
	}

	private string? get_sibbling_cover_path () throws Error {
		var file = File.new_for_uri (uri);
		var parent = file.get_parent ();
		if (parent == null)
			return null;

		var basename = file.get_basename ();
		var splitted_basename = basename.split (".");
		var prefix = splitted_basename.length == 1 ? basename : string.joinv (".", splitted_basename[0:splitted_basename.length - 1]);

		string cover_path = null;
		var directory = new Directory (parent);
		directory.foreach ("*", (sibbling) => {
			var sibbling_basename = sibbling.get_name ();
			if (sibbling_basename == basename)
				return false;

			if (!sibbling_basename.has_prefix (prefix))
				return false;

			var type = sibbling.get_content_type ();
			if (!type.has_prefix ("image"))
				return false;

			var sibbling_file = parent.get_child (sibbling_basename);
			cover_path = sibbling_file.get_path ();

			return true;
		});

		return cover_path;
	}

	private string? get_directory_cover_path () throws Error {
		var file = File.new_for_uri (uri);
		var parent = file.get_parent ();
		if (parent == null)
			return null;

		string cover_path = null;
		var directory = new Directory (parent);
		directory.foreach ("*", (sibbling) => {
			var sibbling_basename = sibbling.get_name ();
			if (!sibbling_basename.has_prefix ("cover.") &&
			    !sibbling_basename.has_prefix ("folder."))
				return false;

			var type = sibbling.get_content_type ();
			if (!type.has_prefix ("image"))
				return false;

			var sibbling_file = parent.get_child (sibbling_basename);
			cover_path = sibbling_file.get_path ();

			return true;
		});

		return cover_path;
	}
}
