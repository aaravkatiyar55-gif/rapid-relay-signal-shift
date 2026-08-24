class_name MiniGameBase
extends Node2D

signal finished(success: bool)

var _resolved: bool = false
var _feedback: String = ""
var _result_success: bool = false
var _resolution_generation := 0


func _reset_resolution_state() -> void:

	# Invalidating the generation prevents an old result timer from emitting into a reset run.
	_resolution_generation += 1
	_resolved = false
	_result_success = false
	set_process(true)
	set_process_unhandled_input(true)


func _resolve(success: bool, message: String, delay := 0.75) -> void:

	if _resolved:
		return
	_resolution_generation += 1
	var this_generation := _resolution_generation
	_resolved = true
	_feedback = message
	_result_success = success
	set_process(false)
	set_process_unhandled_input(false)
	queue_redraw()
	await get_tree().create_timer(delay).timeout
	if this_generation != _resolution_generation:
		return
	finished.emit(_result_success)
