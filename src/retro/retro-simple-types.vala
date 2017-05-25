// This file is part of GNOME Games. License: GPL-3.0+.

namespace Games {
	private const RetroSimpleType[] RETRO_SIMPLE_TYPES = {
		{ "application/x-amiga-disk-format", true, "Amiga", "amiga" },
		{ "application/x-atari-2600-rom", true, "Atari2600", "atari-2600" },
		{ "application/x-atari-7800-rom", true, "Atari7800", "atari-7800" },
		{ "application/x-atari-lynx-rom", true, "AtariLynx", "atari-lynx" },
		{ "application/x-doom-wad", true, "DOOM", "doom" },
		{ "application/x-gameboy-color-rom", true, "GameBoyColor", "game-boy" }, // The prefix is the same as the Game Boy type for backward compatibility.
		{ "application/x-gameboy-rom", true, "GameBoy", "game-boy" },
		{ "application/x-gamegear-rom", true, "GameGear", "game-gear" },
		{ "application/x-gba-rom", true, "GameBoyAdvance", "game-boy-advance" },
		{ "application/x-sg1000-rom", true, "SG1000", "sg-1000" },
		{ "application/x-sms-rom", true, "MasterSystem", "master-system" },
	};
}
