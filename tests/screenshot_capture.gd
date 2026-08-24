extends SceneTree

const MENU_SCENE := preload("res://scenes/MainMenu.tscn")
const GAME_SCENE := preload("res://scenes/Game.tscn")
const WIN_SCENE := preload("res://scenes/WinScene.tscn")
const DEATH_SCENE := preload("res://scenes/DeathScene.tscn")
const EXPECTED_CAPTURES := [
	"res://screenshots/main-menu.png",
	"res://screenshots/pulse-press.png",
	"res://screenshots/orb-catch.png",
	"res://screenshots/wave-tuner.png",
	"res://screenshots/relay-round.png",
	"res://screenshots/relay-route.png",
	"res://screenshots/core-dock.png",
	"res://screenshots/transmission-complete.png",
	"res://screenshots/signal-lost.png",
]

var _saved_captures: Dictionary = {}
var _capture_failed := false


func _init() -> void:

	await _capture_scene(MENU_SCENE, "res://screenshots/main-menu.png")
	await _capture_round(0, "res://screenshots/pulse-press.png")
	await _capture_round(1, "res://screenshots/orb-catch.png")
	await _capture_round(2, "res://screenshots/wave-tuner.png")
	await _capture_round(2, "res://screenshots/relay-round.png")
	await _capture_round(3, "res://screenshots/relay-route.png")
	await _capture_round(4, "res://screenshots/core-dock.png")
	await _capture_scene(WIN_SCENE, "res://screenshots/transmission-complete.png")
	await _capture_scene(DEATH_SCENE, "res://screenshots/signal-lost.png")
	_verify_expected_captures()
	quit(1 if _capture_failed else 0)


func _capture_scene(scene: PackedScene, output_path: String) -> void:

	change_scene_to_packed(scene)
	await process_frame
	await process_frame
	await process_frame
	_save_viewport(output_path)


func _capture_round(round_index: int, output_path: String) -> void:

	change_scene_to_packed(GAME_SCENE)
	await process_frame
	await process_frame
	var game := current_scene
	if round_index > 0:
		if is_instance_valid(game._current_game):
			game._current_game.queue_free()
		await process_frame
		game._round_index = round_index
		game._round_results.clear()
		for _completed_index in range(round_index):
			game._round_results.append(true)
		game._start_next_round()
	await process_frame
	await process_frame
	await process_frame
	_save_viewport(output_path)


func _save_viewport(output_path: String) -> void:

	var image := root.get_texture().get_image()
	var result := image.save_png(ProjectSettings.globalize_path(output_path))
	if result != OK:
		_capture_failed = true
		push_error("Could not save screenshot: " + output_path)
	elif not FileAccess.file_exists(output_path):
		_capture_failed = true
		push_error("Screenshot file is missing after save: " + output_path)
	else:
		_saved_captures[output_path] = true
		print("SCREENSHOT: ", output_path)


func _verify_expected_captures() -> void:

	for output_path in EXPECTED_CAPTURES:
		if not _saved_captures.has(output_path) or not FileAccess.file_exists(output_path):
			_capture_failed = true
			push_error("Expected screenshot was not captured in this run: " + output_path)
