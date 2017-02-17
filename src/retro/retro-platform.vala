// This file is part of GNOME Games. License: GPLv3

namespace Games.RetroPlatform {
	private string? get_platform_name (string platform) {
		switch (platform) {
		case "Atari2600":
			return _("Atari 2600");
		case "Atari5200":
			return _("Atari 5200");
		case "Atari7800":
			return _("Atari 7800");
		case "Dreamcast":
			return _("Dreamcast");
		case "FamicomDiskSystem":
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
		case "NintendoEntertainmentSystem":
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
			return _("Genesis 32X");
		case "SegaCD":
			return _("Sega CD");
		case "SegaCD32X":
			return _("Sega CD 32X");
		case "SegaGenesis":
			return _("Sega Genesis");
		case "SegaMasterSystem":
			return _("Sega Master System");
		case "SegaSaturn":
			return _("Sega Saturn");
		case "SG1000":
			return _("SG-1000");
		case "SuperNintendoEntertainmentSystem":
			return _("Super Nintendo Entertainment System");
		case "TurboGrafx16":
			return _("TurboGrafx-16");
		case "TurboGrafxCD":
			return _("TurboGrafx-CD");
		case "Wii":
			return _("Wii");
		case "WiiU":
			return _("Wii U");
		default:
			return null;
		}
	}
}
