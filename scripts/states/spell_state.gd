class_name SpellState
extends Node

signal state_finished(next_state_name: String)
signal cast_completed(cast_rank: String)

var aspect_data: AspectData
var timer: float = 0.0
var owner_node: Node = null

func _on_enter() -> void:
	timer = 0.0

func _on_exit() -> void:
	pass

func _on_update(delta: float) -> void:
	timer += delta

func _on_input(event: InputEvent) -> void:
	pass

func _on_damage(amount: int) -> void:
	pass

func is_in_window(center: float, tolerance: float, current_time: float) -> bool:
	return current_time >= (center - tolerance) and current_time <= (center + tolerance)

func set_owner_node(node: Node) -> void:
	owner_node = node
