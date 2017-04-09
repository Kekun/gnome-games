// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.Media : Object {
	public Title? title { get; construct; }
	public string uri { get; construct; }

	public Media (string uri, Title? title = null) {
		Object (title: title, uri: uri);
	}
}
