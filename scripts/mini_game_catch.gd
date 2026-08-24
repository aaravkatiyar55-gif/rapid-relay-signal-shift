extends "res://scripts/mini_game_base.gd"

const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")
const PURPLE := Color("b59ae8")
const RETICLE_STEP := 24.0
const RETICLE_MIN := Vector2(178, 263)
const RETICLE_MAX := Vector2(782, 345)

var _font: Font
var _orb_position := Vector2(170, 302)
var _reticle_position := Vector2(480, 302)
var _elapsed := 0.0


func _ready() -> void:

	_font = ThemeDB.fallback_font
	_feedback = "Catch the orb with mouse, touch, or Arrow keys + Enter."
	queue_redraw()


func _process(delta: float) -> void:

	if _resolved:
		return
	_elapsed += delta
	_orb_position.x = 170.0 + _elapsed * 190.0
	_orb_position.y = 302.0 + sin(_elapsed * 4.0) * 48.0
	if _elapsed >= 3.3 or _orb_position.x >= 790.0:
		_resolve(false, "Signal escaped the capture field")
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:

	if _resolved:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_click(event.position)
	elif event is InputEventKey and event.pressed:
		_handle_key(event)


func _handle_key(event: InputEventKey) -> void:

	var direction := Vector2.ZERO
	match event.keycode:
		KEY_LEFT:
			direction.x = -1.0
		KEY_RIGHT:
			direction.x = 1.0
		KEY_UP:
			direction.y = -1.0
		KEY_DOWN:
			direction.y = 1.0
		KEY_ENTER, KEY_KP_ENTER:
			get_viewport().set_input_as_handled()
			_handle_click(_reticle_position)
			return
		_:
			return

	get_viewport().set_input_as_handled()
	_reticle_position += direction * RETICLE_STEP
	_reticle_position.x = clampf(_reticle_position.x, RETICLE_MIN.x, RETICLE_MAX.x)
	_reticle_position.y = clampf(_reticle_position.y, RETICLE_MIN.y, RETICLE_MAX.y)
	queue_redraw()


func _handle_click(point: Vector2) -> void:

	if _resolved:
		return
	get_viewport().set_input_as_handled()
	if point.distance_to(_orb_position) <= 46.0:
		_resolve(true, "Orb caught — relay connected")
	else:
		_resolve(false, "Missed orb — signal dropped")


func _draw() -> void:

	draw_rect(Rect2(125, 142, 710, 280), PANEL, true)
	draw_string(_font, Vector2(301, 189), "ORB CATCH", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, INK)
	draw_string(_font, Vector2(194, 218), "Mouse/touch the orb, or move with Arrows and press Enter.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, CYAN)
	draw_rect(Rect2(160, 245, 640, 118), Color("10162e"), true)
	draw_line(Vector2(790, 245), Vector2(790, 363), CORAL, 4.0)
	draw_string(_font, Vector2(749, 384), "EXIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CORAL)

	var orb_color := LIME if _resolved and _result_success else CYAN
	if _resolved and not _result_success:
		orb_color = CORAL
	draw_circle(_orb_position, 32, orb_color)
	draw_arc(_orb_position, 42, 0.0, TAU, 28, PURPLE, 3.0)
	draw_circle(_orb_position + Vector2(-9, -9), 8, Color(1.0, 1.0, 1.0, 0.35))

	var reticle_color := LIME if _resolved and _result_success else PURPLE
	if _resolved and not _result_success:
		reticle_color = CORAL
	draw_arc(_reticle_position, 17, 0.0, TAU, 24, reticle_color, 2.5)
	draw_line(_reticle_position + Vector2(-27, 0), _reticle_position + Vector2(-18, 0), reticle_color, 3.0)
	draw_line(_reticle_position + Vector2(18, 0), _reticle_position + Vector2(27, 0), reticle_color, 3.0)
	draw_line(_reticle_position + Vector2(0, -27), _reticle_position + Vector2(0, -18), reticle_color, 3.0)
	draw_line(_reticle_position + Vector2(0, 18), _reticle_position + Vector2(0, 27), reticle_color, 3.0)
	draw_string(_font, Vector2(281, 408), _feedback, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, INK)
