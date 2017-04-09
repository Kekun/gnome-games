// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GameinfoDiscIdInputCapabilities : Object, InputCapabilities {
	public bool default_allow_classic_gamepads { set; get; }
	public bool default_allow_analog_gamepads { set; get; }

	private GameinfoDoc gameinfo;
	private string disc_id;
	private string[] controllers;

	public GameinfoDiscIdInputCapabilities (GameinfoDoc gameinfo, string disc_id) {
		this.gameinfo = gameinfo;
		this.disc_id = disc_id;
	}

	public bool get_allow_classic_gamepads () throws Error {
		if (controllers == null)
			controllers = gameinfo.get_game_controllers_for_disc_id (disc_id);

		if (controllers.length == 0)
			return default_allow_classic_gamepads;

		return "classic-gamepad" in controllers;
	}

	public bool get_allow_analog_gamepads () throws Error {
		if (controllers == null)
			controllers = gameinfo.get_game_controllers_for_disc_id (disc_id);

		if (controllers.length == 0)
			return default_allow_analog_gamepads;

		return "analog-gamepad" in controllers;
	}
}
