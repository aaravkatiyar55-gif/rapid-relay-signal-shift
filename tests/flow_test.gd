extends SceneTree

const GAME_SCENE := preload("res://scenes/Game.tscn")

var _failures := 0


func _init() -> void:

	await _test_four_round_win()
	await _test_three_loss_death()
	print("FLOW_TESTS failures=", _failures)
	quit(_failures)


func _test_four_round_win() -> void:

	var game := await _new_game()
	_expect(game._current_game.name == "MiniGamePress", "round 1 starts with Pulse Press")
	await game._on_minigame_finished(true)
	_expect(game._round_index == 1 and game._current_game.name == "MiniGameCatch", "round 2 switches to Orb Catch")
	await game._on_minigame_finished(true)
	_expect(game._round_index == 2 and game._current_game.name == "MiniGamePress", "round 3 returns to Pulse Press")
	await game._on_minigame_finished(true)
	_expect(game._round_index == 3 and game._current_game.name == "MiniGameCatch", "round 4 switches to Orb Catch")
	await game._on_minigame_finished(true)
	await process_frame
	await process_frame
	_expect(current_scene != null and current_scene.name == "WinScene", "four successful rounds open WinScene")
	if current_scene != null:
		_expect(current_scene.has_node("PlayAgain") and current_scene.get_node("PlayAgain").has_focus(), "WinScene exposes a focused replay button")


func _test_three_loss_death() -> void:

	var game := await _new_game()
	await game._on_minigame_finished(false)
	_expect(game._signal_bars == 2, "first loss removes one signal bar")
	await game._on_minigame_finished(false)
	_expect(game._signal_bars == 1, "second loss removes one signal bar")
	await game._on_minigame_finished(false)
	await process_frame
	await process_frame
	_expect(current_scene != null and current_scene.name == "DeathScene", "zero bars open DeathScene")
	if current_scene != null:
		_expect(current_scene.has_node("TryAgain") and current_scene.get_node("TryAgain").has_focus(), "DeathScene exposes a focused retry button")


func _new_game() -> Node:

	change_scene_to_packed(GAME_SCENE)
	await process_frame
	await process_frame
	return current_scene


func _expect(condition: bool, label: String) -> void:

	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		push_error("FAIL: " + label)
