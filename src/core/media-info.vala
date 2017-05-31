// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.MediaInfo : Object {
	public string platform { get; private set; }
	public string game_id { get; private set; }
	public string? media_id { get; private set; }
	public uint media_index { get; private set; }

	public MediaInfo (string platform, string game_id, string? media_id, uint media_index) {
		this.platform = platform;
		this.game_id = game_id;
		this.media_id = media_id;
		this.media_index = media_index;
	}

	public static uint game_hash (MediaInfo media_info) {
		return str_hash (media_info.platform) +
		       str_hash (media_info.game_id);
	}

	public static bool game_equal (MediaInfo a, MediaInfo b) {
		return str_equal (a.platform, b.platform) &
		       str_equal (a.game_id, b.game_id);
	}

	public static uint media_hash (MediaInfo media_info) {
		return str_hash (media_info.platform) +
		       str_hash (media_info.game_id) +
		       str_hash (media_info.media_id);
	}

	public static bool media_equal (MediaInfo a, MediaInfo b) {
		return str_equal (a.platform, b.platform) &
		       str_equal (a.game_id, b.game_id) &
		       str_equal (a.media_id, b.media_id);
	}

	public string to_string () {
		return media_id == null ?
			@"urn:gnome:Games:$platform:$game_id:" :
			@"urn:gnome:Games:$platform:$game_id:$media_id";
	}
}
