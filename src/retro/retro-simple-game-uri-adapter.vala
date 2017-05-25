// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.RetroSimpleGameUriAdapter : GameUriAdapter, Object {
	private RetroSimpleType simple_type;

	public RetroSimpleGameUriAdapter (RetroSimpleType simple_type) {
		this.simple_type = simple_type;
	}

	public async Game game_for_uri (Uri uri) throws Error {
		Idle.add (this.game_for_uri.callback);
		yield;

		var uid = new FingerprintUid (uri, simple_type.prefix);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, simple_type.mime_type);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var core_source = new RetroCoreSource (simple_type.platform, { simple_type.mime_type });
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}
}
