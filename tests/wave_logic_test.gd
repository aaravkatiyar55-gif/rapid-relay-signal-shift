extends SceneTree

const WAVE_SCENE := preload("res://scenes/MiniGameWave.tscn")

var _failures := 0
var _emission_count := 0


func _init() -> void:

	await _test_left_and_right_move_needle()
	await _test_crossing_target_does_not_instant_lock()
	await _test_lock_success()
	await _test_leaving_band_resets_lock()
	await _test_timeout_failure()
	await _test_target_acquired_too_late_fails()
	await _test_duplicate_resolution_is_blocked()
	await _test_reset_cancels_pending_result()
	await _test_reset_restores_playable_state()
	print("WAVE_LOGIC_TESTS failures=", _failures)
	quit(_failures)


func _test_left_and_right_move_needle() -> void:

	var wave_game := await _new_wave_game()
	var start_x: float = wave_game._needle_x
	wave_game._advance(0.2, -1.0)
	var left_x: float = wave_game._needle_x
	wave_game._advance(0.2, 1.0)
	_expect(left_x < start_x, "Left moves the tuning needle left")
	_expect(wave_game._needle_x > left_x, "Right moves the tuning needle right")
	wave_game.queue_free()


func _test_crossing_target_does_not_instant_lock() -> void:

	var wave_game := await _new_wave_game()
	var travel_time: float = (wave_game.TARGET_CENTER_X - wave_game.NEEDLE_START_X) / wave_game.NEEDLE_SPEED
	wave_game._advance(travel_time, 1.0)
	_expect(wave_game._is_needle_in_target(), "a long movement frame can end inside the target band")
	_expect(is_zero_approx(wave_game._lock_elapsed) and not wave_game._resolved, "crossing into the band does not count travel time as a stable hold")
	wave_game.queue_free()


func _test_lock_success() -> void:

	var wave_game := await _new_wave_game()
	wave_game._needle_x = wave_game.TARGET_CENTER_X
	wave_game._advance(wave_game.LOCK_REQUIRED + 0.05, 0.0)
	_expect(not wave_game.is_processing() and not wave_game.is_processing_unhandled_input(), "resolution stops Wave Tuner processing and controls")
	var result: bool = await wave_game.finished
	_expect(result == true, "holding the needle in the target band succeeds")
	wave_game.queue_free()


func _test_leaving_band_resets_lock() -> void:

	var wave_game := await _new_wave_game()
	wave_game._needle_x = wave_game.TARGET_CENTER_X
	wave_game._advance(wave_game.LOCK_REQUIRED - 0.1, 0.0)
	wave_game._needle_x = wave_game.TARGET_MAX_X + 1.0
	wave_game._advance(0.05, 0.0)
	_expect(is_zero_approx(wave_game._lock_elapsed), "leaving the target band resets hold progress")
	wave_game._needle_x = wave_game.TARGET_CENTER_X
	wave_game._advance(0.15, 0.0)
	_expect(not wave_game._resolved, "partial holds on separate visits do not combine")
	wave_game.queue_free()


func _test_timeout_failure() -> void:

	var wave_game := await _new_wave_game()
	wave_game._advance(wave_game.TIME_LIMIT - 0.01, 0.0)
	_expect(not wave_game._resolved, "Wave Tuner stays active before 4.5 seconds")
	wave_game._advance(0.02, 0.0)
	var result: bool = await wave_game.finished
	_expect(result == false, "letting the 4.5 second tuning timer expire fails")
	wave_game.queue_free()


func _test_target_acquired_too_late_fails() -> void:

	var wave_game := await _new_wave_game()
	wave_game._elapsed = wave_game.TIME_LIMIT - 0.1
	wave_game._needle_x = wave_game.TARGET_CENTER_X
	wave_game._advance(wave_game.LOCK_REQUIRED, 0.0)
	var result: bool = await wave_game.finished
	_expect(result == false, "entering the target too late cannot bypass the timeout")
	wave_game.queue_free()


func _test_duplicate_resolution_is_blocked() -> void:

	var wave_game := await _new_wave_game()
	_emission_count = 0
	wave_game.finished.connect(_record_emission)
	wave_game._needle_x = wave_game.TARGET_CENTER_X
	wave_game._advance(wave_game.LOCK_REQUIRED + 0.05, 0.0)
	wave_game._advance(wave_game.TIME_LIMIT + 0.05, 0.0)
	await create_timer(1.0).timeout
	_expect(_emission_count == 1, "Wave Tuner emits only one finished result")
	wave_game.queue_free()


func _test_reset_cancels_pending_result() -> void:

	var wave_game := await _new_wave_game()
	_emission_count = 0
	wave_game.finished.connect(_record_emission)
	wave_game._needle_x = wave_game.TARGET_CENTER_X
	wave_game._advance(wave_game.LOCK_REQUIRED + 0.05, 0.0)
	wave_game.reset_game()
	await create_timer(1.0).timeout
	_expect(_emission_count == 0, "reset cancels a result timer from the previous run")
	_expect(not wave_game._resolved, "stale result timer cannot re-resolve a reset game")
	wave_game.queue_free()


func _test_reset_restores_playable_state() -> void:

	var wave_game := await _new_wave_game()
	wave_game._needle_x = wave_game.TARGET_CENTER_X
	wave_game._advance(wave_game.LOCK_REQUIRED + 0.05, 0.0)
	var first_result: bool = await wave_game.finished
	_expect(first_result == true, "first Wave Tuner run resolves successfully")
	wave_game.reset_game()
	_expect(not wave_game._resolved and not wave_game._result_success, "reset clears inherited result state")
	_expect(is_zero_approx(wave_game._elapsed) and is_zero_approx(wave_game._lock_elapsed), "reset clears Wave Tuner timers")
	_expect(wave_game.is_processing() and wave_game.is_processing_unhandled_input(), "reset re-enables Wave Tuner processing and controls")
	wave_game.set_process(false)
	wave_game._advance(wave_game.TIME_LIMIT + 0.05, 0.0)
	var second_result: bool = await wave_game.finished
	_expect(second_result == false, "reset Wave Tuner can resolve a new result")
	wave_game.queue_free()


func _new_wave_game() -> Node:

	var wave_game := WAVE_SCENE.instantiate()
	root.add_child(wave_game)
	await process_frame
	wave_game.set_process(false)
	return wave_game


func _record_emission(_success: bool) -> void:

	_emission_count += 1


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
