// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GameinfoDiscIdGameTitle : Object, Title {
	private GameinfoDoc gameinfo;
	private string disc_id;
	private string? domain;
	private string title;

	public GameinfoDiscIdGameTitle (GameinfoDoc gameinfo, string disc_id, string? domain = null) {
		this.gameinfo = gameinfo;
		this.disc_id = disc_id;
		this.domain = domain;
	}

	public string get_title () throws Error {
		if (title != null)
			return dgettext (domain, title);

		title = gameinfo.get_game_title_for_disc_id (disc_id);

		return dgettext (domain, title);
	}
}
