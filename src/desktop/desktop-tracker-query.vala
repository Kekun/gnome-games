// This file is part of GNOME Games. License: GPLv3

private class Games.DesktopTrackerQuery : Object, TrackerQuery {
	private static const string[] CATEGORIES_BLACK_LIST = {
		"Application",
		"Emulator",
		"Development",
	};

	private static const string[] BASE_NAME_BLACK_LIST = {
		"bsnes.desktop",
		"fakenes.desktop",
		"chocolate-doom.desktop",
		"chocolate-heretic.desktop",
		"chocolate-hexen.desktop",
		"chocolate-setup.desktop",
		"chocolate-strife.desktop",
		"cutemupen.desktop",
		"desmume.desktop",
		"desmume-glade.desktop",
		"dolphin-emu.desktop",
		"doomsday.desktop",
		"dosbox.desktop",
		"dosemu.desktop",
		"dribble-fakenes.desktop",
		"dribble-Frodo.desktop",
		"dribble-FrodoPC.desktop",
		"dribble-FrodoSC.desktop",
		"fceux.desktop",
		"fs-uae.desktop",
		"fs-uae-arcade.desktop",
		"fs-uae-launcher.desktop",
		"gambatte-qt.desktop",
		"gfceu.desktop",
		"gnome-video-arcade.desktop",
		"gvbam.desktop",
		"hatariui.desktop",
		"higan.desktop",
		"love.desktop",
		"lutris.desktop",
		"lxdream.desktop",
		"mame.desktop",
		"mednafen.desktop",
		"meka.desktop",
		"mess.desktop",
		"mess-dc.desktop",
		"mess-gameboy.desktop",
		"mess-gba.desktop",
		"mess-genesis.desktop",
		"mess-msx.desktop",
		"mess-n64.desktop",
		"mess-nes.desktop",
		"mess-sms.desktop",
		"mess-snes.desktop",
		"nestopia.desktop",
		"org.gnome.Games.desktop",
		"osmose.desktop",
		"p4makecfg.desktop",
		"p4fliconv.desktop",
		"pcsx.desktop",
		"pcsx2.desktop",
		"plus4emu.desktop",
		"ppsspp-qt.desktop",
		"ppsspp-sdl.desktop",
		"prboom-plus.desktop",
		"reminiscence.desktop",
		"rpmfusion-bsnes.desktop",
		"scummvm.desktop",
		"snes9x.desktop",
		"stella.desktop",
		"steam.desktop",
		"vbaexpress.desktop",
		"VisualBoyAdvance.desktop",
		"wolf4sdl.desktop", // ???
		"x64.desktop",
		"x128.desktop",
		"xcmb2.desktop",
		"xpet.desktop",
		"xplus4.desktop",
		"xvic.desktop",
		"yabause.desktop",
		"yabause-gtk.desktop",
		"yabause-qt.desktop",
		"zsnes.desktop",
	};

	public string get_query () {
		return "SELECT ?soft WHERE { ?soft nie:isLogicalPartOf 'urn:software-category:Game' . }";
	}

	public Game game_for_cursor (Tracker.Sparql.Cursor cursor) throws Error {
		var uri = cursor.get_string (0);
		var file = File.new_for_uri (uri);

		var path = file.get_path ();
		var app_info = new DesktopAppInfo.from_filename (path);

		check_categories (app_info);
		check_base_name (file);

		return new DesktopGame (uri);
	}

	private void check_categories (DesktopAppInfo app_info) throws Error {
		var categories_string = app_info.get_categories ();
		var categories = categories_string.split (";");

		foreach (var category in CATEGORIES_BLACK_LIST)
			if (category in categories)
				throw new TrackerError.GAME_IS_BLACKLISTED (@"'$(app_info.filename)' has blacklisted category '$category'.");
	}

	private void check_base_name (File file) throws Error {
		var base_name = file.get_basename ();

		if (base_name in BASE_NAME_BLACK_LIST)
			throw new TrackerError.GAME_IS_BLACKLISTED (@"'$(file.get_path ())' is blacklisted.");
	}
}
