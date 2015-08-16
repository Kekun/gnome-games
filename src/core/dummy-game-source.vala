public class Games.DummyGameSource : Object {
	public delegate void GameCallback (Game game);

	public void each_game (GameCallback callback) {
		callback (new DummyGame ("Mines"));
		callback (new DummyGame ("Sudoku"));
	}
}
