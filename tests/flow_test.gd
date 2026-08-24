extends SceneTree

const GAME_SCENE := preload("res://scenes/Game.tscn")
const EXPECTED_ROUNDS := [
	{"node": "MiniGamePress", "label": "WAKE"},
	{"node": "MiniGameCatch", "label": "CATCH"},
	{"node": "MiniGameWave", "label": "TUNE"},
	{"node": "MiniGameRoute", "label": "ROUTE"},
	{"node": "MiniGameDock", "label": "DOCK"},
]

var _failures := 0


func _init() -> void:

	await _test_five_round_plan_and_win()
	await _test_three_loss_death()
	await _test_final_failure_with_backup_bar_survives()
	await _test_duplicate_round_result_is_blocked()
	await _test_connected_finished_signal_updates_game()
	print("FLOW_TESTS failures=", _failures)
	quit(_failures)


func _test_five_round_plan_and_win() -> void:

	var game := await _new_game()
	_expect(game.ROUND_PLAN.size() == 5, "round plan derives a five-round total")
	for round_index in range(EXPECTED_ROUNDS.size()):
		var expected: Dictionary = EXPECTED_ROUNDS[round_index]
		var plan: Dictionary = game.ROUND_PLAN[round_index]
		_expect(
			game._round_index == round_index
			and game._current_game.name == expected["node"]
			and game._round_label == expected["label"],
			"round %d is %s / %s" % [round_index + 1, expected["label"], expected["node"]]
		)
		_expect(
			plan.has("story") and not String(plan["story"]).is_empty(),
			"round %d includes story metadata" % (round_index + 1)
		)
		await _finish_current_game(game, true)
	await process_frame
	await process_frame
	_expect(current_scene != null and current_scene.name == "WinScene", "five successful rounds open WinScene")
	if current_scene != null:
		_expect(current_scene.has_node("PlayAgain") and current_scene.get_node("PlayAgain").has_focus(), "WinScene exposes a focused replay button")


func _test_three_loss_death() -> void:

	var game := await _new_game()
	await _finish_current_game(game, false)
	_expect(game._signal_bars == 2, "first loss removes one signal bar")
	await _finish_current_game(game, false)
	_expect(game._signal_bars == 1, "second loss removes one signal bar")
	await _finish_current_game(game, false)
	await process_frame
	await process_frame
	_expect(current_scene != null and current_scene.name == "DeathScene", "zero bars open DeathScene")
	if current_scene != null:
		_expect(current_scene.has_node("TryAgain") and current_scene.get_node("TryAgain").has_focus(), "DeathScene exposes a focused retry button")


func _test_final_failure_with_backup_bar_survives() -> void:

	var game := await _new_game()
	for round_index in range(EXPECTED_ROUNDS.size() - 1):
		await _finish_current_game(game, true)
	await _finish_current_game(game, false)
	await process_frame
	await process_frame
	_expect(
		current_scene != null
		and current_scene.name == "WinScene",
		"failing the final round still wins when a backup bar remains"
	)


func _test_duplicate_round_result_is_blocked() -> void:

	var game := await _new_game()
	var active_game: Node = game._current_game
	active_game.emit_signal("finished", false)
	active_game.emit_signal("finished", false)
	await create_timer(0.85).timeout
	_expect(
		game._signal_bars == 2 and game._round_index == 1,
		"duplicate finished signals consume only one bar and advance once"
	)


func _test_connected_finished_signal_updates_game() -> void:

	var game := await _new_game()
	game._current_game.emit_signal("finished", false)
	_expect(
		game._round_resolved
		and game._signal_bars == 2
		and game._round_results == [false],
		"active minigame finished signal resolves the connected Game state"
	)
	await create_timer(0.85).timeout
	_expect(
		game._round_index == 1
		and game._current_game.name == "MiniGameCatch",
		"connected finished signal advances to the next active minigame"
	)


func _new_game() -> Node:

	change_scene_to_packed(GAME_SCENE)
	await process_frame
	await process_frame
	return current_scene


func _finish_current_game(game: Node, success: bool) -> void:

	game._current_game.emit_signal("finished", success)
	await create_timer(0.85).timeout


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
