extends SceneTree

const MENU_SCENE := preload("res://scenes/MainMenu.tscn")
const GAME_SCENE := preload("res://scenes/Game.tscn")
const WIN_SCENE := preload("res://scenes/WinScene.tscn")
const DEATH_SCENE := preload("res://scenes/DeathScene.tscn")

var _failures := 0


func _init() -> void:

	await _test_menu_start()
	await _test_menu_enter_dispatch()
	await _test_escape_during_result_delay()
	await _test_replay_routes()
	await _test_ending_escape_dispatch()
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


func _test_menu_enter_dispatch() -> void:

	change_scene_to_packed(MENU_SCENE)
	await _settle_scene()
	_expect(current_scene.get_node("StartRelay").has_focus(), "Enter test starts on the focused relay button")
	await _dispatch_key(KEY_ENTER)
	await _settle_scene()
	_expect(
		current_scene.name == "Game"
		and current_scene._current_game.name == "MiniGamePress",
		"real Enter input starts the relay at Pulse Press"
	)


func _test_escape_during_result_delay() -> void:

	change_scene_to_packed(GAME_SCENE)
	await _settle_scene()
	var game := current_scene
	game._current_game.emit_signal("finished", true)
	await process_frame
	_expect(
		game._round_resolved and game._round_index == 0,
		"connected result enters the controller delay before Escape"
	)
	await _dispatch_key(KEY_ESCAPE)
	await _settle_scene()
	_expect(current_scene.name == "MainMenu", "real Escape input leaves the controller result delay")
	await create_timer(0.85).timeout
	_expect(current_scene.name == "MainMenu", "expired result delay cannot replace the menu")


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


func _test_ending_escape_dispatch() -> void:

	change_scene_to_packed(WIN_SCENE)
	await _settle_scene()
	await _dispatch_key(KEY_ESCAPE)
	await _settle_scene()
	_expect(current_scene.name == "MainMenu", "real Escape input leaves WinScene")

	change_scene_to_packed(DEATH_SCENE)
	await _settle_scene()
	await _dispatch_key(KEY_ESCAPE)
	await _settle_scene()
	_expect(current_scene.name == "MainMenu", "real Escape input leaves DeathScene")


func _settle_scene() -> void:

	await process_frame
	await process_frame


func _dispatch_key(keycode: Key) -> void:

	var pressed := InputEventKey.new()
	pressed.keycode = keycode
	pressed.physical_keycode = keycode
	pressed.pressed = true
	pressed.echo = false
	Input.parse_input_event(pressed)
	await process_frame

	var released := InputEventKey.new()
	released.keycode = keycode
	released.physical_keycode = keycode
	released.pressed = false
	Input.parse_input_event(released)
	await process_frame


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
