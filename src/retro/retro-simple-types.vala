// This file is part of GNOME Games. License: GPL-3.0+.

namespace Games {
	private const RetroSimpleType[] RETRO_SIMPLE_TYPES = {
		{ "application/vnd.nintendo.snes.rom", true, "SuperNintendoEntertainmentSystem", "snes" },
		{ "application/x-amiga-disk-format", true, "Amiga", "amiga" },
		{ "application/x-atari-2600-rom", true, "Atari2600", "atari-2600" },
		{ "application/x-atari-7800-rom", true, "Atari7800", "atari-7800" },
		{ "application/x-atari-lynx-rom", true, "AtariLynx", "atari-lynx" },
		{ "application/x-doom-wad", true, "DOOM", "doom" },
		{ "application/x-fds-disk", true, "FamicomDiskSystem", "fds" },
		{ "application/x-gameboy-color-rom", true, "GameBoyColor", "game-boy" }, // The prefix is the same as the Game Boy type for backward compatibility.
		{ "application/x-gameboy-rom", true, "GameBoy", "game-boy" },
		{ "application/x-gamegear-rom", true, "GameGear", "game-gear" },
		{ "application/x-gba-rom", true, "GameBoyAdvance", "game-boy-advance" },
		{ "application/x-genesis-32x-rom", true, "Sega32X", "mega-drive-32x" },
		{ "application/x-genesis-rom", true, "SegaGenesis", "mega-drive" },
		{ "application/x-ms-dos-executable", false, "MSDOS", "ms-dos" },
		{ "application/x-n64-rom", true, "Nintendo64", "nintendo-64" },
		{ "application/x-neo-geo-pocket-rom", true, "NeoGeoPocket", "neo-geo-pocket" },
		{ "application/x-nes-rom", true, "NintendoEntertainmentSystem", "nes" },
		{ "application/x-pc-engine-rom", true, "TurboGrafx16", "pc-engine" },
		{ "application/x-sega-pico-rom", true, "SegaPico", "sega-pico" },
		{ "application/x-sg1000-rom", true, "SG1000", "sg-1000" },
		{ "application/x-sms-rom", true, "MasterSystem", "master-system" },
		{ "application/x-wii-wad", true, "WiiWare", "wii-ware" },
		{ "application/x-wonderswan-rom", true, "WonderSwan", "wonderswan" },
		{ "application/x-wonderswan-color-rom", true, "WonderSwanColor", "wonderswan-color" },
	};
}
