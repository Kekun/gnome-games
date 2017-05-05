public interface Games.UriGameFactory : Object {
	public abstract string[] get_mime_types ();
	public abstract async void add_uri (string uri);
	public abstract async void foreach_game (Games.GameCallback game_callback);
}
