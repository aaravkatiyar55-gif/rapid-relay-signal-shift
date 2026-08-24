extends "res://scripts/mini_game_base.gd"

const NAVY := Color("10162e")
const PANEL := Color("22274a")
const OFF_WHITE := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")

const GAME_RECT := Rect2(125, 142, 710, 280)
const TRACK_RECT := Rect2(165, 245, 630, 98)
const TIME_LIMIT := 4.5
const LOCK_REQUIRED := 0.55
const NEEDLE_SPEED := 285.0
const NEEDLE_START_X := 245.0
const NEEDLE_MIN_X := 178.0
const NEEDLE_MAX_X := 782.0
const TARGET_CENTER_X := 610.0
const TARGET_HALF_WIDTH := 44.0
const TARGET_MIN_X := TARGET_CENTER_X - TARGET_HALF_WIDTH
const TARGET_MAX_X := TARGET_CENTER_X + TARGET_HALF_WIDTH

var _font: Font
var _needle_x := NEEDLE_START_X
var _elapsed := 0.0
var _lock_elapsed := 0.0


func _ready() -> void:

	_font = ThemeDB.fallback_font
	reset_game()


func reset_game() -> void:

	_reset_resolution_state()
	_feedback = "Use Left / Right to tune the cyan needle."
	_needle_x = NEEDLE_START_X
	_elapsed = 0.0
	_lock_elapsed = 0.0
	queue_redraw()


func _process(delta: float) -> void:

	var direction := Input.get_axis("ui_left", "ui_right")
	_advance(delta, direction)


func _unhandled_input(event: InputEvent) -> void:

	if _resolved:
		return
	if event is InputEventKey and event.keycode in [KEY_LEFT, KEY_RIGHT]:
		get_viewport().set_input_as_handled()


func _advance(delta: float, direction: float) -> void:

	if _resolved or delta <= 0.0:
		return

	var active_delta := minf(delta, maxf(0.0, TIME_LIMIT - _elapsed))
	_elapsed += active_delta
	var was_in_target := _is_needle_in_target()
	var bounded_direction := clampf(direction, -1.0, 1.0)
	_needle_x = clampf(
		_needle_x + bounded_direction * NEEDLE_SPEED * active_delta,
		NEEDLE_MIN_X,
		NEEDLE_MAX_X
	)

	if _is_needle_in_target():
		if was_in_target:
			_lock_elapsed += active_delta
		else:
			_lock_elapsed = 0.0
		_feedback = "Signal aligned — hold steady."
	else:
		if _lock_elapsed > 0.0:
			_feedback = "Lock lost — line up inside the lime band."
		_lock_elapsed = 0.0

	if _lock_elapsed >= LOCK_REQUIRED:
		_resolve(true, "Wave locked — relay connected")
	elif _elapsed >= TIME_LIMIT:
		_resolve(false, "Time up — signal drifted away")

	queue_redraw()


func _is_needle_in_target() -> bool:

	return _needle_x >= TARGET_MIN_X and _needle_x <= TARGET_MAX_X


func _draw() -> void:

	draw_rect(GAME_RECT, PANEL, true)
	draw_string(_font, Vector2(155, 183), "WAVE TUNER", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, OFF_WHITE)
	draw_string(_font, Vector2(155, 211), "Move with Left / Right, then hold inside the lime band.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, CYAN)
	var remaining := maxf(0.0, TIME_LIMIT - _elapsed)
	draw_string(_font, Vector2(720, 183), "%0.1fs" % remaining, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, OFF_WHITE)

	draw_rect(TRACK_RECT, NAVY, true)
	var target_rect := Rect2(TARGET_MIN_X, TRACK_RECT.position.y, TARGET_MAX_X - TARGET_MIN_X, TRACK_RECT.size.y)
	draw_rect(target_rect, LIME, false, 4.0)
	draw_string(_font, Vector2(TARGET_MIN_X + 18.0, 263), "HOLD", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, LIME)

	var wave_points := PackedVector2Array()
	for index in range(37):
		var ratio := float(index) / 36.0
		var point_x := TRACK_RECT.position.x + ratio * TRACK_RECT.size.x
		var point_y := TRACK_RECT.get_center().y + sin(ratio * TAU * 3.0) * 21.0
		wave_points.append(Vector2(point_x, point_y))
	draw_polyline(wave_points, CYAN, 2.0, true)

	var needle_color := LIME if _is_needle_in_target() else CYAN
	if _resolved:
		needle_color = LIME if _result_success else CORAL
	draw_line(Vector2(_needle_x, 238), Vector2(_needle_x, 350), needle_color, 5.0)
	draw_circle(Vector2(_needle_x, TRACK_RECT.get_center().y), 10.0, needle_color)

	draw_rect(Rect2(250, 360, 460, 12), NAVY, true)
	var lock_ratio := clampf(_lock_elapsed / LOCK_REQUIRED, 0.0, 1.0)
	draw_rect(Rect2(250, 360, 460.0 * lock_ratio, 12), LIME, true)
	draw_string(_font, Vector2(718, 372), "%d%%" % roundi(lock_ratio * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, LIME)

	var feedback_color := CYAN
	if _resolved:
		feedback_color = LIME if _result_success else CORAL
	elif _is_needle_in_target():
		feedback_color = LIME
	var feedback_center := Vector2(184, 395)
	draw_circle(feedback_center, 12.0, feedback_color)
	if _resolved and _result_success:
		draw_line(feedback_center + Vector2(-6, 0), feedback_center + Vector2(-1, 5), NAVY, 3.0)
		draw_line(feedback_center + Vector2(-1, 5), feedback_center + Vector2(7, -5), NAVY, 3.0)
	elif _resolved:
		draw_line(feedback_center + Vector2(-5, -5), feedback_center + Vector2(5, 5), NAVY, 3.0)
		draw_line(feedback_center + Vector2(5, -5), feedback_center + Vector2(-5, 5), NAVY, 3.0)
	draw_string(_font, Vector2(207, 402), _feedback, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, OFF_WHITE)
