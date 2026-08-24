extends SceneTree

const PRESS_SCENE := preload("res://scenes/MiniGamePress.tscn")

var _failures := 0
var _emission_count := 0


func _init() -> void:

	await _test_wait_is_randomized_inside_target_range()
	await _test_early_press()
	await _test_good_press()
	await _test_late_press()
	await _test_duplicate_resolution_is_blocked()
	print("PRESS_LOGIC_TESTS failures=", _failures)
	quit(_failures)


func _test_wait_is_randomized_inside_target_range() -> void:

	var press_game := await _new_press_game()
	_expect(
		press_game._wait_duration >= press_game.WAIT_MIN
		and press_game._wait_duration <= press_game.WAIT_MAX,
		"GO wait stays between 1.25 and 1.9 seconds"
	)
	press_game.queue_free()


func _test_early_press() -> void:

	var press_game := await _new_press_game()
	press_game._unhandled_input(_space_event())
	var result: bool = await press_game.finished
	_expect(result == false, "early Space fails")
	press_game.queue_free()


func _test_good_press() -> void:

	var press_game := await _new_press_game()
	press_game._process(press_game._wait_duration + 0.01)
	press_game._unhandled_input(_space_event())
	var result: bool = await press_game.finished
	_expect(result == true, "Space during GO succeeds")
	press_game.queue_free()


func _test_late_press() -> void:

	var press_game := await _new_press_game()
	press_game._process(press_game._wait_duration + press_game.ACTIVE_WINDOW + 0.01)
	var result: bool = await press_game.finished
	_expect(result == false, "the 0.85-second GO window times out")
	press_game.queue_free()


func _test_duplicate_resolution_is_blocked() -> void:

	var press_game := await _new_press_game()
	_emission_count = 0
	press_game.finished.connect(_record_emission)
	press_game._resolve(true, "First result", 0.01)
	press_game._resolve(false, "Duplicate result", 0.01)
	var result: bool = await press_game.finished
	await process_frame
	_expect(
		result == true
		and press_game._feedback == "First result"
		and _emission_count == 1,
		"shared resolver preserves and emits only the first result"
	)
	press_game.queue_free()


func _new_press_game() -> Node:

	var press_game := PRESS_SCENE.instantiate()
	root.add_child(press_game)
	await process_frame
	return press_game


func _space_event() -> InputEventKey:

	var event := InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = true
	return event


func _record_emission(_success: bool) -> void:

	_emission_count += 1


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
