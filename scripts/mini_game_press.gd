extends Node2D

signal finished(success: bool)

enum Phase { WAITING, ACTIVE, RESULT }

const NAVY := Color("10162e")
const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")
const PURPLE := Color("b59ae8")

var _font: Font
var _phase := Phase.WAITING
var _elapsed := 0.0
var _resolved := false
var _feedback := "Stand by..."


func _ready() -> void:

	_font = ThemeDB.fallback_font
	queue_redraw()


func _process(delta: float) -> void:

	if _phase == Phase.RESULT:
		return

	_elapsed += delta
	if _phase == Phase.WAITING and _elapsed >= 1.65:
		_phase = Phase.ACTIVE
		_feedback = "GO — press Space now!"
	elif _phase == Phase.ACTIVE and _elapsed >= 2.55:
		_finish(false, "Too late — signal missed")
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:

	if _resolved:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		if _phase == Phase.WAITING:
			_finish(false, "Too early — wait for GO")
		elif _phase == Phase.ACTIVE:
			_finish(true, "Good signal — relay connected")


func _finish(success: bool, message: String) -> void:

	if _resolved:
		return
	_resolved = true
	_phase = Phase.RESULT
	_feedback = message
	queue_redraw()
	await get_tree().create_timer(0.85).timeout
	finished.emit(success)


func _draw() -> void:

	draw_rect(Rect2(125, 142, 710, 280), PANEL, true)
	draw_string(_font, Vector2(287, 189), "PULSE PRESS", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, INK)
	draw_string(_font, Vector2(236, 218), "Press Space only when the relay says GO.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CYAN)

	var lamp_color := PURPLE
	var label := "WAIT"
	if _phase == Phase.ACTIVE:
		lamp_color = LIME
		label = "GO"
	elif _phase == Phase.RESULT:
		lamp_color = LIME if _feedback.begins_with("Good") else CORAL
		label = "DONE"

	draw_circle(Vector2(480, 302), 66, Color("0b1024"))
	draw_circle(Vector2(480, 302), 51, lamp_color)
	draw_circle(Vector2(463, 284), 13, Color(1.0, 1.0, 1.0, 0.32))
	draw_string(_font, Vector2(453, 310), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, NAVY)
	draw_string(_font, Vector2(289, 394), _feedback, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, INK)
