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
}
