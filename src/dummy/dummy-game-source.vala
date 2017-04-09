// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DummyGameSource : Object, GameSource {
	public async void each_game (GameCallback callback) {
		callback (new DummyGame ("Mines"));
		callback (new DummyGame ("Sudoku"));
	}
}
