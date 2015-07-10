public class Games.Game : Object {

    public string name { get; construct; }
    public Icon icon { get; construct; }

    public Game (string name, Icon icon) {
        Object (name: name, icon: icon);
    }
}

