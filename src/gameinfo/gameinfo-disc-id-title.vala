// This file is part of GNOME Games. License: GPLv3

public class Games.GameinfoDiscIdTitle : Object, Title {
	private GameinfoDoc gameinfo;
	private string disc_id;
	private string? domain;
	private string title;

	public GameinfoDiscIdTitle (GameinfoDoc gameinfo, string disc_id, string? domain = null) {
		this.gameinfo = gameinfo;
		this.disc_id = disc_id;
		this.domain = domain;
	}

	public string get_title () throws Error {
		if (title != null)
			return dgettext (domain, title);

		title = gameinfo.get_game_title_for_disc_id (disc_id);
		if (gameinfo.get_disc_set_size_for_disc_id (disc_id) > 1) {
			var index = gameinfo.get_disc_set_index_for_disc_id (disc_id);
			title += " — ";
			title += _("Disc %d").printf (index + 1);
		}

		return dgettext (domain, title);
	}
}
