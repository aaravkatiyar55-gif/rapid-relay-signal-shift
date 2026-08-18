extends SceneTree

const MENU_SCENE := preload("res://scenes/MainMenu.tscn")
const GAME_SCENE := preload("res://scenes/Game.tscn")
const WIN_SCENE := preload("res://scenes/WinScene.tscn")
const DEATH_SCENE := preload("res://scenes/DeathScene.tscn")


func _init() -> void:

	await _capture(MENU_SCENE, "res://screenshots/main-menu.png")
	await _capture(GAME_SCENE, "res://screenshots/relay-round.png")
	await _capture(WIN_SCENE, "res://screenshots/transmission-complete.png")
	await _capture(DEATH_SCENE, "res://screenshots/signal-lost.png")
	quit()


func _capture(scene: PackedScene, output_path: String) -> void:

	change_scene_to_packed(scene)
	await process_frame
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var result := image.save_png(ProjectSettings.globalize_path(output_path))
	if result != OK:
		push_error("Could not save screenshot: " + output_path)
	else:
		print("SCREENSHOT: ", output_path)
