extends Node2D

const MENU_SCENE := "res://scenes/MainMenu.tscn"
const WIN_SCENE := "res://scenes/WinScene.tscn"
const DEATH_SCENE := "res://scenes/DeathScene.tscn"
const PRESS_SCENE := preload("res://scenes/MiniGamePress.tscn")
const CATCH_SCENE := preload("res://scenes/MiniGameCatch.tscn")

const NAVY := Color("10162e")
const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")
const PURPLE := Color("b59ae8")

var _font: Font
var _round_index := 0
var _signal_bars := 3
var _instruction := ""
var _status := "Relay test armed."
var _round_resolved := false
var _current_game: Node


func _ready() -> void:

	_font = ThemeDB.fallback_font
	_make_menu_button()
	_add_signal_bar_icon()
	_start_next_round()
	queue_redraw()


func _make_menu_button() -> void:

	var button := Button.new()
	button.name = "ReturnToMenu"
	button.text = "RETURN TO MENU"
	button.position = Vector2(720, 466)
	button.size = Vector2(190, 45)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _button_style(PANEL, PURPLE))
	button.add_theme_stylebox_override("hover", _button_style(PANEL, CYAN))
	button.pressed.connect(_return_to_menu)
	add_child(button)


func _add_signal_bar_icon() -> void:

	var signal_bar_texture := load("res://assets/signal_bar.svg") as Texture2D
	if signal_bar_texture != null:
		var icon := Sprite2D.new()
		icon.texture = signal_bar_texture
		icon.position = Vector2(866, 93)
		icon.scale = Vector2(0.34, 0.34)
		add_child(icon)


func _button_style(background: Color, border: Color) -> StyleBoxFlat:

	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	return style


func _start_next_round() -> void:

	_round_resolved = false
	if _round_index % 2 == 0:
		_instruction = "PULSE PRESS — press Space only after GO."
		_current_game = PRESS_SCENE.instantiate()
	else:
		_instruction = "ORB CATCH — click the moving signal orb."
		_current_game = CATCH_SCENE.instantiate()
	_status = "Round %d is live." % (_round_index + 1)
	add_child(_current_game)
	_current_game.connect("finished", _on_minigame_finished)
	queue_redraw()


func _on_minigame_finished(success: bool) -> void:

	if _round_resolved:
		return
	_round_resolved = true
	if success:
		_status = "Connected. The relay continues."
	else:
		_signal_bars -= 1
		_status = "Signal missed. One bar was lost."
	if is_instance_valid(_current_game):
		_current_game.queue_free()
	queue_redraw()

	await get_tree().create_timer(0.75).timeout
	if _signal_bars <= 0:
		get_tree().change_scene_to_file(DEATH_SCENE)
		return
	_round_index += 1
	if _round_index >= 4:
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
	draw_rect(Rect2(28, 24, 904, 86), PANEL, true)
	draw_string(_font, Vector2(55, 59), "ROUND %d / 4" % (_round_index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, INK)
	draw_string(_font, Vector2(318, 59), "SIGNAL BARS %d / 3" % _signal_bars, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, CYAN)
	draw_string(_font, Vector2(705, 59), "STATION ONLINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, PURPLE)

	for bar_index in range(3):
		var bar_color := LIME if bar_index < _signal_bars else CORAL
		draw_rect(Rect2(55 + bar_index * 34, 78, 24, 12), bar_color, true)

	draw_string(_font, Vector2(57, 138), _instruction, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CYAN)
	draw_string(_font, Vector2(57, 458), _status, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, INK)
	draw_string(_font, Vector2(57, 500), "Esc returns to the menu.", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, PURPLE)
