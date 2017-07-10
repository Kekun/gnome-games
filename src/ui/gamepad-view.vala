// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.GamepadView : Gtk.DrawingArea {
	private const Gtk.StateFlags DEFAULT_STATE = Gtk.StateFlags.NORMAL;
	private const Gtk.StateFlags HIGHLIGHT_STATE = Gtk.StateFlags.LINK;

	private Rsvg.Handle handle;
	private GamepadViewConfiguration configuration;
	private bool[] input_highlights;

	construct {
		handle = new Rsvg.Handle ();
		configuration = { "", new GamepadInputPath[0] };
		input_highlights = {};
	}

	public void set_configuration (GamepadViewConfiguration configuration) throws Error {
		handle = new Rsvg.Handle.from_file (configuration.svg_path);
		set_size_request (handle.width, handle.height);
		this.configuration = configuration;
		input_highlights = new bool[configuration.input_paths.length];

		reset ();
	}

	public void reset () {
		for (var i = 0; i < input_highlights.length; ++i)
			input_highlights[i] = false;

		queue_draw ();
	}

	public bool highlight (GamepadInput input, bool highlight) {
		for (var i = 0; i < configuration.input_paths.length; ++i) {
			if (configuration.input_paths[i].input == input) {
				input_highlights[i] = highlight;
				queue_draw ();

				return true;
			}
		}

		return false;
	}

	public override bool draw (Cairo.Context context) {
		double x, y, scale;
		calculate_image_dimensions (out x, out y, out scale);

		var color_context = create_similar_context (context, x, y, scale);
		color_gamepad (context, color_context);
		var highlight_context = create_similar_context (context, x, y, scale);
		highlight_gamepad (context, highlight_context);

		return false;
	}

	private void color_gamepad (Cairo.Context gamepad_context, Cairo.Context color_context) {
		var color_suface = color_context.get_target ();

		handle.render_cairo (color_context);

		var color = get_style_context ().get_color (DEFAULT_STATE);
		gamepad_context.set_source_rgba (color.red, color.green, color.blue, color.alpha);
		gamepad_context.mask_surface (color_suface, 0, 0);
	}

	private void highlight_gamepad (Cairo.Context gamepad_context, Cairo.Context highlight_context) {
		var highlight_suface = highlight_context.get_target ();
		
		for (var i = 0; i < configuration.input_paths.length; ++i)
			if (input_highlights[i])
				handle.render_cairo_sub (highlight_context, "#" + configuration.input_paths[i].path);

		var color = get_style_context ().get_color (HIGHLIGHT_STATE);
		gamepad_context.set_source_rgba (color.red, color.green, color.blue, color.alpha);
		gamepad_context.mask_surface (highlight_suface, 0, 0);
	}

	private Cairo.Context create_similar_context (Cairo.Context context, double x, double y, double scale) {
		var w = get_allocated_width ();
		var h = get_allocated_height ();
		var surface = context.get_target ();
		var similar_suface = new Cairo.Surface.similar (surface, Cairo.Content.COLOR_ALPHA, w, h);
		var similar_context = new Cairo.Context (similar_suface);
		similar_context.translate (x, y);
		similar_context.scale (scale, scale);

		return similar_context;
	}

	private void calculate_image_dimensions (out double x, out double y, out double scale) {
		double w = get_allocated_width ();
		double h = get_allocated_height ();
		double allocation_ratio = w / h;
		double image_ratio = (double) handle.width / handle.height;

		if (allocation_ratio > image_ratio) {
			scale = h / handle.height;
		}
		else {
			scale = w / handle.width;
		}
		x = (w - handle.width * scale) / 2;
		y = (h - handle.height * scale) / 2;
	}
}
