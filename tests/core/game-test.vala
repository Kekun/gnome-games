public class GameTest : Games.TestCase {

	public GameTest () {
		base ("Game");

		add_test ("name", test_name);
		add_test ("icon", test_icon);
	}

	private Game game;

	public override void set_up () {
		game = new Game ("Sudoku", null);
	}

	public void test_name () {
		assert (game.name == "Sudoku");
	}

	public void test_icon () {
		assert (game.icon == null);
	}
}

