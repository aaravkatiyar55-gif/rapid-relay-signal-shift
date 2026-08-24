extends "res://scripts/mini_game_base.gd"

const PLAYFIELD := Rect2(125, 142, 710, 280)
const TIME_LIMIT := 5.0
const SOCKET_RADIUS := 48.0
const CORE_RADIUS := 25.0
const CORE_HIT_RADIUS := 34.0
const CORRECT_SOCKET := 1
const CORE_START := Vector2(205, 374)
const SOCKET_CENTERS := [Vector2(280, 278), Vector2(480, 278), Vector2(680, 278)]

const NAVY := Color("10162e")
const PANEL := Color("22274a")
const OFF_WHITE := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")

var _font: Font
var _elapsed := 0.0
var _core_position := CORE_START
var _selected_socket := 0
var _dragging := false


func _ready() -> void:

	_font = ThemeDB.fallback_font
	reset_game()


func reset_game() -> void:

	_elapsed = 0.0
	_core_position = CORE_START
	_selected_socket = 0
	_dragging = false
	_reset_resolution_state()
	_feedback = "Drag the diamond core to its matching socket."
	queue_redraw()


func _process(delta: float) -> void:

	_advance(delta)


func _advance(delta: float) -> void:

	if _resolved:
		return
	_elapsed += maxf(delta, 0.0)
	if _elapsed >= TIME_LIMIT:
		_resolve(false, "Dock timed out — core disconnected")
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:

	if _resolved:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER]:
			get_viewport().set_input_as_handled()
			_handle_keycode(event.keycode)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and event.position.distance_to(_core_position) <= CORE_HIT_RADIUS:
			get_viewport().set_input_as_handled()
			_dragging = true
		elif not event.pressed and _dragging:
			get_viewport().set_input_as_handled()
			_handle_drop(event.position)
	elif event is InputEventMouseMotion and _dragging:
		get_viewport().set_input_as_handled()
		_move_core(event.position)
	elif event is InputEventScreenTouch:
		if event.pressed and event.position.distance_to(_core_position) <= CORE_HIT_RADIUS:
			get_viewport().set_input_as_handled()
			_dragging = true
		elif not event.pressed and _dragging:
			get_viewport().set_input_as_handled()
			_handle_drop(event.position)
	elif event is InputEventScreenDrag and _dragging:
		get_viewport().set_input_as_handled()
		_move_core(event.position)


func _handle_keycode(keycode: int) -> void:

	if _resolved:
		return
	if keycode == KEY_LEFT:
		_selected_socket = (_selected_socket - 1 + SOCKET_CENTERS.size()) % SOCKET_CENTERS.size()
		_feedback = "Socket %s selected — press Enter to dock." % _socket_label(_selected_socket)
	elif keycode == KEY_RIGHT:
		_selected_socket = (_selected_socket + 1) % SOCKET_CENTERS.size()
		_feedback = "Socket %s selected — press Enter to dock." % _socket_label(_selected_socket)
	elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
		_handle_drop(SOCKET_CENTERS[_selected_socket])
		return
	else:
		return
	queue_redraw()


func _move_core(point: Vector2) -> void:

	_core_position = Vector2(
		clampf(point.x, PLAYFIELD.position.x + CORE_RADIUS, PLAYFIELD.end.x - CORE_RADIUS),
		clampf(point.y, PLAYFIELD.position.y + CORE_RADIUS, PLAYFIELD.end.y - CORE_RADIUS)
	)
	queue_redraw()


func _handle_drop(point: Vector2) -> void:

	if _resolved:
		return
	_dragging = false
	var socket_index := _socket_at(point)
	if socket_index == -1:
		_core_position = CORE_START
		_feedback = "No socket there — try the diamond-shaped port."
		queue_redraw()
		return

	_core_position = SOCKET_CENTERS[socket_index]
	_selected_socket = socket_index
	if socket_index == CORRECT_SOCKET:
		_resolve(true, "Core docked — relay connected")
	else:
		_resolve(false, "Wrong socket — core rejected")


func _socket_at(point: Vector2) -> int:

	for index in SOCKET_CENTERS.size():
		if point.distance_to(SOCKET_CENTERS[index]) <= SOCKET_RADIUS:
			return index
	return -1


func _draw() -> void:

	draw_rect(PLAYFIELD, PANEL, true)
	draw_string(_font, Vector2(382, 175), "CORE DOCK", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, OFF_WHITE)
	draw_string(_font, Vector2(255, 199), "Match the core shape. Drag/touch, or use Left/Right + Enter.", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, CYAN)

	var timer_ratio := clampf(1.0 - (_elapsed / TIME_LIMIT), 0.0, 1.0)
	draw_rect(Rect2(190, 209, 580, 8), NAVY, true)
	draw_rect(Rect2(190, 209, 580.0 * timer_ratio, 8), CORAL if timer_ratio < 0.25 else CYAN, true)

	for index in SOCKET_CENTERS.size():
		_draw_socket(index)

	var core_color := CYAN
	if _resolved:
		core_color = LIME if _result_success else CORAL
	_draw_diamond(_core_position, CORE_RADIUS, core_color, true)
	draw_circle(_core_position, 8, OFF_WHITE)

	var feedback_color := OFF_WHITE
	if _resolved:
		feedback_color = LIME if _result_success else CORAL
		draw_circle(Vector2(801, 171), 14, feedback_color)
		if _result_success:
			draw_line(Vector2(794, 171), Vector2(799, 177), NAVY, 3.0)
			draw_line(Vector2(799, 177), Vector2(808, 165), NAVY, 3.0)
		else:
			draw_line(Vector2(795, 165), Vector2(807, 177), NAVY, 3.0)
			draw_line(Vector2(807, 165), Vector2(795, 177), NAVY, 3.0)
	draw_string(_font, Vector2(245, 380), _feedback, HORIZONTAL_ALIGNMENT_LEFT, 550, 16, feedback_color)
	draw_string(_font, Vector2(245, 405), "Core: diamond     Selected socket: %s" % _socket_label(_selected_socket), HORIZONTAL_ALIGNMENT_LEFT, 550, 14, OFF_WHITE)


func _draw_socket(index: int) -> void:

	var center: Vector2 = SOCKET_CENTERS[index]
	var selected := index == _selected_socket and not _resolved
	var border_color := CYAN if selected else OFF_WHITE
	draw_circle(center, SOCKET_RADIUS, NAVY)
	draw_arc(center, SOCKET_RADIUS, 0.0, TAU, 40, border_color, 3.0)
	match index:
		0:
			draw_arc(center, 23.0, 0.0, TAU, 28, OFF_WHITE, 4.0)
		1:
			_draw_diamond(center, 24.0, OFF_WHITE, false)
		2:
			draw_rect(Rect2(center - Vector2(22, 22), Vector2(44, 44)), OFF_WHITE, false, 4.0)
	draw_string(_font, Vector2(center.x - 30, center.y + 65), "SOCKET %s" % _socket_label(index), HORIZONTAL_ALIGNMENT_CENTER, 60, 12, border_color)


func _draw_diamond(center: Vector2, radius: float, color: Color, filled: bool) -> void:

	var points := PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius, 0),
	])
	if filled:
		draw_colored_polygon(points, color)
	else:
		points.append(points[0])
		draw_polyline(points, color, 4.0)


func _socket_label(index: int) -> String:

	return ["A", "B", "C"][index]
