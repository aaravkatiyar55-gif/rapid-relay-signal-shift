extends SceneTree

const ROUTE_SCENE := preload("res://scenes/MiniGameRoute.tscn")

var _failures := 0
var _emission_count := 0


func _init() -> void:

	await _test_fixed_sequence_success()
	await _test_wrong_arrow_failure()
	await _test_timeout_failure()
	await _test_duplicate_resolution_stops_and_resets()
	print("ROUTE_LOGIC_TESTS failures=", _failures)
	quit(_failures)


func _test_fixed_sequence_success() -> void:

	var route_game := await _new_route_game()
	for keycode in route_game.SEQUENCE:
		route_game._handle_keycode(keycode)
	var result: bool = await route_game.finished
	_expect(result == true, "entering all four visible arrows succeeds")
	route_game.queue_free()


func _test_wrong_arrow_failure() -> void:

	var route_game := await _new_route_game()
	route_game._handle_keycode(KEY_LEFT)
	var result: bool = await route_game.finished
	_expect(result == false, "a wrong arrow fails immediately")
	route_game.queue_free()


func _test_timeout_failure() -> void:

	var route_game := await _new_route_game()
	route_game._advance(route_game.TIME_LIMIT + 0.05)
	var result: bool = await route_game.finished
	_expect(result == false, "the 4.2 second route timer fails when it expires")
	route_game.queue_free()


func _test_duplicate_resolution_stops_and_resets() -> void:

	var route_game := await _new_route_game()
	_emission_count = 0
	route_game.finished.connect(_record_emission)
	for keycode in route_game.SEQUENCE:
		route_game._handle_keycode(keycode)
	route_game._handle_keycode(KEY_LEFT)
	route_game._advance(route_game.TIME_LIMIT + 0.05)
	await route_game.finished
	await process_frame
	_expect(_emission_count == 1, "Route Decoder emits only one finished result")
	_expect(not route_game.is_processing() and not route_game.is_processing_unhandled_input(), "Route Decoder stops after resolution")
	route_game.reset_game()
	_expect(not route_game._resolved and route_game._step_index == 0 and is_zero_approx(route_game._elapsed), "Route Decoder resets progress and result state")
	_expect(route_game.is_processing() and route_game.is_processing_unhandled_input(), "Route Decoder re-enables processing on reset")
	route_game.queue_free()


func _new_route_game() -> Node:

	var route_game := ROUTE_SCENE.instantiate()
	root.add_child(route_game)
	await process_frame
	return route_game


func _record_emission(_success: bool) -> void:

	_emission_count += 1


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
