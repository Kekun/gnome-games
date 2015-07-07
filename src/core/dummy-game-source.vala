public class Games.DummyGameSource: Games.GameSource, Object {

    public void each_game(GameSource.GameCallback callback) {
        callback(new Games.Game("Mines"));
        callback(new Games.Game("Sudoku"));
    }
}

