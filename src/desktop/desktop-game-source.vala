public class Games.DesktopGameSource : Games.GameSource, Object {

    private Tracker.Sparql.Connection tracker;

    private const string GAMES_QUERY = """
        SELECT ?software
        WHERE {
            ?software nie:isLogicalPartOf 'urn:software-category:Game' .
        }
    """;

    public DesktopGameSource (Tracker.Sparql.Connection tracker) {
        this.tracker = tracker;
    }

    public void each_game (GameSource.GameCallback callback) {
        var cursor = this.tracker.query (GAMES_QUERY);

        while (cursor.next ()) {
            var filename = GLib.Filename.from_uri (cursor.get_string (0));
            var entry = new DesktopAppInfo.from_filename (filename);

            callback (new Game (
            	entry.get_name (),
            	entry.get_icon ()
            ));
        }
    }
}

