// This file is part of GNOME Games. License: GPLv3

private class Games.RetroLog: Object, Retro.Log {
	public bool log (Retro.LogLevel level, string message) {
		switch (level) {
		case Retro.LogLevel.DEBUG:
			GLib.debug (message);

			break;
		case Retro.LogLevel.INFO:
			GLib.info (message);

			break;
		case Retro.LogLevel.WARN:
			GLib.warning (message);

			break;
		case Retro.LogLevel.ERROR:
			GLib.critical (message);

			break;
		default:
			return false;
		}

		return true;
	}
}
