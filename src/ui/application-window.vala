// This file is part of GNOME Games. License: GPLv3

[GtkTemplate (ui = "/org/gnome/Games/ui/application-window.ui")]
private class Games.ApplicationWindow : Gtk.ApplicationWindow {
	private UiState _ui_state;
	public UiState ui_state {
		set {
			if (value == ui_state)
				return;

			_ui_state = value;

			switch (ui_state) {
			case UiState.COLLECTION:
				content_box.set_visible_child (collection_box);
				header_bar.set_visible_child (collection_header_bar);

				is_fullscreen = false;

				if (display_box.runner != null) {
					display_box.runner.stop ();
					display_box.runner = null;
				}

				break;
			case UiState.DISPLAY:
				content_box.set_visible_child (display_box);
				header_bar.set_visible_child (display_header_bar);

				search_mode = false;

				break;
			}
		}
		get { return _ui_state; }
	}

	private bool _is_fullscreen;
	public bool is_fullscreen {
		set {
			_is_fullscreen = value && (ui_state == UiState.DISPLAY);

			if (_is_fullscreen)
				fullscreen ();
			else
				unfullscreen ();
		}
		get { return _is_fullscreen; }
	}

	private bool _search_mode;
	public bool search_mode {
		set { _search_mode = value && (ui_state == UiState.COLLECTION); }
		get { return _search_mode; }
	}

	[GtkChild]
	private Gtk.Stack content_box;
	[GtkChild]
	private CollectionBox collection_box;
	[GtkChild]
	private DisplayBox display_box;

	[GtkChild]
	private Gtk.Stack header_bar;
	[GtkChild]
	private CollectionHeaderBar collection_header_bar;
	[GtkChild]
	private DisplayHeaderBar display_header_bar;

	private Binding box_search_binding;
	private Binding box_fullscreen_binding;
	private Binding header_bar_search_binding;
	private Binding header_bar_fullscreen_binding;

	private Cancellable run_game_cancellable;
	private Cancellable quit_game_cancellable;

	public ApplicationWindow (ListModel collection) {
		collection_box.collection = collection;
	}

	construct {
		box_search_binding = bind_property ("search-mode", collection_box, "search-mode",
		                                    BindingFlags.BIDIRECTIONAL);
		header_bar_search_binding = bind_property ("search-mode", collection_header_bar, "search-mode",
		                                           BindingFlags.BIDIRECTIONAL);

		box_fullscreen_binding = bind_property ("is-fullscreen", display_box, "is-fullscreen",
		                                        BindingFlags.BIDIRECTIONAL);
		header_bar_fullscreen_binding = bind_property ("is-fullscreen", display_header_bar, "is-fullscreen",
		                                               BindingFlags.BIDIRECTIONAL);
	}

	public void run_game (Game game) {
		if (run_game_cancellable != null)
			run_game_cancellable.cancel ();

		run_game_cancellable = new Cancellable ();

		run_game_with_cancellable (game, run_game_cancellable);
	}

	public bool quit_game () {
		// If the window have been deleted/hidden we probably don't want to
		// prompt the user.
		if (!visible)
			return true;

		if (run_game_cancellable != null)
			run_game_cancellable.cancel ();

		if (quit_game_cancellable != null)
			quit_game_cancellable.cancel ();

		quit_game_cancellable = new Cancellable ();

		return quit_game_with_cancellable (quit_game_cancellable);
	}

	[GtkCallback]
	public bool on_delete_event () {
		return !quit_game ();
	}

	[GtkCallback]
	public bool on_key_pressed (Gdk.EventKey event) {
		var default_modifiers = Gtk.accelerator_get_default_mod_mask ();

		if ((event.keyval == Gdk.Key.q || event.keyval == Gdk.Key.Q) &&
		    (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
			if (!quit_game ())
				return false;

			destroy ();

			return true;
		}

		if ((event.keyval == Gdk.Key.f || event.keyval == Gdk.Key.F) &&
		    (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
			if (!search_mode)
				search_mode = true;

			return true;
		}

		if (ui_state == UiState.COLLECTION && collection_box.search_bar_handle_event (event))
			return true;

		return false;
	}

	[GtkCallback]
	public bool on_window_state_event (Gdk.EventWindowState event) {
		is_fullscreen = (bool) (event.new_window_state & Gdk.WindowState.FULLSCREEN);

		return false;
	}

	[GtkCallback]
	private void on_game_activated (Game game) {
		run_game (game);
	}

	[GtkCallback]
	private void on_display_back () {
		if (quit_game ())
			ui_state = UiState.COLLECTION;
	}

	private void run_game_with_cancellable (Game game, Cancellable cancellable) {
		display_header_bar.game_title = game.name;
		display_box.header_bar.game_title = game.name;
		ui_state = UiState.DISPLAY;

		var runner = try_get_runner (game);
		if (runner == null)
			return;

		display_header_bar.can_fullscreen = runner.can_fullscreen;
		display_box.header_bar.can_fullscreen = runner.can_fullscreen;
		display_box.runner = runner;
		display_header_bar.media_set = runner.media_set;
		display_box.header_bar.media_set = runner.media_set;

		bool resume = false;
		if (runner.can_resume)
			resume = prompt_resume_with_cancellable (cancellable);

		if (!try_run_with_cancellable (runner, resume, cancellable))
			prompt_resume_fail_with_cancellable (runner, cancellable);
	}

	private Runner? try_get_runner (Game game) {
		try {
			var runner = game.get_runner ();
			runner.check_is_valid ();

			return runner;
		}
		catch (Error e) {
			warning ("%s\n", e.message);
			display_box.display_running_game_failed (e, game);

			return null;
		}
	}

	private bool prompt_resume_with_cancellable (Cancellable cancellable) {
		var dialog = new ResumeDialog ();
		dialog.set_transient_for (this);

		cancellable.cancelled.connect (() => {
			dialog.destroy ();
		});

		var response = dialog.run ();
		dialog.destroy ();

		if (cancellable.is_cancelled ())
			response = Gtk.ResponseType.CANCEL;

		if (response == Gtk.ResponseType.CANCEL)
			return false;

		return true;
	}

	private bool try_run_with_cancellable (Runner runner, bool resume, Cancellable cancellable) {
		try {
			if (resume)
				display_box.runner.resume ();
			else
				runner.start ();

			return true;
		}
		catch (Error e) {
			warning (e.message);

			return false;
		}
	}

	private void prompt_resume_fail_with_cancellable (Runner runner, Cancellable cancellable) {
		var dialog = new ResumeFailedDialog ();
		dialog.set_transient_for (this);

		cancellable.cancelled.connect (() => {
			dialog.destroy ();
		});

		var response = dialog.run ();
		dialog.destroy ();

		if (cancellable.is_cancelled ())
			response = Gtk.ResponseType.CANCEL;

		if (response == Gtk.ResponseType.CANCEL) {
			display_box.runner = null;
			ui_state = UiState.COLLECTION;

			return;
		}

		try {
			runner.start ();
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	public bool quit_game_with_cancellable (Cancellable cancellable) {
		if (display_box.runner == null)
			return true;

		display_box.runner.pause ();

		if (display_box.runner.can_quit_safely)
			return true;

		var dialog = new QuitDialog ();
		dialog.set_transient_for (this);

		cancellable.cancelled.connect (() => {
			dialog.destroy ();
		});

		var response = dialog.run ();
		dialog.destroy ();

		if (cancellable.is_cancelled ())
			return cancel_quitting_game ();

		if (response == Gtk.ResponseType.ACCEPT)
			return true;

		return cancel_quitting_game ();
	}

	private bool cancel_quitting_game () {
		if (display_box.runner != null)
			try {
				display_box.runner.resume ();
			}
			catch (Error e) {
				warning (e.message);
			}

		return false;
	}

	[GtkCallback]
	private void on_toplevel_focus () {
		if (ui_state != UiState.DISPLAY)
			return;

		if (display_box.runner == null)
			return;

		if (has_toplevel_focus)
			try {
				display_box.runner.resume ();
			}
			catch (Error e) {
				warning (e.message);
			}
		else
			display_box.runner.pause ();
	}
}
