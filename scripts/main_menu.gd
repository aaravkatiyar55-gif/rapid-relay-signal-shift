extends Node2D

const GAME_SCENE := "res://scenes/Game.tscn"
const NAVY := Color("10162e")
const DEEP_NAVY := Color("0a0f22")
const PANEL := Color("22274a")
const INK := Color("edf0df")
const CYAN := Color("69e9ff")
const LIME := Color("b8f56c")
const CORAL := Color("ff7a78")
const MUTED := Color("8892bf")

var _font: Font
var _kite: Sprite2D
var _elapsed := 0.0


func _ready() -> void:
	_font = ThemeDB.fallback_font
	_make_start_button()
	_add_kite()
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	if is_instance_valid(_kite):
		_kite.position.y = 254.0 + sin(_elapsed * 1.8) * 7.0
		_kite.rotation = sin(_elapsed * 1.15) * 0.025
	queue_redraw()


func _make_start_button() -> void:
	var button := Button.new()
	button.name = "StartRelay"
	button.text = "START THE NIGHT SHIFT  >"
	button.position = Vector2(78, 382)
	button.size = Vector2(330, 60)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", NAVY)
	button.add_theme_stylebox_override("normal", _button_style(LIME, LIME, 8))
	button.add_theme_stylebox_override("hover", _button_style(CYAN, CYAN, 8))
	button.add_theme_stylebox_override("focus", _button_style(LIME, CYAN, 8, true))
	button.pressed.connect(_start_relay)
	add_child(button)
	button.grab_focus()


func _add_kite() -> void:
	_kite = Sprite2D.new()
	var kite_texture := load("res://assets/kite_drone.svg") as Texture2D
	if kite_texture != null:
		_kite.texture = kite_texture
	_kite.position = Vector2(710, 254)
	_kite.scale = Vector2(0.72, 0.72)
	add_child(_kite)


func _button_style(background: Color, border: Color, radius: int, focus_cue := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(6 if focus_cue else 3)
	style.set_corner_radius_all(radius)
	if focus_cue:
		style.set_expand_margin_all(3.0)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 6
	return style


func _start_relay() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), NAVY)
	_draw_grid()
	draw_rect(Rect2(28, 24, 904, 492), Color(DEEP_NAVY, 0.56), true)
	draw_rect(Rect2(48, 44, 404, 432), PANEL, true)
	draw_line(Vector2(452, 44), Vector2(452, 476), CYAN, 2.0)

	# The station window gives KITE a clear place in the story.
	draw_circle(Vector2(710, 252), 178, DEEP_NAVY)
	draw_arc(Vector2(710, 252), 178, 0.0, TAU, 72, CYAN, 3.0)
	draw_arc(Vector2(710, 252), 145, -2.7, -0.25, 44, Color(CYAN, 0.32), 3.0)
	draw_arc(Vector2(710, 252), 122, 0.25, 2.7, 44, Color(LIME, 0.25), 3.0)
	for star in [Vector2(575, 151), Vector2(637, 102), Vector2(789, 112), Vector2(842, 217), Vector2(585, 332), Vector2(810, 366)]:
		draw_circle(star, 2.5, INK)

	draw_string(_font, Vector2(78, 86), "RELAY STATION FIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, CYAN)
	draw_string(_font, Vector2(78, 132), "RAPID RELAY", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, INK)
	draw_string(_font, Vector2(79, 161), "SIGNAL SHIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, LIME)
	draw_rect(Rect2(78, 184, 68, 4), CORAL, true)
	draw_string(_font, Vector2(78, 225), "An ion storm cut KITE's route home.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, INK)
	draw_string(_font, Vector2(78, 254), "Repair five relay links before every", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, MUTED)
	draw_string(_font, Vector2(78, 279), "backup channel goes dark.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, MUTED)
	draw_string(_font, Vector2(78, 326), "5 RAPID TESTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CYAN)
	for index in range(5):
		var node_x := 86.0 + index * 65.0
		if index < 4:
			draw_line(Vector2(node_x + 14, 348), Vector2(node_x + 51, 348), Color(CYAN, 0.35), 3.0)
		draw_circle(Vector2(node_x, 348), 10, DEEP_NAVY)
		draw_arc(Vector2(node_x, 348), 10, 0.0, TAU, 20, LIME if index == 0 else CYAN, 2.0)
	draw_string(_font, Vector2(78, 468), "TAB + ENTER  •  SPACE  •  ARROWS  •  MOUSE / TOUCH", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, MUTED)
	draw_string(_font, Vector2(614, 466), "INCOMING SIGNAL: KITE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, CYAN)


func _draw_grid() -> void:
	for x in range(0, 961, 32):
		draw_line(Vector2(x, 0), Vector2(x, 540), Color(CYAN, 0.035), 1.0)
	for y in range(0, 541, 32):
		draw_line(Vector2(0, y), Vector2(960, y), Color(CYAN, 0.035), 1.0)
	draw_line(Vector2(0, 80), Vector2(220, 80), Color(CYAN, 0.18), 2.0)
	draw_line(Vector2(740, 494), Vector2(960, 494), Color(LIME, 0.14), 2.0)
