// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GameinfoDiscIdDiscTitle : Object, Title {
	private GameinfoDoc gameinfo;
	private string disc_id;
	private string? domain;
	private string title;

	public GameinfoDiscIdDiscTitle (GameinfoDoc gameinfo, string disc_id, string? domain = null) {
		this.gameinfo = gameinfo;
		this.disc_id = disc_id;
		this.domain = domain;
	}

	public string get_title () throws Error {
		if (title != null)
			return dgettext (domain, title);

		try {
			title = gameinfo.get_disc_title_for_disc_id (disc_id);
		}
		catch (Error e) {
			var index = gameinfo.get_disc_set_index_for_disc_id (disc_id);
			title = _("Disc %d").printf (index + 1);
		}

		return dgettext (domain, title);
	}
}
