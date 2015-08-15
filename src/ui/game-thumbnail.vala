// This file is part of GNOME Boxes. License: LGPLv2+

//[GtkTemplate (ui = "/org/gnome/Boxes/ui/game-list-thumbnail.ui")]
private class Games.GameThumbnail: Gtk.DrawingArea {
	private const Gtk.CornerType[] right_corners = { Gtk.CornerType.TOP_RIGHT, Gtk.CornerType.BOTTOM_RIGHT };
	private const Gtk.CornerType[] bottom_corners = { Gtk.CornerType.BOTTOM_LEFT, Gtk.CornerType.BOTTOM_RIGHT };

	private const double ICON_SCALE = 0.75;
	private const double FRAME_RADIUS = 2;
	private const int EMBLEM_PADDING = 8;

	public int center_emblem_size { set; get; default = 16; }
	public int secondary_emblem_size { set; get; default = 8; }

	private Game _game;
	public Game game {
		get { return _game; }
		set {
			if (_game == value)
				return;

			_game = value;

			queue_draw ();
		}
		default = null;
	}

	public struct DrawingContext {
		Cairo.Context cr;
		Gdk.Window? window;
		Gtk.StyleContext style;
		Gtk.StateFlags state;
		int width;
		int height;
	}

	public override bool draw (Cairo.Context cr) {
		var window = get_window ();
		var style = get_style_context ();
		var state = get_state_flags ();
		var width = get_allocated_width ();
		var height = get_allocated_height ();

		DrawingContext context = {
			cr, window, style, state, width, height
		};

		if (game == null)
			return false;

		var drawn = false;

		// Draw the default thumbnail if no thumbnail have been drawn
		if (!drawn)
			draw_default (context);

		return true;
	}

	public void draw_default (DrawingContext context) {
		draw_background (context);
		draw_emblem_icon (context, "applications-games-symbolic", center_emblem_size);
		draw_border (context);
	}

	private void draw_emblem_icon (DrawingContext context, string icon_name, int size) {
		Gdk.Pixbuf? emblem = null;

		var color = context.style.get_color (context.state);

		var theme = Gtk.IconTheme.get_default ();
		try {
			var icon_info = theme.lookup_icon (icon_name, size, Gtk.IconLookupFlags.FORCE_SIZE);
			emblem = icon_info.load_symbolic (color);
		} catch (GLib.Error error) {
			warning (@"Unable to get icon '$icon_name': $(error.message)");
			return;
		}

		if (emblem == null)
			return;

		double offset_x = context.width / 2.0 - emblem.width / 2.0;
		double offset_y = context.height / 2.0 - emblem.height / 2.0;

		Gdk.cairo_set_source_pixbuf (context.cr, emblem, offset_x, offset_y);
		context.cr.paint ();
	}

	private void draw_background (DrawingContext context) {
		var color = context.style.get_background_color (context.state);
		context.cr.set_source_rgba (color.red, color.green, color.blue, color.alpha);
		rounded_rectangle (context.cr, 0.5, 0.5, context.width - 1, context.height - 1, FRAME_RADIUS);
		context.cr.fill ();
	}

	private void draw_border (DrawingContext context) {
		var color = context.style.get_border_color (context.state);
		context.cr.set_source_rgba (color.red, color.green, color.blue, color.alpha);
		rounded_rectangle (context.cr, 0.5, 0.5, context.width - 1, context.height - 1, FRAME_RADIUS);
		context.cr.stroke ();
	}

	private void rounded_rectangle (Cairo.Context cr, double x, double y, double width, double height, double radius) {
		const double ARC_0 = 0;
		const double ARC_1 = Math.PI * 0.5;
		const double ARC_2 = Math.PI;
		const double ARC_3 = Math.PI * 1.5;

		cr.new_sub_path ();
		cr.arc (x + width - radius, y + radius,	         radius, ARC_3, ARC_0);
		cr.arc (x + width - radius, y + height - radius, radius, ARC_0, ARC_1);
		cr.arc (x + radius,         y + height - radius, radius, ARC_1, ARC_2);
		cr.arc (x + radius,         y + radius,          radius, ARC_2, ARC_3);
		cr.close_path ();
	}
}
