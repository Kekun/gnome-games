void main(string[] args) {
    Test.init(ref args);
    var root = TestSuite.get_root();

    test_game(root);

    Test.run();
}

