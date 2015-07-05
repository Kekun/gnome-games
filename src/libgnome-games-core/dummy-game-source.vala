public class DummyGameSource: Object {

    public delegate void GameCallback(Game game);

    public void each_game(GameCallback callback) {
        callback(new Game("Mines"));
        callback(new Game("Sudoku"));
    }
}

