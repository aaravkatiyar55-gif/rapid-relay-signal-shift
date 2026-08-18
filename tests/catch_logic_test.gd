extends SceneTree

const CATCH_SCENE := preload("res://scenes/MiniGameCatch.tscn")

var _failures := 0


func _init() -> void:

	await _test_orb_click()
	await _test_wrong_click()
	await _test_timeout()
	print("CATCH_LOGIC_TESTS failures=", _failures)
	quit(_failures)


func _test_orb_click() -> void:

	var catch_game := await _new_catch_game()
	catch_game._handle_click(catch_game._orb_position)
	var result: bool = await catch_game.finished
	_expect(result == true, "clicking the orb succeeds")
	catch_game.queue_free()


func _test_wrong_click() -> void:

	var catch_game := await _new_catch_game()
	catch_game._handle_click(Vector2(40, 40))
	var result: bool = await catch_game.finished
	_expect(result == false, "clicking outside the orb fails")
	catch_game.queue_free()


func _test_timeout() -> void:

	var catch_game := await _new_catch_game()
	catch_game._process(3.4)
	var result: bool = await catch_game.finished
	_expect(result == false, "letting the orb escape fails")
	catch_game.queue_free()


func _new_catch_game() -> Node:

	var catch_game := CATCH_SCENE.instantiate()
	root.add_child(catch_game)
	await process_frame
	return catch_game


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
