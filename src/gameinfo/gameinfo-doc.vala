// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GameinfoDoc : Object {
	private XmlDoc xml_doc;

	public GameinfoDoc.from_data (uint8[] data) throws Error {
		xml_doc = new XmlDoc.from_data (data);
	}

	public string? get_game_title_for_disc_id (string disc_id) throws Error {
		var expr = "/gameinfo/games/game[discs/disc[@id = \"" + disc_id + "\"]]/title";

		var title = xml_doc.get_content (expr);
		if (title == null)
			throw new GameinfoError.DISC_NOT_FOUND (_("No game title found for disc ID “%s”."), disc_id);

		return title;
	}

	public string[] get_game_controllers_for_disc_id (string disc_id) throws Error {
		var expr = "/gameinfo/games/game[discs/disc[@id = \"" + disc_id + "\"]]/controllers/controller/@type";

		return xml_doc.get_contents (expr);
	}

	public string? get_disc_title_for_disc_id (string disc_id) throws Error {
		var expr = "/gameinfo/games/game/discs/disc[@id = \"" + disc_id + "\"]/title";

		var title = xml_doc.get_content (expr);
		if (title == null)
			throw new GameinfoError.DISC_NOT_FOUND (_("No disc title found for disc ID “%s”."), disc_id);

		return title;
	}

	public string? get_disc_set_id_for_disc_id (string disc_id) throws Error {
		var expr = "/gameinfo/games/game/discs[disc[@id = \"" + disc_id + "\"]]/disc[1]/@id";

		var title = xml_doc.get_content (expr);
		if (title == null)
			throw new GameinfoError.DISC_NOT_FOUND (_("No disc set ID found for disc ID “%s”."), disc_id);

		return title;
	}

	public int get_disc_set_index_for_disc_id (string disc_id) throws Error {
		var test_expr = "/gameinfo/games/game/discs/disc[@id = \"" + disc_id + "\"]";
		if (xml_doc.count_nodes (test_expr) == 0)
			throw new GameinfoError.DISC_NOT_FOUND (_("No disc found for disc ID “%s”."), disc_id);

		var expr = "/gameinfo/games/game/discs/disc[@id = \"" + disc_id + "\"]/preceding-sibling::disc";

		return xml_doc.count_nodes (expr);
	}

	public int get_disc_set_size_for_disc_id (string disc_id) throws Error {
		var test_expr = "/gameinfo/games/game/discs/disc[@id = \"" + disc_id + "\"]";
		if (xml_doc.count_nodes (test_expr) == 0)
			throw new GameinfoError.DISC_NOT_FOUND (_("No disc found for disc ID “%s”."), disc_id);

		var expr = "/gameinfo/games/game/discs[disc[@id = \"" + disc_id + "\"]]/disc";

		return xml_doc.count_nodes (expr);
	}
}
