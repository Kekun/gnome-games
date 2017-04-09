// This file is part of GNOME Games. License: GPL-3.0+.

namespace Games.RetroPlatform {
	private string? get_platform_name (string platform) {
		switch (platform) {
		case "Amiga":
			return _("Amiga");
		case "Atari2600":
			return _("Atari 2600");
		case "Atari5200":
			return _("Atari 5200");
		case "Atari7800":
			return _("Atari 7800");
		case "DOOM":
			return _("DOOM");
		case "Dreamcast":
			return _("Dreamcast");
		case "FamicomDiskSystem":
			/* translators: only released in eastern Asia */
			return _("Famicom Disk System");
		case "GameBoy":
			return _("Game Boy");
		case "GameBoyColor":
			return _("Game Boy Color");
		case "GameBoyAdvance":
			return _("Game Boy Advance");
		case "GameCube":
			return _("Nintendo GameCube");
		case "GameGear":
			return _("Game Gear");
		case "MAME":
			/* translators: the "Multiple Arcade Machine Emulator" */
			return _("MAME");
		case "NeoGeoPocket":
			return _("Neo Geo Pocket");
		case "NintendoEntertainmentSystem":
			/* translators: known as "Famicom" in eastern Asia */
			return _("Nintendo Entertainment System");
		case "Nintendo64":
			return _("Nintendo 64");
		case "NintendoDS":
			return _("Nintendo DS");
		case "Nintendo3DS":
			return _("Nintendo 3DS");
		case "PlayStation":
			return _("PlayStation");
		case "PlayStation2":
			return _("PlayStation 2");
		case "PlayStation3":
			return _("PlayStation 3");
		case "PlayStation4":
			return _("PlayStation 4");
		case "PlayStationPortable":
			return _("PlayStation Portable");
		case "PlayStationVita":
			return _("PlayStation Vita");
		case "Sega32X":
			/* translators: known as "Mega Drive 32X", "Mega 32X" or "Super 32X" in other places */
			return _("Genesis 32X");
		case "SegaCD":
			/* translators: known as "Mega-CD" in most of the world */
			return _("Sega CD");
		case "SegaCD32X":
			/* translators: known as "Mega-CD 32X" in most of the world */
			return _("Sega CD 32X");
		case "SegaGenesis":
			/* translators: known as "Mega Drive" in most of the world */
			return _("Sega Genesis");
		case "SegaMasterSystem":
			/* translators: also known as "Sega Mark III" in eastern asia */
			return _("Sega Master System");
		case "SegaPico":
			return _("Sega Pico");
		case "SegaSaturn":
			return _("Sega Saturn");
		case "SG1000":
			return _("SG-1000");
		case "SuperNintendoEntertainmentSystem":
			/* translators: known as "Super Famicom" in eastern Asia */
			return _("Super Nintendo Entertainment System");
		case "TurboGrafx16":
			/* translators: known as "PC Engine" in eastern Asia and France */
			return _("TurboGrafx-16");
		case "TurboGrafxCD":
			/* translators: known as "CD-ROM²" in eastern Asia and France */
			return _("TurboGrafx-CD");
		case "Wii":
			return _("Wii");
		case "WiiU":
			return _("Wii U");
		case "WiiWare":
			return _("WiiWare");
		default:
			return null;
		}
	}
}
