extends SceneTree

const MENU_SCENE := preload("res://scenes/MainMenu.tscn")
const WIN_SCENE := preload("res://scenes/WinScene.tscn")
const DEATH_SCENE := preload("res://scenes/DeathScene.tscn")

var _failures := 0


func _init() -> void:

	await _test_menu_start()
	await _test_replay_routes()
	print("NAVIGATION_TESTS failures=", _failures)
	quit(_failures)


func _test_menu_start() -> void:

	change_scene_to_packed(MENU_SCENE)
	await _settle_scene()
	_expect(current_scene.has_node("StartRelay") and current_scene.get_node("StartRelay").has_focus(), "main menu starts with visible button focus")
	current_scene._start_relay()
	await _settle_scene()
	_expect(current_scene.name == "Game", "Start Relay opens the game scene")
	_expect(current_scene._round_index == 0 and current_scene._signal_bars == 3, "new relay run starts with three bars")


func _test_replay_routes() -> void:

	change_scene_to_packed(DEATH_SCENE)
	await _settle_scene()
	current_scene._try_again()
	await _settle_scene()
	_expect(current_scene.name == "Game" and current_scene._signal_bars == 3, "Try Again resets the relay state")

	change_scene_to_packed(WIN_SCENE)
	await _settle_scene()
	current_scene._back_to_menu()
	await _settle_scene()
	_expect(current_scene.name == "MainMenu", "Back to Menu returns to MainMenu")

	change_scene_to_packed(WIN_SCENE)
	await _settle_scene()
	current_scene._play_again()
	await _settle_scene()
	_expect(current_scene.name == "Game" and current_scene._round_index == 0, "Play Again starts a fresh relay run")


func _settle_scene() -> void:

	await process_frame
	await process_frame


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
