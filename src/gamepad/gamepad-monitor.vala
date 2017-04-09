// This file is part of GNOME Games. License: GPL-3.0+.

/**
 * This class provides a way to the client to monitor gamepads
 *
 * The client interfaces with this class primarily
 */
private class Games.GamepadMonitor : Object {
	/**
	 * Emitted when a gamepad is plugged in.
	 * This would be emitted once even if RawGamepadMonitor emits it multiple
	 * times
	 * @param  gamepad    The gamepad
	 */
	public signal void gamepad_plugged (Gamepad gamepad);

	private static GamepadMonitor instance;

	private GenericSet<Gamepad?> gamepads;

	private GamepadMonitor () {
		gamepads = new GenericSet<Gamepad?> (direct_hash, direct_equal);
#if ENABLE_LINUX_GAMEPADS
		var raw_gamepad_monitor = LinuxRawGamepadMonitor.get_instance ();
		raw_gamepad_monitor.gamepad_plugged.connect (on_raw_gamepad_plugged);
		raw_gamepad_monitor.foreach_gamepad ((raw_gamepad) => add_gamepad (raw_gamepad));
#endif
	}

	public static GamepadMonitor get_instance () {
		if (instance == null)
			instance = new GamepadMonitor ();

		return instance;
	}

	public void foreach_gamepad (GamepadCallback callback) {
		foreach (var gamepad in gamepads)
			callback (gamepad);
	}

	private Gamepad? add_gamepad (RawGamepad raw_gamepad) {
		Gamepad gamepad;
		try {
			gamepad = new Gamepad (raw_gamepad);
		}
		catch (GamepadMappingError e) {
			return null;
		}

		gamepads.add (gamepad);
		gamepad.unplugged.connect (remove_gamepad);

		return gamepad;
	}

	private void on_raw_gamepad_plugged (RawGamepad raw_gamepad) {
		var gamepad = add_gamepad (raw_gamepad);

		// To emit only once even if RawGamepadMonitor emits it multiple times
		if (gamepad != null)
			gamepad_plugged (gamepad);
	}

	private void remove_gamepad (Gamepad gamepad) {
		gamepads.remove (gamepad);
	}
}
