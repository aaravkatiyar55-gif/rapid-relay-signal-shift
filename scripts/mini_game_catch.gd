extends Node2D

signal finished(success: bool)

const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")
const PURPLE := Color("b59ae8")

var _font: Font
var _orb_position := Vector2(170, 302)
var _elapsed := 0.0
var _resolved := false
var _feedback := "Click the drifting orb before it crosses the line."


func _ready() -> void:

	_font = ThemeDB.fallback_font
	queue_redraw()


func _process(delta: float) -> void:

	if _resolved:
		return
	_elapsed += delta
	_orb_position.x = 170.0 + _elapsed * 190.0
	_orb_position.y = 302.0 + sin(_elapsed * 4.0) * 48.0
	if _elapsed >= 3.3 or _orb_position.x >= 790.0:
		_finish(false, "Signal escaped the capture field")
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:

	if _resolved:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_click(event.position)


func _handle_click(point: Vector2) -> void:

	get_viewport().set_input_as_handled()
	if point.distance_to(_orb_position) <= 46.0:
		_finish(true, "Orb caught — relay connected")
	else:
		_finish(false, "Missed orb — signal dropped")


func _finish(success: bool, message: String) -> void:

	if _resolved:
		return
	_resolved = true
	_feedback = message
	queue_redraw()
	await get_tree().create_timer(0.85).timeout
	finished.emit(success)


func _draw() -> void:

	draw_rect(Rect2(125, 142, 710, 280), PANEL, true)
	draw_string(_font, Vector2(301, 189), "ORB CATCH", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, INK)
	draw_string(_font, Vector2(232, 218), "Click the moving signal before it leaves the field.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CYAN)
	draw_rect(Rect2(160, 245, 640, 118), Color("10162e"), true)
	draw_line(Vector2(790, 245), Vector2(790, 363), CORAL, 4.0)
	draw_string(_font, Vector2(749, 384), "EXIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CORAL)

	var orb_color := LIME if _resolved and _feedback.begins_with("Orb") else CYAN
	if _resolved and not _feedback.begins_with("Orb"):
		orb_color = CORAL
	draw_circle(_orb_position, 32, orb_color)
	draw_arc(_orb_position, 42, 0.0, TAU, 28, PURPLE, 3.0)
	draw_circle(_orb_position + Vector2(-9, -9), 8, Color(1.0, 1.0, 1.0, 0.35))
	draw_string(_font, Vector2(281, 408), _feedback, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, INK)
