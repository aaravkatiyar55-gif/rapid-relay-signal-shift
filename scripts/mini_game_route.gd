extends "res://scripts/mini_game_base.gd"

const PLAYFIELD := Rect2(125, 142, 710, 280)
const TIME_LIMIT := 4.2
const SEQUENCE := [KEY_UP, KEY_RIGHT, KEY_DOWN, KEY_LEFT]

const NAVY := Color("10162e")
const PANEL := Color("22274a")
const OFF_WHITE := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")

var _font: Font
var _elapsed := 0.0
var _step_index := 0


func _ready() -> void:

	_font = ThemeDB.fallback_font
	reset_game()


func reset_game() -> void:

	_elapsed = 0.0
	_step_index = 0
	_reset_resolution_state()
	_feedback = "Decode the four arrows in order."
	queue_redraw()


func _process(delta: float) -> void:

	_advance(delta)


func _advance(delta: float) -> void:

	if _resolved:
		return
	_elapsed += maxf(delta, 0.0)
	if _elapsed >= TIME_LIMIT:
		_resolve(false, "Route timed out — signal diverted")
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:

	if _resolved:
		return
	if event is InputEventKey and event.pressed and not event.echo and SEQUENCE.has(event.keycode):
		get_viewport().set_input_as_handled()
		_handle_keycode(event.keycode)


func _handle_keycode(keycode: int) -> void:

	if _resolved:
		return
	var expected_key: int = SEQUENCE[_step_index]
	if keycode != expected_key:
		_resolve(false, "Wrong arrow — route broken")
		return

	_step_index += 1
	if _step_index == SEQUENCE.size():
		_resolve(true, "Route decoded — relay connected")
	else:
		_feedback = "%d of %d arrows decoded" % [_step_index, SEQUENCE.size()]
		queue_redraw()


func _draw() -> void:

	draw_rect(PLAYFIELD, PANEL, true)
	draw_string(_font, Vector2(365, 177), "RELAY ROUTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, OFF_WHITE)
	draw_string(_font, Vector2(263, 204), "Use the arrow keys before the route timer empties.", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, CYAN)

	var timer_ratio := clampf(1.0 - (_elapsed / TIME_LIMIT), 0.0, 1.0)
	draw_rect(Rect2(190, 214, 580, 8), NAVY, true)
	draw_rect(Rect2(190, 214, 580.0 * timer_ratio, 8), CORAL if timer_ratio < 0.25 else CYAN, true)

	for index in SEQUENCE.size():
		var center := Vector2(276 + index * 136, 278)
		var box_color := NAVY
		var arrow_color := OFF_WHITE
		if index < _step_index:
			box_color = LIME
			arrow_color = NAVY
		elif index == _step_index and not _resolved:
			arrow_color = CYAN
		draw_rect(Rect2(center - Vector2(48, 44), Vector2(96, 88)), box_color, true)
		draw_rect(Rect2(center - Vector2(48, 44), Vector2(96, 88)), CYAN if index == _step_index and not _resolved else OFF_WHITE, false, 2.0)
		_draw_arrow(center - Vector2(0, 7), SEQUENCE[index], arrow_color)
		draw_string(_font, Vector2(center.x - 35, center.y + 34), _direction_name(SEQUENCE[index]), HORIZONTAL_ALIGNMENT_CENTER, 70, 13, arrow_color)

	var feedback_color := OFF_WHITE
	if _resolved:
		feedback_color = LIME if _result_success else CORAL
		draw_circle(Vector2(800, 174), 14, feedback_color)
		if _result_success:
			draw_line(Vector2(793, 174), Vector2(798, 180), NAVY, 3.0)
			draw_line(Vector2(798, 180), Vector2(808, 168), NAVY, 3.0)
		else:
			draw_line(Vector2(794, 168), Vector2(806, 180), NAVY, 3.0)
			draw_line(Vector2(806, 168), Vector2(794, 180), NAVY, 3.0)
	draw_string(_font, Vector2(190, 374), _feedback, HORIZONTAL_ALIGNMENT_CENTER, 580, 18, feedback_color)
	draw_string(_font, Vector2(190, 402), "Fixed route: UP  RIGHT  DOWN  LEFT", HORIZONTAL_ALIGNMENT_CENTER, 580, 14, OFF_WHITE)


func _draw_arrow(center: Vector2, keycode: int, color: Color) -> void:

	var direction := Vector2.UP
	match keycode:
		KEY_RIGHT:
			direction = Vector2.RIGHT
		KEY_DOWN:
			direction = Vector2.DOWN
		KEY_LEFT:
			direction = Vector2.LEFT
	var side := Vector2(-direction.y, direction.x)
	var tip := center + direction * 20.0
	draw_line(center - direction * 17.0, tip, color, 5.0)
	draw_colored_polygon(PackedVector2Array([
		tip,
		tip - direction * 13.0 + side * 9.0,
		tip - direction * 13.0 - side * 9.0,
	]), color)


func _direction_name(keycode: int) -> String:

	match keycode:
		KEY_UP:
			return "UP"
		KEY_RIGHT:
			return "RIGHT"
		KEY_DOWN:
			return "DOWN"
		_:
			return "LEFT"
