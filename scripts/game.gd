extends Node2D

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const WIN_SCENE := "res://scenes/WinScene.tscn"
const DEATH_SCENE := "res://scenes/DeathScene.tscn"
const PRESS_SCENE := preload("res://scenes/MiniGamePress.tscn")
const CATCH_SCENE := preload("res://scenes/MiniGameCatch.tscn")
const WAVE_SCENE := preload("res://scenes/MiniGameWave.tscn")
const ROUTE_SCENE := preload("res://scenes/MiniGameRoute.tscn")
const DOCK_SCENE := preload("res://scenes/MiniGameDock.tscn")

const ROUND_PLAN := [
	{
		"scene": PRESS_SCENE,
		"label": "WAKE",
		"title": "Pulse Press",
		"instruction": "Press Space only after GO.",
		"story": "Wake the dormant beacon.",
	},
	{
		"scene": CATCH_SCENE,
		"label": "CATCH",
		"title": "Orb Catch",
		"instruction": "Catch the moving signal with mouse, touch, or the keyboard reticle.",
		"story": "Catch KITE's drifting carrier signal.",
	},
	{
		"scene": WAVE_SCENE,
		"label": "TUNE",
		"title": "Wave Tuner",
		"instruction": "Use Left and Right. Hold the needle inside the stable band.",
		"story": "Tune through the ion storm.",
	},
	{
		"scene": ROUTE_SCENE,
		"label": "ROUTE",
		"title": "Relay Route",
		"instruction": "Enter the four visible Arrow keys in order.",
		"story": "Route power around the damaged junction.",
	},
	{
		"scene": DOCK_SCENE,
		"label": "DOCK",
		"title": "Core Dock",
		"instruction": "Drag the marked core to its matching socket, or use Left/Right + Enter.",
		"story": "Dock KITE's final navigation core.",
	},
]

const NAVY := Color("10162e")
const DEEP_NAVY := Color("0a0f22")
const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")
const MUTED := Color("8892bf")

var _font: Font
var _round_index := 0
var _signal_bars := 3
var _round_label := ""
var _round_title := ""
var _instruction := ""
var _story := ""
var _status := "Relay test armed."
var _round_resolved := false
var _current_game: Node
var _round_results: Array[bool] = []
var _elapsed := 0.0


func _ready() -> void:

	_font = ThemeDB.fallback_font
	_make_menu_button()
	_add_kite_status()
	_start_next_round()
	queue_redraw()


func _process(delta: float) -> void:

	_elapsed += delta
	queue_redraw()


func _make_menu_button() -> void:

	var button := Button.new()
	button.name = "ReturnToMenu"
	button.text = "RETURN TO MENU"
	button.position = Vector2(744, 473)
	button.size = Vector2(168, 42)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _button_style(PANEL, MUTED))
	button.add_theme_stylebox_override("hover", _button_style(PANEL, CYAN))
	button.add_theme_stylebox_override("focus", _button_style(PANEL, CYAN))
	button.pressed.connect(_return_to_menu)
	add_child(button)


func _add_kite_status() -> void:

	var kite_texture := load("res://assets/kite_drone.svg") as Texture2D
	if kite_texture == null:
		return
	var icon := Sprite2D.new()
	icon.name = "KiteStatus"
	icon.texture = kite_texture
	icon.position = Vector2(883, 72)
	icon.scale = Vector2(0.19, 0.19)
	add_child(icon)


func _button_style(background: Color, border: Color) -> StyleBoxFlat:

	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style


func _start_next_round() -> void:

	_round_resolved = false
	if _round_index >= ROUND_PLAN.size():
		return
	var round_data: Dictionary = ROUND_PLAN[_round_index]
	var round_scene: PackedScene = round_data["scene"]
	_round_label = round_data["label"]
	_round_title = round_data["title"]
	_instruction = round_data["instruction"]
	_story = round_data["story"]
	_current_game = round_scene.instantiate()
	_status = "Stage %d is live." % (_round_index + 1)
	add_child(_current_game)
	_current_game.connect("finished", _on_minigame_finished)
	queue_redraw()


func _on_minigame_finished(success: bool) -> void:

	if _round_resolved:
		return
	_round_resolved = true
	if success:
		_status = "Link stable. No backup used."
	else:
		_signal_bars -= 1
		if _signal_bars > 0:
			_status = "Backup channel recovered this stage. Signal bar lost."
		else:
			_status = "No backup channels remain."
	_round_results.append(success)
	if is_instance_valid(_current_game):
		_current_game.queue_free()
	queue_redraw()

	await get_tree().create_timer(0.75).timeout
	if _signal_bars <= 0:
		get_tree().change_scene_to_file(DEATH_SCENE)
		return
	_round_index += 1
	if _round_index >= ROUND_PLAN.size():
		get_tree().change_scene_to_file(WIN_SCENE)
		return
	_start_next_round()


func _return_to_menu() -> void:

	get_tree().change_scene_to_file(MENU_SCENE)


func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_cancel"):
		_return_to_menu()


func _draw() -> void:

	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), NAVY)
	_draw_grid()
	draw_rect(Rect2(28, 20, 904, 106), Color(DEEP_NAVY, 0.8), true)
	draw_rect(Rect2(40, 30, 880, 86), PANEL, true)
	draw_rect(Rect2(40, 30, 6, 86), CYAN, true)
	draw_string(_font, Vector2(62, 55), "RELAY STATION FIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CYAN)
	draw_string(_font, Vector2(62, 86), "STAGE %02d / %02d" % [_round_index + 1, ROUND_PLAN.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, INK)

	# Five route nodes show progress, current stage, and recovered failures.
	for stage_index in range(ROUND_PLAN.size()):
		var node_x := 286.0 + stage_index * 106.0
		if stage_index < ROUND_PLAN.size() - 1:
			var line_color := LIME if stage_index < _round_results.size() else Color(CYAN, 0.22)
			draw_line(Vector2(node_x + 15, 73), Vector2(node_x + 91, 73), line_color, 3.0)
		var node_color := MUTED
		if stage_index < _round_results.size():
			node_color = LIME if _round_results[stage_index] else CORAL
		elif stage_index == _round_index:
			node_color = CYAN
		draw_circle(Vector2(node_x, 73), 13, DEEP_NAVY)
		draw_arc(Vector2(node_x, 73), 13, 0.0, TAU, 24, node_color, 3.0)
		if stage_index < _round_results.size():
			if _round_results[stage_index]:
				draw_circle(Vector2(node_x, 73), 5, LIME)
			else:
				draw_line(Vector2(node_x - 4, 69), Vector2(node_x + 4, 77), CORAL, 2.0)
				draw_line(Vector2(node_x + 4, 69), Vector2(node_x - 4, 77), CORAL, 2.0)
		elif stage_index == _round_index:
			var pulse_radius := 4.0 + (sin(_elapsed * 4.0) + 1.0) * 1.5
			draw_circle(Vector2(node_x, 73), pulse_radius, CYAN)
		draw_string(_font, Vector2(node_x - 27, 104), str(ROUND_PLAN[stage_index]["label"]), HORIZONTAL_ALIGNMENT_CENTER, 54, 11, node_color)

	draw_string(_font, Vector2(748, 51), "BACKUPS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, MUTED)
	draw_string(_font, Vector2(748, 79), "%d / 3" % _signal_bars, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, INK)
	for bar_index in range(3):
		var bar_color := LIME if bar_index < _signal_bars else CORAL
		draw_rect(Rect2(800 + bar_index * 18, 62, 12, 20), bar_color, true)

	draw_string(_font, Vector2(56, 137), "%s  //  %s" % [_round_label, _instruction], HORIZONTAL_ALIGNMENT_LEFT, 846, 15, CYAN)
	draw_rect(Rect2(40, 432, 880, 94), Color(DEEP_NAVY, 0.84), true)
	draw_rect(Rect2(40, 432, 5, 94), MUTED, true)
	draw_string(_font, Vector2(60, 457), "KITE LINK  •  %s" % _story, HORIZONTAL_ALIGNMENT_LEFT, 650, 14, MUTED)
	draw_string(_font, Vector2(60, 486), _status, HORIZONTAL_ALIGNMENT_LEFT, 650, 17, INK)
	draw_string(_font, Vector2(60, 514), "ESC: MENU   •   READ THE ACTIVE CONTROL ABOVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, MUTED)


func _draw_grid() -> void:

	for x in range(0, 961, 32):
		draw_line(Vector2(x, 0), Vector2(x, 540), Color(CYAN, 0.028), 1.0)
	for y in range(0, 541, 32):
		draw_line(Vector2(0, y), Vector2(960, y), Color(CYAN, 0.028), 1.0)
