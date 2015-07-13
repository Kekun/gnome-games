public class Games.DummyGameSource : Object {
	public delegate void GameCallback (Game game);

	public void each_game (GameCallback callback) {
		callback (new Games.Game ("Mines"));
		callback (new Games.Game ("Sudoku"));
	}
}
