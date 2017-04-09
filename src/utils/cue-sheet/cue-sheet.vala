// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.CueSheet : Object {
	private const string NEW_LINE = "\n";

	private File _file;
	public File file {
		get { return _file; }
	}

	public uint tracks_number {
		get { return tracks.length; }
	}

	private CueSheetTrackNode[] tracks;

	public CueSheet (File file) throws Error {
		_file = file;

		parse ();
	}

	public CueSheetTrackNode get_track (uint i) throws Error {
		if (i >= tracks.length)
			throw new CueSheetError.NOT_A_TRACK (_("“%s” doesn’t have a track for index %u."), file.get_uri (), i);

		return tracks[i];
	}

	private string[] tokenize () throws Error {
		var stream = file.read ();
		var data_stream = new DataInputStream (stream);

		string[] tokens = {};

		string? line;
		while ((line = data_stream.read_line ()) != null)
			foreach (var token in tokenize_line (line))
				tokens += token;

		return tokens;
	}

	private static Regex token_regex;
	private static string[] tokenize_line (string line) {
		if (token_regex == null)
			// Matches words or "double quoted strings" (no escaping).
			token_regex = /\s*([^"\s]+)|(".+?")\s*/;

		string[] tokens = {};
		foreach (var token in token_regex.split (line))
			switch (token) {
			case "\r":
			case "\r\n":
				tokens += NEW_LINE;

				break;
			case "":
			case " ":
				break;
			default:
				tokens += token;

				break;
			}

		// Makes sure the token set ends by a new line.
		if (tokens.length != 0 && tokens[tokens.length - 1] != NEW_LINE)
			tokens += NEW_LINE;

		return tokens;
	}

	private void parse () throws Error {
		var tokens = tokenize ();

		CueSheetFileNode? latest_file = null;

		size_t line = 1;
		for (size_t i = 0 ; i < tokens.length ; line++)
			// Each case must consume the line completely.
			switch (tokens[i]) {
			case "FILE":
				latest_file = parse_file_line (ref tokens, ref i, line);

				break;
			case "TRACK":
				tracks += parse_track_line (ref tokens, ref i, line, latest_file);

				break;
			default:
				// Skip the line.
				while (i < tokens.length && tokens[i] != NEW_LINE)
					i++;
				i++;

				break;
			}
	}

	private CueSheetFileNode parse_file_line (ref string[] tokens, ref size_t i, size_t line) throws CueSheetError {
		is_token ("FILE", ref tokens, ref i, line);
		var file_name = get_token (ref tokens, ref i, line);
		var file_format_string = get_optional_token (ref tokens, ref i, line);
		is_end_of_line 	(ref tokens, ref i, line);

		if (file_name.has_prefix ("\"") && file_name.has_suffix ("\"") && file_name.length > 1)
			file_name = file_name[1: file_name.length - 1];
		var dir = file.get_parent ();
		var child_file = dir.get_child (file_name);

		var file_format = CueSheetFileFormat.parse_string (file_format_string);
		if (file_format == CueSheetFileFormat.INVALID)
			throw new CueSheetError.INVALID_FILE_FORMAT (_("%s:%lu: Invalid file format %s, expected a valid file format or none."), file.get_basename (), line, file_format_string);

		return new CueSheetFileNode (child_file, file_format);
	}

	private CueSheetTrackNode parse_track_line (ref string[] tokens, ref size_t i, size_t line, CueSheetFileNode? parent_file) throws CueSheetError {
		if (parent_file == null)
			throw new CueSheetError.UNEXPECTED_TOKEN (_("%s:%lu: Unexpected token TRACK before a FILE token."), file.get_basename (), line);

		is_token ("TRACK", ref tokens, ref i, line);
		var track_number_string = get_token (ref tokens, ref i, line);
		var track_mode_string = get_token (ref tokens, ref i, line);
		is_end_of_line 	(ref tokens, ref i, line);

		var track_number = int.parse (track_number_string);
		if (track_number < 1 || track_number > 99)
			throw new CueSheetError.INVALID_TRACK_NUMBER (_("%s:%lu: Invalid track number %s, expected a number in the 1-99 range."), file.get_basename (), line, track_number_string);

		var track_mode = CueSheetTrackMode.parse_string (track_mode_string);
		if (track_mode == CueSheetTrackMode.INVALID)
			throw new CueSheetError.INVALID_TRACK_MODE (_("%s:%lu: Invalid track mode %s, expected a valid track mode."), file.get_basename (), line, track_mode_string);

		return new CueSheetTrackNode (parent_file, track_number, track_mode);
	}

	private void is_token (string expected_token, ref string[] tokens, ref size_t i, size_t line) throws CueSheetError {
		if (i >= tokens.length)
			throw new CueSheetError.UNEXPECTED_EOF (_("%s:%lu: Unexpected end of file, expected %s."), file.get_basename (), line, expected_token);

		if (tokens[i] == NEW_LINE)
			throw new CueSheetError.UNEXPECTED_TOKEN (_("%s:%lu: Unexpected token %s, expected %s."), file.get_basename (), line, tokens[i], expected_token);

		i++;
	}

	private string get_token (ref string[] tokens, ref size_t i, size_t line) throws CueSheetError {
		if (i >= tokens.length)
			throw new CueSheetError.UNEXPECTED_EOF (_("%s:%lu: Unexpected end of file, expected a token."), file.get_basename (), line);

		if (tokens[i] == NEW_LINE)
			throw new CueSheetError.UNEXPECTED_EOL (_("%s:%lu: Unexpected end of line, expected a token."), file.get_basename (), line);

		var token = tokens[i];
		i++;

		return token;
	}

	private string? get_optional_token (ref string[] tokens, ref size_t i, size_t line) {
		if (i >= tokens.length)
			return null;

		if (tokens[i] == NEW_LINE)
			return null;

		var token = tokens[i];
		i++;

		return token;
	}

	private void is_end_of_line (ref string[] tokens, ref size_t i, size_t line) throws CueSheetError {
		if (i < tokens.length && tokens[i] != NEW_LINE)
			throw new CueSheetError.UNEXPECTED_TOKEN (_("%s:%lu: Unexpected token %s, expected end of line."), file.get_basename (), line, tokens[i]);

		i++;
	}
}
