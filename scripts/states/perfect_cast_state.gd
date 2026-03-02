class_name PerfectCastState
extends CasterState

var perfect_cast_duration: float = 0.7

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		perfect_cast_duration = aspect_data.perfect_cast_duration
	print("[PerfectCastState] Entered - Perfect sync with Aspect!")
	
	# Увеличиваем комбо
	if owner_node != null and owner_node.has_method("increment_combo"):
		owner_node.increment_combo()

func _on_update(delta: float) -> void:
	super._on_update(delta)
	if timer >= perfect_cast_duration:
		state_finished.emit("AfterCast")

func _on_damage(amount: int) -> void:
	if aspect_data != null and aspect_data.interrupted_by_damage:
		if aspect_data.reset_combo_on_damage:
			if owner_node != null and owner_node.has_method("reset_combo"):
				owner_node.reset_combo()
		state_finished.emit("LowCast")
