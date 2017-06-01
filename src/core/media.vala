// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.Media : Object {
	public Title? title { get; private set; }

	private MediaInfo media_info;
	private Uri[] uris;

	public Media (Title? title = null) {
		this.media_info = new MediaInfo ("Dummy", "dummy", null, 0);
		this.title = title;
		this.uris = {};
	}

	public MediaInfo get_media_info () {
		// FIXME A proper MediaInfo shbould be returned at all time.
		return media_info ?? new MediaInfo ("Dummy", "dummy", null, 0);
	}

	public Uri[] get_uris () {
		return uris;
	}

	public void add_uri (Uri uri) {
		uris += uri;
	}
}
