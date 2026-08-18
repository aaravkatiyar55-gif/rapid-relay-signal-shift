extends Node2D

const GAME_SCENE := "res://scenes/Game.tscn"
const MENU_SCENE := "res://scenes/MainMenu.tscn"

const NAVY := Color("10162e")
const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const CORAL := Color("ff7a78")
const PURPLE := Color("b59ae8")

var _font: Font


func _ready() -> void:

	_font = ThemeDB.fallback_font
	_add_stamp()
	_make_button("TryAgain", "TRY AGAIN", Vector2(274, 392), _try_again, true)
	_make_button("BackToMenu", "BACK TO MENU", Vector2(502, 392), _back_to_menu, false)
	queue_redraw()


func _add_stamp() -> void:

	var failure_stamp_texture := load("res://assets/failure_stamp.svg") as Texture2D
	if failure_stamp_texture != null:
		var stamp := Sprite2D.new()
		stamp.texture = failure_stamp_texture
		stamp.position = Vector2(480, 212)
		add_child(stamp)


func _make_button(button_name: String, label: String, position: Vector2, action: Callable, take_focus: bool) -> void:

	var button := Button.new()
	button.name = button_name
	button.text = label
	button.position = position
	button.size = Vector2(184, 55)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _button_style(PANEL, CORAL))
	button.add_theme_stylebox_override("hover", _button_style(CORAL, NAVY))
	button.add_theme_stylebox_override("focus", _button_style(PANEL, CYAN))
	button.pressed.connect(action)
	add_child(button)
	if take_focus:
		button.grab_focus()


func _button_style(background: Color, border: Color) -> StyleBoxFlat:

	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	return style


func _try_again() -> void:

	get_tree().change_scene_to_file(GAME_SCENE)


func _back_to_menu() -> void:

	get_tree().change_scene_to_file(MENU_SCENE)


func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_cancel"):
		_back_to_menu()


func _draw() -> void:

	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), NAVY)
	draw_rect(Rect2(130, 55, 700, 420), PANEL, true)
	draw_line(Vector2(198, 135), Vector2(242, 179), CORAL, 4.0)
	draw_line(Vector2(242, 135), Vector2(198, 179), CORAL, 4.0)
	draw_line(Vector2(718, 135), Vector2(762, 179), CORAL, 4.0)
	draw_line(Vector2(762, 135), Vector2(718, 179), CORAL, 4.0)
	draw_string(_font, Vector2(345, 118), "SIGNAL LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, INK)
	draw_string(_font, Vector2(324, 336), "The station lost the relay link.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, PURPLE)
