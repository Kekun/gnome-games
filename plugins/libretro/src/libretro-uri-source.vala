// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.LibretroUriSource : Object, UriSource {
	public UriIterator iterator () {
		return new LibretroUriIterator ();
	}
}
