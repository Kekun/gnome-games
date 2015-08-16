// This file is part of GNOME Games. License: GPLv3

private class Games.DummyGameSource : Object, GameSource {
	public void each_game (GameCallback callback) {
		callback (new DummyGame ("Mines"));
		callback (new DummyGame ("Sudoku"));
	}
}
