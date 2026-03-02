class_name MissCastingState
extends CasterState

var miss_cast_duration: float = 0.8

func _on_enter() -> void:
	super._on_enter()
	if aspect_data != null:
		miss_cast_duration = aspect_data.miss_cast_duration
	print("[MissCastingState] Entered - Penalty!")

func _on_update(delta: float) -> void:
	super._on_update(delta)
	if timer >= miss_cast_duration:
		state_finished.emit("Idle")

func _on_damage(amount: int) -> void:
	pass  # В штрафе урон не прерывает
