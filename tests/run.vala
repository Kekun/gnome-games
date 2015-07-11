void main (string[] args) {
	Test.init (ref args);
	root = TestSuite.get_root ();
	root.add_suite (new GameTest ().get_suite ());
	Test.run ();
}
