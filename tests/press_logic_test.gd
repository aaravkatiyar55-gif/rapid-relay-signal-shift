extends SceneTree

const PRESS_SCENE := preload("res://scenes/MiniGamePress.tscn")

var _failures := 0


func _init() -> void:

	await _test_early_press()
	await _test_good_press()
	await _test_late_press()
	print("PRESS_LOGIC_TESTS failures=", _failures)
	quit(_failures)


func _test_early_press() -> void:

	var press_game := await _new_press_game()
	press_game._unhandled_input(_space_event())
	var result: bool = await press_game.finished
	_expect(result == false, "early Space fails")
	press_game.queue_free()


func _test_good_press() -> void:

	var press_game := await _new_press_game()
	press_game._process(1.7)
	press_game._unhandled_input(_space_event())
	var result: bool = await press_game.finished
	_expect(result == true, "Space during GO succeeds")
	press_game.queue_free()


func _test_late_press() -> void:

	var press_game := await _new_press_game()
	press_game._process(2.7)
	var result: bool = await press_game.finished
	_expect(result == false, "timeout after GO fails")
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


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
