// This file is part of GNOME Games. License: GPL-3.0+.

private struct Games.GamepadInputPath {
	GamepadInput input;
	string path;
}

private struct Games.GamepadViewConfiguration {
	string svg_path;
	GamepadInputPath[] input_paths;
}
