// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.MegaDrivePlugin : Object, Plugin {
	private const string 32X_MIME_TYPE = "application/x-genesis-32x-rom";

	private const string MEGA_CD_PREFIX = "mega-cd";
	private const string CUE_MIME_TYPE = "application/x-cue";
	private const string MEGA_CD_MIME_TYPE = "application/x-sega-cd-rom";
	private const string MEGA_CD_PLATFORM = "SegaCD";
	private const string MEGA_CD_32X_PLATFORM = "SegaCD32X";

	public string[] get_mime_types () {
		return {
			CUE_MIME_TYPE,
			MEGA_CD_MIME_TYPE,
		};
	}

	public UriGameFactory[] get_uri_game_factories () {
		var game_uri_adapter = new GenericGameUriAdapter (game_for_uri);
		var factory = new GenericUriGameFactory (game_uri_adapter);
		factory.add_mime_type (CUE_MIME_TYPE);
		factory.add_mime_type (MEGA_CD_MIME_TYPE);

		return { factory };
	}

	private static Game game_for_uri (Uri uri) throws Error {
		var file = uri.to_file ();
		var file_info = file.query_info (FileAttribute.STANDARD_CONTENT_TYPE, FileQueryInfoFlags.NONE);
		var mime_type = file_info.get_content_type ();

		File bin_file;
		switch (mime_type) {
		case CUE_MIME_TYPE:
			var cue = new CueSheet (file);
			bin_file = get_binary_file (cue);

			break;
		case MEGA_CD_MIME_TYPE:
			bin_file = file;

			break;
		default:
			throw new MegaDriveError.INVALID_FILE_TYPE ("Invalid file type: expected %s or %s but got %s for file %s.", CUE_MIME_TYPE, MEGA_CD_MIME_TYPE, mime_type, uri.to_string ());
		}

		var header = new MegaDriveHeader (bin_file);
		header.check_validity ();

		string[] mime_types;
		string platform;
		if (header.is_mega_drive ()) {
			mime_types = { CUE_MIME_TYPE, MEGA_CD_MIME_TYPE };
			platform = MEGA_CD_PLATFORM;
		}
		else if (header.is_32x ()) {
			mime_types = { CUE_MIME_TYPE, MEGA_CD_MIME_TYPE, 32X_MIME_TYPE };
			platform = MEGA_CD_32X_PLATFORM;
		}
		else
			assert_not_reached ();

		var bin_uri = new Uri (bin_file.get_uri ());
		var header_offset = header.get_offset ();
		var uid = new FingerprintUid.for_chunk (bin_uri, MEGA_CD_PREFIX, header_offset, MegaDriveHeader.HEADER_LENGTH);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, MEGA_CD_MIME_TYPE);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var core_source = new RetroCoreSource (platform, mime_types);
		var runner = new RetroRunner (core_source, uri, uid, title);

		return new GenericGame (title, icon, cover, runner);
	}

	private static File get_binary_file (CueSheet cue) throws Error {
		if (cue.tracks_number == 0)
			throw new MegaDriveError.INVALID_CUE_SHEET (_("The file “%s” doesn’t have a track."), cue.file.get_uri ());

		var track = cue.get_track (0);
		var file = track.file;

		if (file.file_format != CueSheetFileFormat.BINARY && file.file_format != CueSheetFileFormat.UNKNOWN)
			throw new MegaDriveError.INVALID_CUE_SHEET (_("The file “%s” doesn’t have a valid binary file format."), cue.file.get_uri ());

		if (!track.track_mode.is_mode1 ())
			throw new MegaDriveError.INVALID_CUE_SHEET (_("The file “%s” doesn’t have a valid track mode for track %d."), cue.file.get_uri (), track.track_number);

		var header = new MegaDriveHeader (file.file);
		header.check_validity ();

		return file.file;
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.MegaDrivePlugin);
}
