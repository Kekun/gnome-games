public void test_game(TestSuite root) {
    var suite = new TestSuite("Game");

    Game? game = new Game("Sudoku");

    suite.add(new GLib.TestCase("name",
        () => {},
        () => {
            assert(game.name == "Sudoku");
        },
        () => {}
    ));

    root.add_suite(suite);
}

