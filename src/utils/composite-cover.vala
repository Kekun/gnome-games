// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.CompositeCover : Object, Cover {
	private Cover[] covers;

	public CompositeCover (Cover[] covers) {
		this.covers = covers;
		foreach (var cover in covers)
			cover.changed.connect (on_cover_changed);
	}

	public GLib.Icon? get_cover () {
		foreach (var cover in covers) {
			var result_cover = cover.get_cover ();
			if (result_cover != null)
				return result_cover;
		}

		return null;
	}

	private void on_cover_changed () {
		changed ();
	}
}
