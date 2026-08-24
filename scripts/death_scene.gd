extends Node2D

const GAME_SCENE := "res://scenes/Game.tscn"
const MENU_SCENE := "res://scenes/MainMenu.tscn"
const NAVY := Color("10162e")
const DEEP_NAVY := Color("0a0f22")
const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const CORAL := Color("ff7a78")
const MUTED := Color("8892bf")

var _font: Font
var _elapsed := 0.0


func _ready() -> void:
	_font = ThemeDB.fallback_font
	_add_kite_ping()
	_make_button("TryAgain", "TRY AGAIN", Vector2(258, 436), _try_again, true)
	_make_button("BackToMenu", "BACK TO MENU", Vector2(502, 436), _back_to_menu, false)
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()


func _add_kite_ping() -> void:
	var kite := Sprite2D.new()
	kite.texture = load("res://assets/kite_drone.svg") as Texture2D
	kite.position = Vector2(708, 260)
	kite.scale = Vector2(0.43, 0.43)
	kite.modulate = Color(0.55, 0.60, 0.74, 0.72)
	add_child(kite)


func _make_button(button_name: String, label: String, position: Vector2, action: Callable, take_focus: bool) -> void:
	var button := Button.new()
	button.name = button_name
	button.text = label
	button.position = position
	button.size = Vector2(200, 54)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _button_style(PANEL, CORAL))
	button.add_theme_stylebox_override("hover", _button_style(CORAL, NAVY))
	button.add_theme_stylebox_override("focus", _button_style(PANEL, CYAN, true))
	button.pressed.connect(action)
	add_child(button)
	if take_focus:
		button.grab_focus()


func _button_style(background: Color, border: Color, focus_cue := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(6 if focus_cue else 3)
	style.set_corner_radius_all(8)
	if focus_cue:
		style.set_expand_margin_all(3.0)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.3)
	style.shadow_size = 5
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
	_draw_grid()
	draw_rect(Rect2(48, 38, 864, 464), Color(DEEP_NAVY, 0.74), true)
	draw_rect(Rect2(72, 62, 816, 338), PANEL, true)
	draw_rect(Rect2(72, 62, 8, 338), CORAL, true)
	draw_string(_font, Vector2(108, 108), "BACKUP CHANNELS  •  0 / 3", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CORAL)
	draw_string(_font, Vector2(108, 154), "SIGNAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, INK)
	draw_string(_font, Vector2(108, 191), "LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, CORAL)
	draw_string(_font, Vector2(108, 235), "The last ping is safe.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, CYAN)
	draw_string(_font, Vector2(108, 264), "Every backup channel is dark.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, MUTED)
	for index in range(5):
		var x := 120.0 + index * 71.0
		if index < 4:
			draw_line(Vector2(x + 13, 326), Vector2(x + 58, 326), Color(CORAL, 0.35), 3.0)
		draw_circle(Vector2(x, 326), 12, DEEP_NAVY)
		draw_line(Vector2(x - 5, 321), Vector2(x + 5, 331), CORAL, 2.5)
		draw_line(Vector2(x + 5, 321), Vector2(x - 5, 331), CORAL, 2.5)
	draw_string(_font, Vector2(108, 366), "THE ROUTE CAN BE REBUILT", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, INK)
	var ping_alpha := 0.28 + (sin(_elapsed * 2.4) + 1.0) * 0.13
	draw_arc(Vector2(708, 260), 72, -1.0, 1.0, 24, Color(CYAN, ping_alpha), 3.0)
	draw_arc(Vector2(708, 260), 96, -1.0, 1.0, 24, Color(CYAN, ping_alpha * 0.7), 2.0)


func _draw_grid() -> void:
	for x in range(0, 961, 36):
		draw_line(Vector2(x, 0), Vector2(x, 540), Color(CORAL, 0.025), 1.0)
	for y in range(0, 541, 36):
		draw_line(Vector2(0, y), Vector2(960, y), Color(CORAL, 0.025), 1.0)
