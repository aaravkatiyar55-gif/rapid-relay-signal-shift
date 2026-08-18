extends Node2D

const GAME_SCENE := "res://scenes/Game.tscn"

const NAVY := Color("10162e")
const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const PURPLE := Color("b59ae8")

var _font: Font


func _ready() -> void:

	_font = ThemeDB.fallback_font
	_make_start_button()
	_add_relay_icon()
	queue_redraw()


func _make_start_button() -> void:

	var button := Button.new()
	button.name = "StartRelay"
	button.text = "START RELAY"
	button.position = Vector2(350, 382)
	button.size = Vector2(260, 62)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", NAVY)
	button.add_theme_stylebox_override("normal", _button_style(LIME, LIME, 10))
	button.add_theme_stylebox_override("hover", _button_style(CYAN, CYAN, 10))
	button.add_theme_stylebox_override("focus", _button_style(LIME, CYAN, 10))
	button.pressed.connect(_start_relay)
	add_child(button)
	button.grab_focus()


func _add_relay_icon() -> void:

	var icon := Sprite2D.new()
	var relay_texture := load("res://assets/relay_icon.svg") as Texture2D
	if relay_texture != null:
		icon.texture = relay_texture
	icon.position = Vector2(480, 167)
	icon.scale = Vector2(0.78, 0.78)
	add_child(icon)


func _button_style(background: Color, border: Color, radius: int) -> StyleBoxFlat:

	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(radius)
	return style


func _start_relay() -> void:

	get_tree().change_scene_to_file(GAME_SCENE)


func _draw() -> void:

	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), NAVY)
	draw_rect(Rect2(70, 52, 820, 438), PANEL, true)
	draw_line(Vector2(110, 306), Vector2(850, 306), PURPLE, 2.0)
	draw_string(_font, Vector2(269, 92), "RAPID RELAY", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, INK)
	draw_string(_font, Vector2(295, 122), "SIGNAL SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CYAN)
	draw_string(_font, Vector2(213, 334), "React to short relay tests before contact drops.", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, INK)
	draw_string(_font, Vector2(267, 476), "Tab + Enter: buttons     Space: timing test     Mouse: orb test", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, PURPLE)
