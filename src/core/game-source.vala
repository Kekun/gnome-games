// This file is part of GNOME Games. License: GPLv3

private interface Games.GameSource : Object {
	public abstract async void each_game (GameCallback callback);
}

private delegate void Games.GameCallback (Game game);
