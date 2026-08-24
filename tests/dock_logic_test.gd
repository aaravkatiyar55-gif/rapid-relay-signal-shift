extends SceneTree

const DOCK_SCENE := preload("res://scenes/MiniGameDock.tscn")

var _failures := 0
var _emission_count := 0


func _init() -> void:

	await _test_correct_drag_drop_success()
	await _test_empty_drop_retries()
	await _test_wrong_socket_failure()
	await _test_keyboard_alternative()
	await _test_timeout_failure()
	await _test_duplicate_resolution_stops_and_resets()
	print("DOCK_LOGIC_TESTS failures=", _failures)
	quit(_failures)


func _test_correct_drag_drop_success() -> void:

	var dock_game := await _new_dock_game()
	dock_game._handle_drop(dock_game.SOCKET_CENTERS[dock_game.CORRECT_SOCKET])
	var result: bool = await dock_game.finished
	_expect(result == true, "dropping the symbol core into its matching socket succeeds")
	dock_game.queue_free()


func _test_empty_drop_retries() -> void:

	var dock_game := await _new_dock_game()
	dock_game._core_position = Vector2(150, 150)
	dock_game._handle_drop(Vector2(150, 150))
	_expect(not dock_game._resolved, "dropping outside all sockets keeps the round active")
	_expect(dock_game._core_position == dock_game.CORE_START, "an empty drop returns the core for another try")
	dock_game.queue_free()


func _test_wrong_socket_failure() -> void:

	var dock_game := await _new_dock_game()
	dock_game._handle_drop(dock_game.SOCKET_CENTERS[0])
	var result: bool = await dock_game.finished
	_expect(result == false, "dropping into a wrong socket fails immediately")
	dock_game.queue_free()


func _test_keyboard_alternative() -> void:

	var dock_game := await _new_dock_game()
	dock_game._handle_keycode(KEY_RIGHT)
	dock_game._handle_keycode(KEY_ENTER)
	var result: bool = await dock_game.finished
	_expect(result == true, "Right plus Enter docks the core without a pointer")
	dock_game.queue_free()


func _test_timeout_failure() -> void:

	var dock_game := await _new_dock_game()
	dock_game._advance(dock_game.TIME_LIMIT + 0.05)
	var result: bool = await dock_game.finished
	_expect(result == false, "the 5 second dock timer fails when it expires")
	dock_game.queue_free()


func _test_duplicate_resolution_stops_and_resets() -> void:

	var dock_game := await _new_dock_game()
	_emission_count = 0
	dock_game.finished.connect(_record_emission)
	dock_game._handle_drop(dock_game.SOCKET_CENTERS[dock_game.CORRECT_SOCKET])
	dock_game._handle_drop(dock_game.SOCKET_CENTERS[0])
	dock_game._advance(dock_game.TIME_LIMIT + 0.05)
	await dock_game.finished
	await process_frame
	_expect(_emission_count == 1, "Core Dock emits only one finished result")
	_expect(not dock_game.is_processing() and not dock_game.is_processing_unhandled_input(), "Core Dock stops after resolution")
	dock_game.reset_game()
	_expect(not dock_game._resolved and dock_game._core_position == dock_game.CORE_START and is_zero_approx(dock_game._elapsed), "Core Dock resets core, timer, and result state")
	_expect(dock_game.is_processing() and dock_game.is_processing_unhandled_input(), "Core Dock re-enables processing on reset")
	dock_game.queue_free()


func _new_dock_game() -> Node:

	var dock_game := DOCK_SCENE.instantiate()
	root.add_child(dock_game)
	await process_frame
	return dock_game


func _record_emission(_success: bool) -> void:

	_emission_count += 1


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
