public interface Games.GameSource : Object {

    public delegate void GameCallback (Game game);

    public abstract void each_game (GameCallback callback);
}

