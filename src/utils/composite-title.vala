// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.CompositeTitle : Object, Title {
	private Title[] titles;

	public CompositeTitle (Title[] titles) ensures (titles.length > 0) {
		this.titles = titles;
	}

	public string get_title () throws Error {
		Error last_error = null;

		foreach (var title in titles) {
			try {
				return title.get_title ();
			}
			catch (Error e) {
				last_error = e;
			}
		}

		throw last_error;
	}
}
