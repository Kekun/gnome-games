// This file is part of GNOME Games. License: GPL-3.0+.

[CCode (cheader_filename = "event.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "games_event_get_type ()")]
[Compact]
public class Games.Event {
	public Games.EventType type;
	[CCode (has_construct_function = false)]
	public Event (Games.EventType type);
	public Games.Event copy ();
	public void free ();
	public Games.EventAny any {[CCode (cname = "(GamesEventAny *)")] get; }
	public Games.EventGamepad gamepad {[CCode (cname = "(GamesEventGamepad *)")] get; }
	public Games.EventGamepadButton gamepad_button {[CCode (cname = "(GamesEventGamepadButton *)")] get; }
	public Games.EventGamepadAxis gamepad_axis {[CCode (cname = "(GamesEventGamepadAxis *)")] get; }
	public Games.EventGamepadHat gamepad_hat {[CCode (cname = "(GamesEventGamepadHat *)")] get; }
}

[CCode (cheader_filename = "event.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "games_event_get_type ()")]
[Compact]
public class Games.EventAny : Games.Event {
	public Games.EventType type;
	public uint32 time;
}

[CCode (cheader_filename = "event.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "games_event_get_type ()")]
[Compact]
public class Games.EventGamepad : Games.Event {
	public Games.EventType type;
	public uint32 time;
	public uint16 hardware_type;
	public uint16 hardware_code;
	public int32 hardware_value;
}

[CCode (cheader_filename = "event.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "games_event_get_type ()")]
[Compact]
public class Games.EventGamepadButton : Games.Event {
	public Games.EventType type;
	public uint32 time;
	public uint16 hardware_type;
	public uint16 hardware_code;
	public int32 hardware_value;
	public uint8 hardware_index;
	public uint16 button;
}

[CCode (cheader_filename = "event.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "games_event_get_type ()")]
[Compact]
public class Games.EventGamepadAxis : Games.Event {
	public Games.EventType type;
	public uint32 time;
	public uint16 hardware_type;
	public uint16 hardware_code;
	public int32 hardware_value;
	public uint8 hardware_index;
	public uint16 axis;
	public double value;
}

[CCode (cheader_filename = "event.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "games_event_get_type ()")]
[Compact]
public class Games.EventGamepadHat : Games.Event {
	public Games.EventType type;
	public uint32 time;
	public uint16 hardware_type;
	public uint16 hardware_code;
	public int32 hardware_value;
	public uint8 hardware_index;
	public uint16 axis;
	public int8 value;
}

[CCode (cheader_filename = "event.h", cprefix = "GAMES_")]
public enum Games.EventType {
	EVENT_NOTHING,
	EVENT_GAMEPAD_BUTTON_PRESS,
	EVENT_GAMEPAD_BUTTON_RELEASE,
	EVENT_GAMEPAD_AXIS,
	EVENT_GAMEPAD_HAT,
	LAST_EVENT,
}
